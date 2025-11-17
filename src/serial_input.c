
#include "serial_input.h"

#define CPLD_SERIAL_INPUT_ADDRESS 0x60001000


void read_serial_input(uint8_t* buffer, uint32_t length){
    volatile uint8_t* serial_input_ptr = (uint8_t*)CPLD_SERIAL_INPUT_ADDRESS;
    for (uint32_t i = 0; i < length; i++) {
        buffer[i] = serial_input_ptr[i];
    }    
}