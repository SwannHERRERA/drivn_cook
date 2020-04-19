#include <stdio.h>
#include <stdlib.h>
#include <postgresql/libpq-fe.h>

void do_exit(PGconn *conn) {
    
    PQfinish(conn);
    exit(1);
}

int main(int argc, char** argv) {
    
    if (argc < 2) {
        fprintf(stderr, "Erreur nombre d'argument\n Usage: %s name_data_file", argv[0]);
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

    if (buffer) {
        // Do stuff
    } else {
        fprintf(stderr, "Erreur Malloc\n");
        exit(EXIT_FAILURE);
    }



    PGconn *conn = PQconnectdb("user=postgres password=drivncook dbname=postgres hostaddr=51.255.173.90");

    if (PQstatus(conn) == CONNECTION_BAD) { 
        fprintf(stderr, "Connection to database failed: %s\n",
            PQerrorMessage(conn));
        do_exit(conn);
    }
    
    // res = PQexec(conn, "INSERT INTO user VALUES(NULL, ,)");

    char *user = PQuser(conn);
    char *db_name = PQdb(conn);
    char *pswd = PQpass(conn);
    
    printf("User: %s\n", user);
    printf("Database name: %s\n", db_name);
    printf("Password: %s\n", pswd);
    
    PQfinish(conn);

    return EXIT_SUCCESS;
}