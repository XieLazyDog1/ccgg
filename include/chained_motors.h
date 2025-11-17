#include "board.h"


#define MOTOR_NUM 48

// 限位状态所占字节总数
#define LIM_BYTE_NUM ((MOTOR_NUM + 7) / 8)

#define CC_MODE_IDLE 0        // 无控制
#define CC_MODE_CONST_OMG  1  // 恒速位置控制模式
#define CC_MODE_ORDER2     2  // 二阶运动系统
#define CC_MODE_OMG        3  // 纯角速度控制


// 用于和FPGA交互的函数，输出PWM占空比
typedef void (*motorPWMFunc)(uint16_t* wr_ptr, uint16_t size, uint16_t mode);
// 读取限位输入数据
typedef void (*readInputFunc)(uint8_t* buffer, uint16_t bytes);

typedef struct {

}MotorParameters;

// 初始化电机
void initCCMotors(uint16_t force, uint8_t mode, float targetOmega, motorPWMFunc pwmFunc, readInputFunc inputFunc);

// 更新电机状态
void updateCCMotors(void);

// // 写入波形周期 （根据频率计算出周期）
// void writeWavePeriod(void);

// 将所有电机归零到限位位置
void zeroAllMotors(void);

// 将指定电机归零到限位位置
void zeroMotor(uint16_t i);

// 初始化零点偏移值
void initZeroOffset(int32_t* zeroOffsetList);

void readLimBytes(void);


