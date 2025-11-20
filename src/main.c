
#include "board.h"
#include "serial_input.h"
#include "step_motor_pwm.h"

#include "chained_motors.h"
#include "cspi.h"

int32_t targetPositions[MOTOR_NUM];

uint32_t cspi_data[MOTOR_NUM / 4 + 1];

CCMotorParameters motorParams = {
    .ctrFlags = CC_FLAG_LOOP,
    .servoMode = CC_MODE_ORDER2,
    .subEDegBits = 7,
    .staticCurrent = 12800,
    .dynamicCurrent = 25800,
    .dynamicCurrentK = 10,
    .maxVel = 200,
    .maxAcc = 50000,
    .totalPulse = 596440,
    .velocityK = 0.0f,
    .accK = 0.0f};

int32_t pht = 0;

volatile int32_t ms_cnt = 0;
volatile uint8_t ms_flag = 0;

void MTIMER_isr(void)
{
    INT_SetMtime(0);
    updateCCMotors();

    if (ms_cnt >= 10)
    {
        ms_cnt = 0;
        ms_flag = 1;
    }
    else
    {
        ms_cnt++;
    }
}

void exti_isr(void)
{
    read_cspi_data(cspi_data, MOTOR_NUM / 4 + 1);

    uint8_t *cspi_data_ptr = (uint8_t *)cspi_data;
    if (cspi_data_ptr[0] == 1)
    {
        cspi_data_ptr += 4;
        for (int i = 0; i < MOTOR_NUM; i++)
        {
            targetPositions[i] = (cspi_data_ptr[i] * 256);
        }
        setCCTargetPosArray(targetPositions, MOTOR_NUM, 1);
    }
    GPIO_ClearInt(EXTI_GPIO, EXTI_GPIO_BITS);
}

void initMTimerInterrupt(int32_t us)
{
    clint_isr[IRQ_M_TIMER] = MTIMER_isr;
    INT_SetMtime(0);
    INT_SetMtimeCmp(SYS_GetSysClkFreq() / 1000000 * us - 5);
    INT_EnableIntTimer();
}

void initEXTI(void)
{
    SYS_EnableAPBClock(EXTI_GPIO_MASK);

    GPIO_SetInput(EXTI_GPIO, EXTI_GPIO_BITS);
    GPIO_EnableInt(EXTI_GPIO, EXTI_GPIO_BITS);
    GPIO_IntConfig(EXTI_GPIO, EXTI_GPIO_BITS, GPIO_INTMODE_RISEEDGE);

    plic_isr[GPIO6_IRQn] = exti_isr;

    INT_SetIRQThreshold(1);
    INT_EnableIRQ(GPIO6_IRQn, PLIC_MAX_PRIORITY);
}

int main(void)
{

    board_init();

    initCCMotors(&motorParams, write_step_motor_pwm, read_serial_input);
    zeroAllMotors();

    initMTimerInterrupt(300); // 200us定时器中断
    initEXTI();
    targetPositions[0] = 10222;
    setCCTargetPosArray(targetPositions, MOTOR_NUM, 1);
    while (1)
    {

        if (ms_flag == 1)
        {
            ms_flag = 0;
        }
    }
    return 0;
}
