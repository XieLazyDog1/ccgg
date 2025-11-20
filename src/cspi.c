#include "cspi.h"


void read_cspi_data(uint32_t* buffer, uint16_t num_i32){

    uint32_t* cspi_ptr = (uint32_t*)CPLD_CSPI_ADDRESS;
    for (uint32_t i = 0; i < num_i32; i++) {
        buffer[i] = cspi_ptr[i];
    }  
    // buffer[0] = cspi_ptr[0];
    // // buffer[0] = cspi_ptr[0];
    // buffer[1] = cspi_ptr[1]; 
    // buffer[2] = cspi_ptr[2];
    // // buffer[0] = cspi_ptr[0];
    // buffer[3] = cspi_ptr[3];  
    // buffer[3] = cspi_ptr[4];  
    // buffer[3] = cspi_ptr[5];

    // volatile uint16_t* cspi_ptr = (uint16_t*)CPLD_CSPI_ADDRESS;
    // uint16_t* buf_ptr = (uint16_t*)buffer;
    // for (uint32_t i = 0; i < num_i32 * 2; i++) {
    //     buf_ptr[i] = cspi_ptr[i];
    // }

    // volatile uint8_t* cspi_ptr = (uint8_t*)CPLD_CSPI_ADDRESS;
    // uint8_t* buf_ptr = (uint8_t*)buffer;
    // for (uint32_t i = 0; i < 8; i++) {
    //     buf_ptr[i] = cspi_ptr[i];
    // }

}