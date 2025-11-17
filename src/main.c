
#include "board.h"
#include "serial_input.h"
#include "step_motor_pwm.h"

#include "chained_motors.h"


int32_t targetPositions[48];

CCMotorParameters motorParams = {
    .ctrFlags = CC_FLAG_LOOP,
    .servoMode = CC_MODE_ORDER2,
    .subEDegBits = 7,
    .staticCurrent = 12800,
    .dynamicCurrent = 25800,
    .dynamicCurrentK = 10,
    .maxVel = 100,
    .maxAcc = 50000,
    .totalPulse = 589360,
    .velocityK = 0.0f,
    .accK = 0.0f
};

int32_t pht=0;


void MTIMER_isr(void)
{
  INT_SetMtime(0);
  updateCCMotors();
}

void initMTimerInterrupt(uint32_t us)
{
  clint_isr[IRQ_M_TIMER] = MTIMER_isr;
  INT_SetMtime(0);
  INT_SetMtimeCmp(SYS_GetSysClkFreq() / 1000000 * us - 5);
  INT_EnableIntTimer();
}


int main(void) {

    board_init();

    initCCMotors(&motorParams, write_step_motor_pwm, read_serial_input);
    zeroAllMotors();

    initMTimerInterrupt(200); // 1ms定时器中断

    while (1) {


        // 延时一段时间
        for(int i = 0; i< 10000; i++){            
        }

        for(int i=0;i<48;i++){
            //targetPositions[i] = (int32_t)( (sinf(ph + i * 0.1308997f) + 1.0f) * 128.0f ) + 127; // 0~256

            targetPositions[i] = pht %65536;

        }
        pht += 1;

        setCCTargetPosArray(targetPositions, 48, 1);
     
    }
    return 0;
}





