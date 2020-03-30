#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "qrcodegen.h"
#include "libbmp.h"
#include <curl/curl.h>

static FILE* saveQr(const uint8_t qrcode[], int size_img_coef, const char* text);

int main(int argc, char **argv) {
	
	if(argc <= 1) {
		printf("Usage : ./qr [text]\n");
		return EXIT_FAILURE;
	}

	CURL *curl;
	FILE* qrcode;
	CURLcode res;
	curl_global_init(CURL_GLOBAL_ALL);
	curl = curl_easy_init();
	if(curl) {
		printf("Curl OK ! \n");
	}

	const char *name = argv[1];
	enum qrcodegen_Ecc errCorLvl = qrcodegen_Ecc_LOW;  // Error correction level
	
	// Make and print the QR Code symbol
	uint8_t qrcode_identifier[qrcodegen_BUFFER_LEN_MAX];
	uint8_t tempBuffer[qrcodegen_BUFFER_LEN_MAX];
	// Encode argv[1] with qrcodegen_encodeText function
	bool isSuccess = qrcodegen_encodeText(name, tempBuffer, qrcode_identifier, errCorLvl, qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX, qrcodegen_Mask_AUTO, true);
	if (isSuccess) {
		qrcode = saveQr(qrcode_identifier, 20, name);
		curl_easy_setopt(curl, CURLOPT_USERPWD, "wilk65537:H4E4tIWc");
		curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
		char* remote_url = (char*)malloc(strlen("ftp://192.168.1.16/uploads/") + strlen(name) + strlen(".bmp"));
		strcpy(remote_url, "ftp://192.168.1.16/uploads/");
		strcat(remote_url, name);
		strcat(remote_url, ".bmp");
		curl_easy_setopt(curl, CURLOPT_URL, remote_url);
		curl_easy_setopt(curl, CURLOPT_READDATA, qrcode);

		res = curl_easy_perform(curl);
		/* Check for errors */ 
		if(res != CURLE_OK) {
			fprintf(stderr, "curl_easy_perform() failed: %s\n",
				curl_easy_strerror(res));
		}
		free(remote_url);
		curl_easy_cleanup(curl);
		fclose(qrcode);
		curl_global_cleanup();
		return EXIT_SUCCESS;
	} else {
		return EXIT_FAILURE;
	}
}

static FILE* saveQr(const uint8_t qrcode[], int size_img_coef, const char* text) {
	bmp_img img;
	FILE* qrcodeFile;
	int size = qrcodegen_getSize(qrcode);
	bmp_img_init_df (&img, size * size_img_coef, size * size_img_coef);
	for (int y = 0; y < size; y++) {
		for (int yi = 0; yi < size_img_coef; yi += 1) {
			for (int x = 0; x < size; x++) {
				for (int xi = 0; xi < size_img_coef; xi += 1) {
					if (qrcodegen_getModule(qrcode, x, y)) 
					{
						bmp_pixel_init(&img.img_pixels[y * size_img_coef + yi][x * size_img_coef + xi], 250, 250, 250);
					} 
					else 
					{
						bmp_pixel_init(&img.img_pixels[y * size_img_coef + yi][x * size_img_coef + xi], 0, 0, 0);
					}
				}
			}
		}
	}

	// output/ = 7
	//  .bmp = 4
	char* filename = malloc(sizeof(char) * (11 + strlen(text)));
	strcpy(filename, "output/");
	strcat(filename, text);
	strcat(filename, ".bmp");

	bmp_img_write(&img, filename);
	bmp_img_free(&img);

	qrcodeFile = fopen(filename, "r");
	free(filename);
	return qrcodeFile;
}