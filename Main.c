#include <LPC214x.h>
#include "font.h"
#include "Microvga.h"
#include "IRQhelper.h"
#define FRAME_WIDTH 80
#define FRAME_LENGTH 60
#define FRAME_SIZE FRAME_LENGTH*FRAME_WIDTH
#define MESSAGE_LENGTH 7

unsigned char* framecreator(void){
	unsigned char message[MESSAGE_LENGTH] = {'A','N','U','B','H','A','V'};
	static unsigned char frame[FRAME_SIZE];
	
	for(int rows=0;rows<FRAME_LENGTH;rows++) {
		for(int cols=0;cols<FRAME_WIDTH;cols++) {
			if(cols>MESSAGE_LENGTH){
				frame[rows+cols]=0x00;
			} else {
				frame[rows+cols]=font[message[cols]][rows%8];
			}
		}
	}
	/**
	for(int j=0;j<80;j++)
		for(int i=0;i<60;i++)
				if(j>MESSAGE_LENGTH)
					frame[i+j]=0x00;
				else
					frame[i+j]=font[message[j]][i%8];
	**/
	return frame;
}

int main(void){
	EnableInterrupts();
	unsigned char* frame = framecreator();
	initVGA();
	while(1) {
		display(&frame[0]);
	}
}
