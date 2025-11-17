
#include "board.h"
#include "serial_input.h"
#include "step_motor_pwm.h"

#include "chained_motors.h"


uint16_t pwms [48];
uint8_t lims[6];



int main(void) {

    board_init();
    
    pwms[0] = 0x0000;
    pwms[1] = 0x0000;
    pwms[2] = 0x0000;
    pwms[3] = 0x0000;
    pwms[4] = 0x0000;
    pwms[5] = 0x0000;
    write_step_motor_pwm(pwms, 48, 0x0000);

    initCCMotors(12800, CC_MODE_ORDER2, 100.0f, write_step_motor_pwm, read_serial_input);
    zeroAllMotors();

    while (1) {

        updateCCMotors();

        // 延时一段时间
        for(int i = 0; i< 10000; i++){            
        }
     
    }
    return 0;
}





