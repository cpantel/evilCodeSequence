/*
  This program implements
    RTC to UART
      copies RTC data to UART
    PMOD0 to PMOD1
      copies PMOD0 to PMOD1
    SERVO
      uses the buttons to set the servo position
      uses ARDUINO[] as output
    KITT
      follows servo position as speed
      uses ARDUINO[] as output
    SEQUENCER
      follows servo position as speed
      uses ARTUINO[] as output 

*/

#include <stdint.h>
#include "../memmap.h"
#include "../uart.h"
#include "../delay.h"


int main() {
    // UART
    uart_init();
    uart_puts("Full Demo starting\r\n");

    // RTC to UART
    //     char rtcMsg[] = "RTC: ..:.. \r\n\0";
/*
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wall -Wextra -pedantic -DFREQ=36000000 -Os -ffreestanding -nostartfiles -g -Iprograms/rtc2uart -Wl,-TBUILD/progmem.lds -o BUILD/progmem programs/rtc2uart/main.o start.o
/usr/local/lib/gcc/riscv64-unknown-elf/11.1.0/../../../../riscv64-unknown-elf/bin/ld: /usr/local/lib/gcc/riscv64-unknown-elf/11.1.0/../../../../riscv64-unknown-elf/lib/libc.a(lib_a-memcpy.o): ABI is incompatible with that of the selected emulation:
  target emulation `elf64-littleriscv' does not match `elf32-littleriscv'
*/

    char rtcMsg[13];
    rtcMsg[0]='R';
    rtcMsg[1]='T';
    rtcMsg[2]='C';
    rtcMsg[3]=':';
    rtcMsg[4]=' ';
    rtcMsg[5]='.';
    rtcMsg[6]='.';
    rtcMsg[7]=':';
    rtcMsg[8]='.';
    rtcMsg[9]='.';
    rtcMsg[10]=13;
    rtcMsg[11]=10;
    rtcMsg[12]='\0';
    uint32_t rtc = RTC;

    // SERVO
    #define SERVO_MAX_POS 10
    //signed char servo_position = 0;

    // FSM 
    //char state = 'a';

    // BUTTONS
    char buttons;

    // KITT
    #define KITT_MAX_SPEED 16
    int kitt_delay = 1;

    for (;;) {
        // RTC to UART
        rtc = RTC;
        rtcMsg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
        rtcMsg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
        rtcMsg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
        rtcMsg[9] = ( rtc & 0xf ) + '0';
        uart_puts(rtcMsg);

        // BUTTONS
        buttons = ~BUTTONS;

/*
        // PMOD0 to PMOD1  
        PMOD0 = PMOD1;


        // SERVO
        SERVO = servo_position;
        if ((buttons & 8 ) >> 3 ) {
            servo_position = SERVO_MAX_POS;
        } else if (buttons & 1 ) {
            servo_position = 0;
        } else if ((buttons & 2 ) >> 1 ) {
            --servo_position;
            if (servo_position < 0 ) servo_position = 0;
        } else if ((buttons & 4 ) >> 2 ) {
            ++servo_position;
            if (servo_position > SERVO_MAX_POS) servo_position = SERVO_MAX_POS;
        }
*/
        // KITT
        
        KITT = kitt_delay;
        if ((buttons & 8 ) >> 3 ) {
            kitt_delay = KITT_MAX_SPEED;
        } else if (buttons & 1 ) {
            kitt_delay = 1;
        } else if ((buttons & 2 ) >> 1 ) {
            --kitt_delay;
            if (kitt_delay < 1 ) kitt_delay = 1;
        } else if ((buttons & 4 ) >> 2 ) {
            ++kitt_delay;
            if (kitt_delay > KITT_MAX_SPEED) kitt_delay = KITT_MAX_SPEED;
        }
        // SEQUENCER
        // sequencer speed = position
        // if position == SERVO_MAX_POS
        //    change pattern

        delay();
    }

}
