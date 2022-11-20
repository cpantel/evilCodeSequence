/*
  This program covers:
     UART read and write
     RTC
     LEDS
     BUTTONS
     delay()
     SERVO (via ARDUINO[31])
     PWM (via ARDUINO[23])
     KITT (via ARDUINO[20:16)

  This program will cover:
     SEQUENCER (via ARDUINO[7:0])
     PMOD in
     PMOD out
*/

#include <stdint.h>
#include "../memmap.h"
#include "../uart.h"
#include "../delay.h"

void uart_cls() {
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

void displayRTC() {
  uart_puts("\r\n");
  char msg[] = "   RTC: ..:.. \r\0";
  while (0 == uart_getc()) {
    uint32_t rtc = RTC;
    msg[8] = ((rtc & 0xf000 ) >> 12 ) + '0';
    msg[9] = ((rtc & 0xf00 ) >> 8 ) + '0';
    msg[11] = ((rtc & 0xf0 ) >> 4 ) + '0';
    msg[12] = ( rtc & 0xf ) + '0';
    uart_puts(msg);
    delay();
  }    
  uart_puts("\r\n\r\n");
}

#define PWM_MAX 255 
unsigned char pwm = 0;

void menu_pwm() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> Pwm highest\r\n");
	pwm = PWM_MAX;
      break;
      case '2':
	if (pwm < PWM_MAX) {
          ++pwm;
          uart_puts(">>> Pwm higher\r\n");
        }
      break;
      case '3':
        uart_puts(">>> Pwm 3/4\r\n");
	pwm = PWM_MAX / 4 * 3;
      break;
      case '4':
        uart_puts(">>> Pwm 1/2\r\n");
	pwm = PWM_MAX / 2;
      break;
      case '5':
        uart_puts(">>> Pwm 1/4\r\n");
	pwm = PWM_MAX / 4;
      break;
      case '6':
	if (pwm > 0) {
          --pwm;
          uart_puts(">>> Pwm lower\r\n");
        }
      break;
      case '7':
        uart_puts(">>> Pwm lowest\r\n");
	pwm = 0;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("PWM Menu\r\n   (1) Highest\r\n   (2) Higher\r\n   (3) 3/4\r\b   (4) 1/2\r\n   (5) 1/4\r\n   (6) Lower\r\n   (7) Lowest\r\n   (0) Exit\r\n\0");
      break;
    }
    PWM = pwm;
    cmd = uart_getc();
  }
}


#define SERVO_MAX_POS 10
signed char servo_position = 0;

void menu_servo() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> SERVO full left\r\n");
	servo_position = 0;
      break;
      case '2':
	if (servo_position > 0) {
          --servo_position;
          uart_puts(">>> SERVO move left\r\n");
        }
      break;
      case '3':
	if (servo_position < SERVO_MAX_POS) {
          ++servo_position;
          uart_puts(">>> SERVO move right\r\n");
        }
      break;
      case '4':
        uart_puts(">>> SERVO full right\r\n");
	servo_position = SERVO_MAX_POS;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("SERVO Menu\r\n   (1) Full left\r\n   (2) Go left\r\n   (3) Go right\r\n   (4) Full right\r\n   (0) Exit\r\n\0");
      break;
    }
    SERVO = servo_position;
    cmd = uart_getc();
  }
} 

#define KITT_MAX_SPEED  FREQ/8
#define KITT_MIN_SPEED  FREQ/2
#define KITT_DELTA      FREQ/20
unsigned int kitt_speed = (KITT_MAX_SPEED + KITT_MIN_SPEED) / 2;


