#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "qrcodegen.h"
#include "libbmp.h"

static void saveQr(const uint8_t qrcode[], int size_img_coef, const char* text);

int main(int argc, char **argv) {
	
	if(argc <= 1) {
		printf("Usage : ./qr [text]\n");
		return EXIT_FAILURE;
	}

	const char *text = argv[1];
	enum qrcodegen_Ecc errCorLvl = qrcodegen_Ecc_LOW;  // Error correction level
	
	// Make and print the QR Code symbol
	uint8_t qrcode[qrcodegen_BUFFER_LEN_MAX];
	uint8_t tempBuffer[qrcodegen_BUFFER_LEN_MAX];
	// Encode argv[1] with qrcodegen_encodeText function
	bool isSuccess = qrcodegen_encodeText(text, tempBuffer, qrcode, errCorLvl, qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX, qrcodegen_Mask_AUTO, true);
	if (isSuccess) {
		saveQr(qrcode, 20, text);
	}
	return EXIT_SUCCESS;
}

static void saveQr(const uint8_t qrcode[], int size_img_coef, const char* text) {
	bmp_img img;
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
	char *filename = malloc(sizeof(char) * (11 + strlen(text)));
	strcpy(filename, "output/");
	strcat(filename, text);
	strcat(filename, ".bmp");

	bmp_img_write (&img, filename);
	bmp_img_free (&img);
}