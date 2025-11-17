#include "step_motor_pwm.h"


void write_step_motor_pwm(uint16_t * pwm_data, uint16_t length, uint16_t mode){
    uint16_t* pwm_ptr = (uint16_t *)(0x60000000);
      for(int mi=0;mi<length;mi++){
        *pwm_ptr = pwm_data[mi];
        pwm_ptr++;    
    }
    pwm_ptr = (uint16_t *)(0x60000000 + 0xff);
    *pwm_ptr = mode;
}


