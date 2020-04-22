#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "qrcodegen.h"
#include <png.h>
#include <curl/curl.h>
#include <gtk/gtk.h>
#include <openssl/sha.h>


typedef struct {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} pixel_t;

typedef struct {
    pixel_t* pixels;
    size_t width;
    size_t height;
} bitmap_t;

void create_file();
void sha1_file(FILE* file, char* hash);
void on_submit_button_clicked();
static pixel_t * pixel_at (bitmap_t * bitmap, int x, int y);
static int save_png_to_file(bitmap_t *bitmap, const char *path);
static FILE* saveQr(const uint8_t qrcode[], int size_img_coef, const char* text);


GtkBuilder* 	builder; 

GtkWidget*		main_window;

GtkWidget* 		main_container;

GtkWidget *logo, *submit_button, *lastname_input, *firstname_input, *siret_input, *email_input, *enterprise_name_input, *error_input;


void load_widget() {
	main_window = GTK_WIDGET(gtk_builder_get_object(builder, "main_window"));
    gtk_window_set_title(GTK_WINDOW(main_window), "DrivnCook creation franchisée");
    g_signal_connect(main_window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    main_container       	= GTK_WIDGET(gtk_builder_get_object(builder, "main_container"));
    submit_button      		= GTK_WIDGET(gtk_builder_get_object(builder, "submit_button"));
    lastname_input         	= GTK_WIDGET(gtk_builder_get_object(builder, "lastname_input"));
    firstname_input  		= GTK_WIDGET(gtk_builder_get_object(builder, "firstname_input"));
    siret_input    		= GTK_WIDGET(gtk_builder_get_object(builder, "siret_input"));
    email_input       	= GTK_WIDGET(gtk_builder_get_object(builder, "email_input"));
    enterprise_name_input   = GTK_WIDGET(gtk_builder_get_object(builder, "enterprise_name_input"));
	error_input				= GTK_WIDGET(gtk_builder_get_object(builder, "error_input"));
}

int main(int argc, char **argv) {
	gtk_init(&argc, &argv);

	builder = gtk_builder_new_from_file("./assets/glade/main.glade");
	
	load_widget();

	gtk_builder_connect_signals(builder, NULL);

    gtk_widget_show(main_window);

    g_object_unref(builder);
    gtk_main();

	return EXIT_SUCCESS; 
}

void on_submit_button_clicked() {
	char* file_name = malloc(sizeof(char) * strlen(gtk_entry_get_text(GTK_ENTRY(lastname_input))));
	file_name = (char*)gtk_entry_get_text(GTK_ENTRY(lastname_input));
	if (!strcmp(file_name, "")) {
		gtk_entry_set_text(GTK_ENTRY(error_input), (const gchar*) "Erreur 'Lastname'");
		return;
	}

	char* txt_path = (char*)malloc(sizeof(char) * (strlen(gtk_entry_get_text(GTK_ENTRY(lastname_input))) + strlen("output/.txt")));
	strcpy(txt_path, "output/");
	strcat(txt_path, (char*)gtk_entry_get_text(GTK_ENTRY(lastname_input)));
	strcat(txt_path, ".txt");
	
	CURL *curl;
	FILE* qrcode;
	FILE* file_info;
	char* hash = (char*)malloc(sizeof(char) * ((SHA_DIGEST_LENGTH * 2) + 1));
	if (!hash) {
		fprintf(stderr, "Error Malloc hash");
		exit(EXIT_FAILURE);
	}
	char* remote_url;
	CURLcode res;
	curl_global_init(CURL_GLOBAL_ALL);
	curl = curl_easy_init();
	if(curl) {
		printf("Curl OK ! \n");
	}

	enum qrcodegen_Ecc errCorLvl = qrcodegen_Ecc_LOW;  // Error correction level

	create_file();
	file_info = fopen(txt_path, "rb");
	sha1_file(file_info, hash);
	fclose(file_info);
	printf("%s\n", hash);
	

	// FOR QRCODE
	uint8_t qrcode_identifier[qrcodegen_BUFFER_LEN_MAX];
	uint8_t tempBuffer[qrcodegen_BUFFER_LEN_MAX];


	bool isSuccess = qrcodegen_encodeText(hash, tempBuffer, qrcode_identifier, errCorLvl, qrcodegen_VERSION_MIN, qrcodegen_VERSION_MAX, qrcodegen_Mask_AUTO, true);
	if (isSuccess) {
		qrcode = saveQr(qrcode_identifier, 20, file_name);
		curl_easy_setopt(curl, CURLOPT_USERPWD, "swann:myges");
		curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
		curl_easy_setopt(curl, CURLOPT_PORT, 2222L);
		char* remote_url = (char*)malloc((strlen("sftp://51.255.173.90/home/swann/uploads/") + strlen(file_name) + strlen(".png")) * sizeof(char));
		strcpy(remote_url, "sftp://51.255.173.90/home/swann/uploads/");
		strcat(remote_url, file_name);
		strcat(remote_url, ".png");

		printf("%s\n", remote_url);

		curl_easy_setopt(curl, CURLOPT_URL, remote_url);
		curl_easy_setopt(curl, CURLOPT_READDATA, qrcode);


		res = curl_easy_perform(curl);

		/* Check for errors */ 
		if(res != CURLE_OK) {
			fprintf(stderr, "curl_easy_perform() failed: %s\n",
				curl_easy_strerror(res));
		}

		strcpy(remote_url, "sftp://51.255.173.90/home/swann/uploads/");
		strcat(remote_url, file_name);
		strcat(remote_url, ".txt");

		file_info = fopen(txt_path, "r");

		curl_easy_setopt(curl, CURLOPT_URL, remote_url);
		curl_easy_setopt(curl, CURLOPT_READDATA, file_info);

		res = curl_easy_perform(curl);

		/* Check for errors */ 
		if(res != CURLE_OK) {
			fprintf(stderr, "curl_easy_perform() failed: %s\n",
				curl_easy_strerror(res));
		}

		free(remote_url);
		
		curl_easy_cleanup(curl);
		curl_global_cleanup();
		fclose(file_info);
		free(hash);
		free(file_name);
		free(txt_path);
		gtk_main_quit();
	} else {
		exit(EXIT_FAILURE);
	}
}

static FILE* saveQr(const uint8_t qrcode[], int size_img_coef, const char* text) {
	bitmap_t img;
	unsigned int padding = 4;
	FILE* qrcodeFile;
	int size = qrcodegen_getSize(qrcode);
	img.width = (size + padding) * size_img_coef;
	img.height = (size + padding) * size_img_coef;
	img.pixels = calloc((img.width * size_img_coef) * (img.height * size_img_coef), sizeof(pixel_t));

	if (!img.pixels) {
		fprintf(stderr, "Error calloc");
		exit(EXIT_FAILURE);
    }

	/**
	 * This loop make firsts line of pixels white
	*/
	for (size_t y = 0; y <= (padding / 2) * size_img_coef; y += 1) {
		for (size_t x = 0; x < img.width; x += 1) {
			for (size_t xi = 0; xi < size_img_coef; xi += 1) {
				pixel_t* pixel = pixel_at(&img, x * size_img_coef + xi, y);
				pixel->red = 250;
				pixel->green = 250;
				pixel->blue = 250;
			}
		}
	}
	
	/**
	 * Main loop write qrcode 
	 */
	for (size_t y = 0; y < img.height; y += 1) {
		for (size_t yi = 0; yi < size_img_coef; yi += 1) {
			for (size_t x = 0; x < img.width; x += 1) {
				for (size_t xi = 0; xi < size_img_coef; xi += 1) {
					if (qrcodegen_getModule(qrcode, x, y)) {
						pixel_t* pixel = pixel_at(&img, (x + 2) * size_img_coef + xi, (y + 2) * size_img_coef + yi);
            			pixel->red = 0;
            			pixel->green = 0;
            			pixel->blue = 0;
					} else {
						pixel_t* pixel = pixel_at(&img, (x + 2) * size_img_coef + xi, (y + 2) * size_img_coef + yi);
						pixel->red = 250;
						pixel->green = 250;
						pixel->blue = 250;
					}
				}
			}
		}
	}

	char* filepath = malloc(sizeof(char) * (strlen("output/.png") + strlen(text)));
	strcpy(filepath, "output/");
	strcat(filepath, text);
	strcat(filepath, ".png");

	if (save_png_to_file(&img, filepath)) {
		fprintf(stderr, "Error writing file.\n");
		exit(EXIT_FAILURE);
    }

    free (img.pixels);


	qrcodeFile = fopen(filepath, "r");
	free(filepath);
	return qrcodeFile;
}

/**
 * Create name_of_franchisee.txt with infomation of the franchisee
 */
void create_file() {
	unsigned int i;
	char* str;
	char* file_path = (char*)malloc(sizeof(char) * (strlen(gtk_entry_get_text(GTK_ENTRY(lastname_input))) + strlen("output/.txt")));
	strcpy(file_path, "output/");
	strcat(file_path, (char*)gtk_entry_get_text(GTK_ENTRY(lastname_input)));
	strcat(file_path, ".txt");
	
	// Avec file vaiable selon le nom du franchsee
	FILE* file = fopen(file_path, "r+");
	if (file == NULL) {
		file = fopen(file_path, "wb");
		GtkWidget* inputs[5] = {firstname_input, lastname_input, siret_input, email_input, enterprise_name_input};
		for (i = 0; i < 5; i += 1) {
			str = (char*)malloc((strlen(gtk_entry_get_text(GTK_ENTRY(inputs[i]))) + 1) * sizeof(char));
			strcpy(str, (char*)gtk_entry_get_text(GTK_ENTRY(inputs[i])));
			fprintf(file, "%s\n", str);
			free(str);
		}
		fclose(file);
		free(file_path);
	} else {
		fclose(file);
		fprintf(stderr, "Erreur le franchisee existe déjà\n");
		exit(EXIT_FAILURE);
	}
}

void sha1_file(FILE* file, char* hash) {
	char *buffer = 0;
    size_t length;

    if (file) {
        fseek(file, 0, SEEK_END);
        length = ftell(file);
        fseek(file, 0, SEEK_SET);
        buffer = malloc(length);
        if (buffer) {
            fread(buffer, sizeof(char), length, file);
        }
    }

    if (buffer) {
        unsigned char tmphash[SHA_DIGEST_LENGTH*2];

        SHA1(buffer, length, tmphash);
        for (size_t i = 0; i < SHA_DIGEST_LENGTH; i++) {
            sprintf((char *)&(hash[i * 2]), "%02x", tmphash[i]);
        }
		free(buffer);
    } else {
		fprintf(stderr, "Erreur malloc buffer");
		exit(EXIT_FAILURE);
	}
}


static int save_png_to_file(bitmap_t *bitmap, const char *path) {
    FILE * fp;
    png_structp png_ptr = NULL;
    png_infop info_ptr = NULL;
    size_t x, y;
    png_byte ** row_pointers = NULL;
    /* "status" contains the return value of this function. At first
       it is set to a value which means 'failure'. When the routine
       has finished its work, it is set to a value which means
       'success'. */
    int status = -1;
    /* The following number is set by trial and error only. I cannot
       see where it it is documented in the libpng manual.
    */
    int pixel_size = 3;
    int depth = 8;
    
    fp = fopen (path, "wb");
    if (! fp) {
        goto fopen_failed;
    }

    png_ptr = png_create_write_struct (PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (png_ptr == NULL) {
        goto png_create_write_struct_failed;
    }
    
    info_ptr = png_create_info_struct (png_ptr);
    if (info_ptr == NULL) {
        goto png_create_info_struct_failed;
    }
    
    /* Set up error handling. */

    if (setjmp (png_jmpbuf (png_ptr))) {
        goto png_failure;
    }
    
    /* Set image attributes. */

    png_set_IHDR (png_ptr,
                  info_ptr,
                  bitmap->width,
                  bitmap->height,
                  depth,
                  PNG_COLOR_TYPE_RGB,
                  PNG_INTERLACE_NONE,
                  PNG_COMPRESSION_TYPE_DEFAULT,
                  PNG_FILTER_TYPE_DEFAULT);
    
    /* Initialize rows of PNG. */

    row_pointers = png_malloc (png_ptr, bitmap->height * sizeof (png_byte *));
    for (y = 0; y < bitmap->height; y++) {
        png_byte *row = 
            png_malloc (png_ptr, sizeof (uint8_t) * bitmap->width * pixel_size);
        row_pointers[y] = row;
        for (x = 0; x < bitmap->width; x++) {
            pixel_t * pixel = pixel_at (bitmap, x, y);
            *row++ = pixel->red;
            *row++ = pixel->green;
            *row++ = pixel->blue;
        }
    }
    
    /* Write the image data to "fp". */

    png_init_io (png_ptr, fp);
    png_set_rows (png_ptr, info_ptr, row_pointers);
    png_write_png (png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, NULL);

    /* The routine has successfully written the file, so we set
       "status" to a value which indicates success. */

    status = 0;
    
    for (y = 0; y < bitmap->height; y++) {
        png_free (png_ptr, row_pointers[y]);
    }
    png_free (png_ptr, row_pointers);
    
 png_failure:
 png_create_info_struct_failed:
    png_destroy_write_struct (&png_ptr, &info_ptr);
 png_create_write_struct_failed:
    fclose (fp);
 fopen_failed:
    return status;
}

static pixel_t * pixel_at (bitmap_t * bitmap, int x, int y) {
    return bitmap->pixels + bitmap->width * y + x;
}
