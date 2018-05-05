#ifndef MICROVGA_H
#define MICROVGA_H

/**
* function: setupHsync
* arguments: void
* desc: setup HSYNC on P0.22 (PWM5) and ISR for VSYNC on P0.22
* return: void
*/
//void setupHsync(void);
/**
* function: display
* arguments: pointer to framedata 8bit by 8bit frame data
* desc: generates RGB from framedata
* return: void
*/
void display(unsigned char[]);
/**
* function: init
* arguments: void
* desc: initializes vsync counter, and sets direction on port pins
* return: void
*/
void initVGA(void);

#endif /* MICROVGA_H */
