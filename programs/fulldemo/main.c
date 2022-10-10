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
     SEQUENCER (via ARDUINO CONN)
     PMOD in
     PMOD out
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
        uart_puts(">>> Pwm higher\r\n");
	if (pwm < PWM_MAX) ++pwm;
      break;
      case '3':
        uart_puts(">>> Pwm lower\r\n");
	if (pwm > 0) --pwm;
      break;
      case '4':
        uart_puts(">>> Pwm lowest\r\n");
	pwm = 0;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("PWM Menu\r\n   (1) Highest\r\n   (2) Higher\r\n   (3) Lower\r\n   (4) Lowest\r\n   (0) Exit\r\n\0");
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
        uart_puts(">>> Servo full left\r\n");
	servo_position = 0;
      break;
      case '2':
        uart_puts(">>> Servo move left\r\n");
	if (servo_position > 0) --servo_position;
      break;
      case '3':
        uart_puts(">>> Servo move right\r\n");
	if (servo_position < SERVO_MAX_POS) ++servo_position;
      break;
      case '4':
        uart_puts(">>> Servo full right\r\n");
	servo_position = SERVO_MAX_POS;
      break;
      case '\n':
      case 0:
      break;
      default:
        uart_puts("Servo Menu\r\n   (1) Full left\r\n   (2) Go left\r\n   (3) Go right\r\n   (4) Full right\r\n   (0) Exit\r\n\0");
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
  char menu[]="Main Menu\r\n   (1) LEDS\r\n   (2) PWM\r\n   (3) Servo\r\n   (4) KITT\r\n   (5) Sequencer\r\n   (6) Print RTC\r\n   (7) Display RTC\r\n\0";

  uart_init();
  cls();
  uart_puts("Full Demo starting\r\n");
  char cmd = ' ';
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

/*
    uint32_t rtc = RTC;

    // SERVO
    #define SERVO_MAX_POS 10
    //signed char servo_position = 0;

    // FSM 
    //char state = 'a';

    // BUTTONS
    char buttons;

    // KITT
    #define KITT_MAX_SPEED FREQ * 4
    #define KITT_MIN_SPEED FREQ / 4
    int kitt_delay = FREQ;

    for (;;) {
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

/*
        // KITT
        
        KITT = kitt_delay;
        if ((buttons & 8 ) >> 3 ) {
            kitt_delay = KITT_MAX_SPEED;
        } else if (buttons & 1 ) {
            kitt_delay = KITT_MIN_SPEED;
        } else if ((buttons & 2 ) >> 1 ) {
            kitt_delay /= 2;
            if (kitt_delay < KITT_MAX_SPEED ) kitt_delay = KITT_MAX_SPEED;
        } else if ((buttons & 4 ) >> 2 ) {
            kitt_delay *= 2;
            if (kitt_delay > KITT_MAX_SPEED) kitt_delay = KITT_MAX_SPEED;
        }
        // SEQUENCER
        // sequencer speed = position
        // if position == SERVO_MAX_POS
        //    change pattern

    }
*/

