#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <postgresql/libpq-fe.h>

 #define NUMBER_OF_CHAMPS 5

void do_exit(PGconn *conn) {
    
    PQfinish(conn);
    exit(1);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Erreur nombre d'argument\n Usage: %s name_data_file\n", argv[0]);
        return EXIT_FAILURE;
    }
    FILE* file = fopen(argv[1],"rb+");
    char *buffer = 0;
    size_t length;

    
    if (file == NULL) {
        fprintf(stderr, "Erreur fichier incorrect\n");
        exit(EXIT_FAILURE);
    }

    fseek(file, 0, SEEK_END);
    length = ftell(file);
    fseek(file, 0, SEEK_SET);
    buffer = malloc(length);
    if (buffer) {
        fread(buffer, sizeof(char), length, file);
    }
    char* paramValues[NUMBER_OF_CHAMPS];
    if (buffer) {
        char* pch;
        int i = 0;
        pch = strtok(buffer,"\n");
        while (pch != NULL) {
            paramValues[i] = (char*)malloc(strlen(pch) * sizeof(char));
            strcpy(paramValues[i], pch);
            pch = strtok(NULL, "\n");
            i += 1;
        }
    } else {
        fprintf(stderr, "Malloc Error\n");
        exit(EXIT_FAILURE);
    }

    PGresult *res = NULL;
   
    int paramLengths[NUMBER_OF_CHAMPS];
    int paramFormats[NUMBER_OF_CHAMPS];
    for (size_t i = 0; i < NUMBER_OF_CHAMPS; i++) {
        paramLengths[i] = sizeof(paramValues[i]);
        paramFormats[i] = 0;
    }
    
    int resultFormat = 0;

    /****     test param      *****/
    // for (size_t i = 0; i < NUMBER_OF_CHAMPS; i++) {
    //     printf("param Length: %d\n"
    //            "param Format: %d\n"
    //            "param value: %s\n",
    //            paramLengths[i],
    //            paramFormats[i],
    //            paramValues[i]);
    // }
    
    PGconn *conn = PQconnectdb("user=postgres password=drivncook dbname=drivncook hostaddr=51.255.173.90");

    if (PQstatus(conn) == CONNECTION_BAD) { 
        fprintf(stderr, "Connection to database failed: %s\n",
            PQerrorMessage(conn));
        do_exit(conn);
    }
    
    // res = PQexec(conn, "INSERT INTO user VALUES(NULL, ,)");
    const char* stmtName = "PREPARE_INSERT_USER";
    PGresult* stmt = PQprepare(
        conn,
        stmtName,
        "INSERT INTO users (first_name, last_name, society_name, siret, email, created_at)"
        "VALUES ($1, $2, $3, $4, $5, NOW());",
        5,
        NULL
    );
    if (PQresultStatus(stmt) != PGRES_COMMAND_OK) {
        fprintf(stderr, "PQexecPrepared failed: %s", PQresultErrorMessage(stmt));
        PQclear(stmt);
    } else {
        PQclear(stmt);
        res = PQexecPrepared(conn, 
            stmtName,
            5,
            (const char* const*)paramValues,
            paramLengths,
            paramFormats,
            resultFormat
        );
        if (PQresultStatus(res) != PGRES_COMMAND_OK) {
            fprintf(stderr, "PQexecPrepared failed: %s", PQresultErrorMessage(res));
        } else {
            printf("Enregistrement en BDD OK !\n");
        }
    }
    PQclear(stmt);
    
    PQfinish(conn);

    return EXIT_SUCCESS;
}