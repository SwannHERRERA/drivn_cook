CC=gcc-8
CFLAGS= -Wall -Wextra -Werror
dev: build start
# main.c
build:
	$(CC) `pkg-config --cflags gtk+-3.0` $(CFLAGS) -o app main.c `pkg-config --libs gtk+-3.0` -export-dynamic
start:
	./app
clean:
	rm app