all: logitech

CFLAGS	= -Wall -g -O2 -Wno-unused-variable
LDFLAGS	= -lm -lrt -lpthread  -lwiringPi

logitech : logitech.h logitech.c
		$(CC) $(CFLAGS) -o logitech logitech.c $(LDFLAGS) 
clean:
	rm -f  *.o




