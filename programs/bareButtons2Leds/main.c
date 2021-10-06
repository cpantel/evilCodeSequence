/*
  This program copies the buttons to the leds
*/

#include <stdint.h>
#include "../memmap.h"

int main() {
    for (;;) {
        LEDS = ~BUTTONS; 
    }
}
