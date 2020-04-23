#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/sha.h>
#include "quirc_internal.h"
#include "dbgutil.h"

static char* dump_info(struct quirc *q);


int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Error number of argument");
        fprintf(stderr, "Usage: %s path_to_qr_code.png path_to_info_file\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *buffer = 0;
    size_t length;
    FILE *file = fopen(argv[2], "rb");
    char* qrcode_string;
    struct quirc *q;
    char hash[SHA_DIGEST_LENGTH * 2];
    unsigned char tmphash[SHA_DIGEST_LENGTH * 2];

    if (file) {
        fseek(file, 0, SEEK_END);
        length = ftell(file);
        fseek(file, 0, SEEK_SET);
        buffer = malloc(length);
        if (buffer) {
            if (length != fread(buffer, 1, length, file)) {
                fprintf(stderr, "Cannot read blocks in file\n");
				exit(EXIT_FAILURE);
            }
        }
        fclose(file);
    }

    if (buffer) {
        SHA1(buffer, length, tmphash);
        for (size_t i = 0; i < SHA_DIGEST_LENGTH; i++) {
            sprintf((char *)&(hash[i * 2]), "%02x", tmphash[i]);
        }
        printf("file hash :\n");
        printf("%s\n", hash);
    }
    q = quirc_new();
	if (!q) {
		perror("can't create quirc object");
		return EXIT_FAILURE;
	}
    load_png(q, argv[1]);
    quirc_end(q);
    qrcode_string = dump_info(q);
    if (strcmp(hash, qrcode_string)== 0) {
        quirc_destroy(q);
        free(qrcode_string);
        printf("File and hash are equal you can insert in database\n");
        return EXIT_SUCCESS;
    }
}

static char* dump_info(struct quirc *q) {
    char* str;
	int count = quirc_count(q);
	int i;

	printf("%d QR-codes found:\n\n", count);
	for (i = 0; i < count; i++) {
		struct quirc_code code;
		struct quirc_data data;
		quirc_decode_error_t err;

		quirc_extract(q, i, &code);
		err = quirc_decode(&code, &data);

		dump_cells(&code);
		printf("\n");

		if (err) {
			printf("Decoding FAILED: %s\n", quirc_strerror(err));
            exit(EXIT_FAILURE);
		} else {
			printf("Decoding successful:\n");
			printf("%s\n", data.payload);
            str = (char*)malloc(strlen(data.payload) * sizeof(char));
            strcpy(str, data.payload);
            return str;
		}
	}
}