void menu_kitt() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        uart_puts(">>> KITT fastest\r\n");
	kitt_speed = KITT_MAX_SPEED;
      break;
      case '2':
        if (kitt_speed > KITT_MAX_SPEED) {
          uart_puts(">>> KITT faster\r\n");
          kitt_speed -= KITT_DELTA;
        }

      break;
      case '3':
        if (kitt_speed < KITT_MIN_SPEED) {
          kitt_speed += KITT_DELTA;
          uart_puts(">>> KITT slower\r\n");
        }
      break;
      case '4':
        uart_puts(">>> KITT slowest\r\n");
	kitt_speed = KITT_MIN_SPEED;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("KITT Menu\r\n   (1) Fastest\r\n   (2) Faster\r\n   (3) Slower\r\n   (4) Slowest\r\n   (0) Exit\r\n\0");
      break;
    }
    KITT = kitt_speed;
    cmd = uart_getc();
  }
} 

#define SEQUENCER_MAX_SPEED  FREQ/4
#define SEQUENCER_MIN_SPEED  FREQ
#define SEQUENCER_MAX_SIZE   30
unsigned int sequencer_speed = SEQUENCER_MIN_SPEED;

unsigned char sequencer_mem[SEQUENCER_MAX_SIZE] = {
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x40, 0x20,
    0x10, 0x08, 0x04, 0x02, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20,
    0x40, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0xff
};


/*
unsigned char sequencer_mem[SEQUENCER_MAX_SIZE] = {
    0x18, 0x24, 0x42, 0x81, 0xC3, 0x66, 0x3c, 0xE7, 0xff, 0xf7,
    0xe7, 0xc7, 0xc3, 0x83, 0x81, 0x01, 0x03, 0x07, 0x0f, 0x1f,
    0x3f, 0x7f, 0xf3, 0xfc, 0xf8, 0xf0, 0xe0, 0x70, 0x38, 0x1c
};
*/

uint32_t sequencer_size = SEQUENCER_MAX_SIZE;

#define SEQUENCER_START_STOP_PORT 31
#define SEQUENCER_SPEED_PORT      30


void menu_sequencer() {
  char cmd = ' ';
  while (cmd != '0') {
    switch (cmd) {
      case '1':
        SEQUENCER[SEQUENCER_START_STOP_PORT] = 0x11111111;
        uart_puts(">>> SEQUENCER start\r\n");
      break;
      case '2':
        SEQUENCER[SEQUENCER_START_STOP_PORT ] = 0x00000000;
        uart_puts(">>> SEQUENCER stop\r\n");
      break;
      case '3':
        uart_puts(">>> SEQUENCER high speed\r\n");
        SEQUENCER[SEQUENCER_SPEED_PORT] = SEQUENCER_MAX_SPEED;
      break;
      case '4':
        uart_puts(">>> SEQUENCER low speed\r\n");
        SEQUENCER[SEQUENCER_SPEED_PORT] = SEQUENCER_MIN_SPEED;
      break;
      case '5':
        uart_puts(">>> SEQUENCER clear\r\n");
       	sequencer_size = 0;
      break;
      case '6':
        uart_puts(">>> SEQUENCER read next step\r\n");
        uint32_t pattern = sequencer_size ;
        SEQUENCER[sequencer_size] = pattern;
       	++sequencer_size;
      break;
      case '7':
        uart_puts(">>> SEQUENCER load default software\r\n");
        for (sequencer_size = 0; sequencer_size < SEQUENCER_MAX_SIZE -1 ; ++sequencer_size) {
          SEQUENCER[sequencer_size] = sequencer_mem[sequencer_size];
        }
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("SEQUENCER Menu\r\n   (1) Start\r\n   (2) Stop\r\n   (3) High speed\r\n   (4) Low speed\r\n   (5) Clear\r\n   (6) Read next step\r\n   (7) Preload\r\n   (0) Exit\r\n\0");
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
  char menu[]="Main Menu\r\n   (1) LEDS\r\n   (2) PWM\r\n   (3) SERVO\r\n   (4) KITT\r\n   (5) SEQUENCER\r\n   (6) Print RTC\r\n   (7) Display RTC\r\n\0";

  char cmd = ' ';
  uart_init();
  uart_cls();
  uart_puts("Full Demo starting\r\n");
  while (1) {
    if (cmd != 0) uart_puts(menu);
    cmd = uart_getc();
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
      break;
      case '7':
	displayRTC();
      break;
      default:
      break;
    }
  }
}
