#include "board.h"


#define MOTOR_NUM 48

// 限位状态所占字节总数
#define LIM_BYTE_NUM ((MOTOR_NUM + 7) / 8)

#define CC_MODE_IDLE 0        // 无控制
#define CC_MODE_CONST_OMG  1  // 恒速位置控制模式
#define CC_MODE_ORDER2     2  // 二阶运动系统
#define CC_MODE_OMG        3  // 纯角速度控制


// 0: loop				周期循环
// 1: reverse			反转
// 2: singleDirection	单向旋转
// 7: aabb				电机线序
#define CC_FLAG_LOOP             0x01
#define CC_FLAG_REVERSE          0x02
#define CC_FLAG_SINGLE_DIRECTION 0x04
#define CC_FLAG_AABB             0x80


// 用于和FPGA交互的函数，输出PWM占空比
typedef void (*motorPWMFunc)(uint16_t* wr_ptr, uint16_t size, uint16_t mode);
// 读取限位输入数据
typedef void (*readInputFunc)(uint8_t* buffer, uint16_t bytes);

typedef struct {
uint8_t ctrFlags;           // 控制位  CC_FLAG 
uint8_t servoMode;					// 伺服模式  CC_MODE
uint8_t subEDegBits;				// 电角度以下的位数（精细度）
uint16_t staticCurrent;			// 静态电流
uint16_t dynamicCurrent;		// 动态电流
uint16_t dynamicCurrentK;			// 动态电流系数
uint16_t maxVel;					// 最大速度
uint16_t maxAcc;				// 最大加速度
uint32_t totalPulse;			// 总行程脉冲数

float velocityK; // 电机速度系数 为0时使用默认值
float accK;		   // 电机加速度系数 为0时使用默认值
}CCMotorParameters;


// 初始化电机
void initCCMotors(CCMotorParameters *parameters, motorPWMFunc pwmFunc, readInputFunc inputFunc);

// 设置电机参数
void setCCParameters(CCMotorParameters *parameters);

// 写入电机目标位置数组
void setCCTargetPosArray(int32_t* posList, uint16_t length, uint8_t bitsMode);



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




