/*
  This program covers:
     UART read and write
     RTC
     LEDS
     BUTTONS
 
  This program will cover:
     KITT (via ARDUINO CONN)
     SEQUENCER (via ARDUINO CONN)
     PMOD in
     PMOD out
     PWM (via ARDUINO CONN)
*/

#include <stdint.h>
#include "../memmap.h"
#include "../uart.h"
#include "../delay.h"
void cls() {
  for (int i=0; i< 25; ++i) {
    uart_puts("\r\n\0");
  }
}

void printRTC() {
  uint32_t rtc = RTC;
  char msg[] = "RTC: ..:.. \r\n\0";
  msg[5] = ((rtc & 0xf000 ) >> 12 ) + '0';
  msg[6] = ((rtc & 0xf00 ) >> 8 ) + '0';
  msg[8] = ((rtc & 0xf0 ) >> 4 ) + '0';
  msg[9] = ( rtc & 0xf ) + '0';
  uart_puts(msg);
}

void menu_pwm() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> Pwm highest\r\n");
      break;
      case '2':
        uart_puts(">>> Pwm higher\r\n");
      break;
      case '3':
        uart_puts(">>> Pwm lower\r\n");
      break;
      case '4':
        uart_puts(">>> Pwm lowest\r\n");
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("PWM Menu\r\n   (1) Highest\r\n   (2) Higher\r\n   (3) Lower\r\n   (4) Lowest\r\n   (0) Exit\r\n\0");
      break;
    }
    cmd = uart_getc();
  }
}

void menu_servo() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> Servo full left\r\n");
      break;
      case '2':
        uart_puts(">>> Servo move left\r\n");
      break;
      case '3':
        uart_puts(">>> Servo move right\r\n");
      break;
      case '4':
        uart_puts(">>> Servo full right\r\n");
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("Servo Menu\r\n   (1) Full left\r\n   (2) Go left\r\n   (3) Go right\r\n   (4) Full right\r\n   (0) Exit\r\n\0");
      break;
    }
    cmd = uart_getc();
  }
} 


void menu_kitt() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> KITT fastest\r\n");
      break;
      case '2':
        uart_puts(">>> KITT fast\r\n");
      break;
      case '3':
        uart_puts(">>> KITT slower\r\n");
      break;
      case '4':
        uart_puts(">>> KITT slowest\r\n");
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("KITT Menu\r\n   (1) Fastest\r\n   (2) Faster\r\n   (3) Slower\r\n   (4) Slowest\r\n   (0) Exit\r\n\0");
      break;
    }
    cmd = uart_getc();
  }
} 
 
void menu_sequencer() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> Sequencer start\r\n");
      break;
      case '2':
        uart_puts(">>> Sequencer stop\r\n");
      break;
      case '3':
        uart_puts(">>> Sequencer faster\r\n");
      break;
      case '4':
        uart_puts(">>> Sequencer lower\r\n");
      break;
      case '5':
        uart_puts(">>> Sequencer clear\r\n");
      break;
       case '6':
        uart_puts(">>> Sequencer read next step\r\n");
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("Sequencer Menu\r\n   (1) Start\r\n   (2) Faster\r\n   (3) Slower\r\n   (4) Stop\r\n   (5) Clear\r\n   (6) Read next step\r\n   (0) Exit\r\n\0");
      break;
    }
    cmd = uart_getc();
  }
} 


void menu_leds() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> LEDS toggle led 1\r\n");
        LEDS = LEDS ^ 1;
      break;
      case '2':
        uart_puts(">>> LEDS toggle led 2\r\n");
        LEDS = LEDS ^ 2;
      break;
      case '3':
        uart_puts(">>> LEDS toggle led 3\r\n");
        LEDS = LEDS ^ 4;
      break;
      case '4':
        uart_puts(">>> LEDS toggle led 4\r\n");
        LEDS = LEDS ^ 8;
      break;
      case '5':
        uart_puts(">>> LEDS toggle all\r\n");
        LEDS = ~LEDS ;
      break;
      case '6':
        uart_puts(">>> LEDS all on\r\n");
        LEDS = 0xF;
      break;
      case '7':
        uart_puts(">>> LEDS all off\r\n");
        LEDS = 0;
      break;
      case '8':
        uart_puts(">>> LEDS copied from BUTTONS\r\n");
        LEDS = ~BUTTONS;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("LEDS and BUTTONS Menu\r\n   (1) Toggle led1\r\n   (2) Toggle led2\r\n   (3) Toggle led3\r\n   (4) Toggle led4\r\n   (5) Toggle all\r\n   (6) All on\r\n   (7) All off\r\n   (8) Copy BUTTONS to LEDS\r\n   (0) Exit\r\n\0");
      break;
    }
    cmd = uart_getc();
  }
 
}


int main() {
  char menu[]="Main Menu\r\n   (1) LEDS\r\n   (2) PWM\r\n   (3) Servo\r\n   (4) KITT\r\n   (5) Sequencer\r\n   (6) Print RTC\r\n\0";

  delay();
  delay();
  delay();
  delay();
  delay();

  uart_init();
  cls();
  uart_puts("Full Demo starting (only l+t+a)\r\n");
  uart_puts(menu);
  while (1) {
    char cmd = uart_getc();
    switch (cmd) {
      case '1':
        menu_leds();
      break;
      case '2':
        menu_pwm();
      break;
      case '3':
        menu_servo();
      break;
      case '4':
        menu_kitt();
      break;
      case '5':
        menu_sequencer();
      break;
      case '6':
        printRTC();
        uart_puts(menu);
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts(menu);
      break;
    }
  }
}
