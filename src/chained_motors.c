#include "chained_motors.h"
#include "math.h"

uint8_t limBytes[LIM_BYTE_NUM];

uint16_t histLimSeq[MOTOR_NUM];

uint16_t sinWave[256] = {
	0x7f,
	0x37f,
	0x67f,
	0x97f,
	0xc7f,
	0x107e,
	0x137e,
	0x167e,
	0x197d,
	0x1c7c,
	0x1f7c,
	0x227b,
	0x257a,
	0x2879,
	0x2b78,
	0x2e77,
	0x3176,
	0x3474,
	0x3673,
	0x3972,
	0x3c70,
	0x3f6f,
	0x416d,
	0x446c,
	0x476a,
	0x4968,
	0x4c66,
	0x4e64,
	0x5162,
	0x5360,
	0x565e,
	0x585c,
	0x5a5a,
	0x5c58,
	0x5e56,
	0x6053,
	0x6251,
	0x644e,
	0x664c,
	0x6849,
	0x6a47,
	0x6c44,
	0x6d41,
	0x6f3f,
	0x703c,
	0x7239,
	0x7336,
	0x7434,
	0x7631,
	0x772e,
	0x782b,
	0x7928,
	0x7a25,
	0x7b22,
	0x7c1f,
	0x7c1c,
	0x7d19,
	0x7e16,
	0x7e13,
	0x7e10,
	0x7f0c,
	0x7f09,
	0x7f06,
	0x7f03,
	0x7f00,
	0x7f83,
	0x7f86,
	0x7f89,
	0x7f8c,
	0x7e90,
	0x7e93,
	0x7e96,
	0x7d99,
	0x7c9c,
	0x7c9f,
	0x7ba2,
	0x7aa5,
	0x79a8,
	0x78ab,
	0x77ae,
	0x76b1,
	0x74b4,
	0x73b6,
	0x72b9,
	0x70bc,
	0x6fbf,
	0x6dc1,
	0x6cc4,
	0x6ac7,
	0x68c9,
	0x66cc,
	0x64ce,
	0x62d1,
	0x60d3,
	0x5ed6,
	0x5cd8,
	0x5ada,
	0x58dc,
	0x56de,
	0x53e0,
	0x51e2,
	0x4ee4,
	0x4ce6,
	0x49e8,
	0x47ea,
	0x44ec,
	0x41ed,
	0x3fef,
	0x3cf0,
	0x39f2,
	0x36f3,
	0x34f4,
	0x31f6,
	0x2ef7,
	0x2bf8,
	0x28f9,
	0x25fa,
	0x22fb,
	0x1ffc,
	0x1cfc,
	0x19fd,
	0x16fe,
	0x13fe,
	0x10fe,
	0xcff,
	0x9ff,
	0x6ff,
	0x3ff,
	0xff,
	0x83ff,
	0x86ff,
	0x89ff,
	0x8cff,
	0x90fe,
	0x93fe,
	0x96fe,
	0x99fd,
	0x9cfc,
	0x9ffc,
	0xa2fb,
	0xa5fa,
	0xa8f9,
	0xabf8,
	0xaef7,
	0xb1f6,
	0xb4f4,
	0xb6f3,
	0xb9f2,
	0xbcf0,
	0xbfef,
	0xc1ed,
	0xc4ec,
	0xc7ea,
	0xc9e8,
	0xcce6,
	0xcee4,
	0xd1e2,
	0xd3e0,
	0xd6de,
	0xd8dc,
	0xdada,
	0xdcd8,
	0xded6,
	0xe0d3,
	0xe2d1,
	0xe4ce,
	0xe6cc,
	0xe8c9,
	0xeac7,
	0xecc4,
	0xedc1,
	0xefbf,
	0xf0bc,
	0xf2b9,
	0xf3b6,
	0xf4b4,
	0xf6b1,
	0xf7ae,
	0xf8ab,
	0xf9a8,
	0xfaa5,
	0xfba2,
	0xfc9f,
	0xfc9c,
	0xfd99,
	0xfe96,
	0xfe93,
	0xfe90,
	0xff8c,
	0xff89,
	0xff86,
	0xff83,
	0xff00,
	0xff03,
	0xff06,
	0xff09,
	0xff0c,
	0xfe10,
	0xfe13,
	0xfe16,
	0xfd19,
	0xfc1c,
	0xfc1f,
	0xfb22,
	0xfa25,
	0xf928,
	0xf82b,
	0xf72e,
	0xf631,
	0xf434,
	0xf336,
	0xf239,
	0xf03c,
	0xef3f,
	0xed41,
	0xec44,
	0xea47,
	0xe849,
	0xe64c,
	0xe44e,
	0xe251,
	0xe053,
	0xde56,
	0xdc58,
	0xda5a,
	0xd85c,
	0xd65e,
	0xd360,
	0xd162,
	0xce64,
	0xcc66,
	0xc968,
	0xc76a,
	0xc46c,
	0xc16d,
	0xbf6f,
	0xbc70,
	0xb972,
	0xb673,
	0xb474,
	0xb176,
	0xae77,
	0xab78,
	0xa879,
	0xa57a,
	0xa27b,
	0x9f7c,
	0x9c7c,
	0x997d,
	0x967e,
	0x937e,
	0x907e,
	0x8c7f,
	0x897f,
	0x867f,
	0x837f};

// uint8_t loop = 0;						// 是否循环
// uint8_t reverseDir = 0;					// 反向旋转
// uint8_t servoMode = 0;					// 伺服模式 0 严格的恒定加速度 1 渐变的加速度

// uint8_t oneDirectionOnly = 0;			// 只能以正向旋转 （配合 loop）

// uint16_t staticCurrent = 18000;			// 静态电流
// uint16_t dynamicCurrent = 18000;		// 动态电流
// uint16_t dynamicCurrentK = 50;			// 动态电流系数
// uint16_t maxVel = 40;					// 最大速度
// uint16_t maxAcc = 15000;				// 最大加速度

// uint32_t totalPulse = 9000000;			// 总行程脉冲数
// int32_t zeroPos = 0;					// 零点粗略位置
// uint32_t calibRange = 50000;			// 零点校准的范围

uint8_t subEDegBits = 7; // 电角度以下的位数（精细度）

float velocityK = 0.0005f; // 电机速度系数
float accK = 15.0f;		   // 电机加速度系数

// omg > 0 时，电机逆时针旋转

// 触发限位的时间点：   omgF > 0 && ((limBytes[limByteIndex] & limTestBit)) && !(histLimBytes[limByteIndex] & limTestBit)
//  omg>0 0->1
//  omg<0 1->0

// const float subResist = 1 - 0.0025f; // 0.0025f;
// const float resist = 0.0035f;		 // 0.0025f;

// 电机复位状态  0: 不在复位中 1：顺时针复位过程 2：逆时针复位过程
uint8_t ccZeroProgressState[MOTOR_NUM];

// 电机控制模式
uint8_t ccMode[MOTOR_NUM];

// 电机控制位
uint8_t ccFlags[MOTOR_NUM];

// 电机总行程脉冲数
uint32_t ccTotalPulse[MOTOR_NUM];

// 电机控制目标位置
int32_t ccTargetPos[MOTOR_NUM];

// 电机控制目标角速度
float ccTargetOmega[MOTOR_NUM];

// 电机最高速度
float ccMaxOmega[MOTOR_NUM];

// 最高加速度
float ccMaxAcc[MOTOR_NUM];

// 电机的电角度偏移
uint8_t ccEDegOffset[MOTOR_NUM];

// 电机复位所在的角度值
int32_t ccZeroPosOffset[MOTOR_NUM];

// 电机复位累积，用于自动停止复位
uint32_t ccZeroProgAccum[MOTOR_NUM];

// 电机角度
int32_t ccDegree[MOTOR_NUM];

// 位置维持力
uint16_t ccStaticForce[MOTOR_NUM];
// 运动时的基本力
uint16_t ccDynamicForce[MOTOR_NUM];
// 运动时基于速度的附加力的系数
uint16_t ccForceK[MOTOR_NUM];

// 电机转速浮点值
float ccOmegaF[MOTOR_NUM];
// 电机转速
int16_t ccOmega[MOTOR_NUM];
// 电机的角加速度
float ccAcc[MOTOR_NUM];

float ccAccR[MOTOR_NUM];

// 电机零点偏移值 以+- 50 x 256为

// 电机用于发声时的音频周期

uint16_t wavePeriod[MOTOR_NUM];
uint16_t pwmData[MOTOR_NUM];

motorPWMFunc gPwmFunc;
readInputFunc gInputFunc;

void initCCMotors(CCMotorParameters *parameters, motorPWMFunc pwmFunc, readInputFunc inputFunc)
{
	gPwmFunc = pwmFunc;
	gInputFunc = inputFunc;
	setCCParameters(parameters);
}

// 设置电机参数
void setCCParameters(CCMotorParameters *parameters)
{
	for (int i = 0; i < MOTOR_NUM; i++)
	{
		ccMode[i] = parameters->servoMode;
		ccFlags[i] = parameters->ctrFlags;

		ccStaticForce[i] = parameters->staticCurrent;
		ccDynamicForce[i] = parameters->dynamicCurrent;
		ccForceK[i] = parameters->dynamicCurrentK;

		ccMaxOmega[i] = parameters->maxVel;
		ccMaxAcc[i] = parameters->maxAcc;
		if(ccMode[i] == CC_MODE_ORDER2 || ccMode[i] == CC_MODE_CONST_OMG)
		ccTargetOmega[i] = parameters->maxVel;

		ccTotalPulse[i] = parameters->totalPulse;

		ccZeroPosOffset[i] = 0;
	}
	subEDegBits = parameters->subEDegBits;
	if (parameters->velocityK != 0)
	{
		velocityK = parameters->velocityK;
	}
	if (parameters->accK != 0)
	{
		accK = parameters->accK;
	}
}

// 写入电机目标位置数组
void setCCTargetPosArray(int32_t *posList, uint16_t length, uint8_t bitsMode)
{
	switch (bitsMode & 0x03)
	{
	case 0:
	{
		for (int i = 0; i < MOTOR_NUM; i++)
		{
			ccTargetPos[i] = (ccTotalPulse[i] >> 8) * posList[i];
		}
		break;
	}
	case 1:
		for (int i = 0; i < MOTOR_NUM; i++)
		{
			ccTargetPos[i] = (ccTotalPulse[i] >> 16) * posList[i];
		}
		break;
	case 2:
		for (int i = 0; i < MOTOR_NUM; i++)
		{
			ccTargetPos[i] = posList[i];
		}
		break;
	default:
		break;
	}
}

void writeMotorPwm()
{

	uint16_t *degPtr = ((uint16_t *)ccDegree);

	for (int i = 0; i < MOTOR_NUM; i++)
	{

		uint16_t w;
		if (ccFlags[i] & CC_FLAG_REVERSE)
		{
			w = sinWave[255 - (((*degPtr >> subEDegBits) + ccEDegOffset[i])) & 0xff];
		}
		else
		{
			w = sinWave[(((*degPtr >> subEDegBits) + ccEDegOffset[i])) & 0xff];
		}
		degPtr += 2;
		uint32_t f = 0; //(*forcePtr);
		int16_t omg = ccOmega[i];

		if (ccAccR[i] > 1 || ccAccR[i] < -1 || omg != 0)
		{
			f += ccDynamicForce[i];
		}
		else
		{
			f += ccStaticForce[i];
		}

#if (PWM_COMPENSATE_BY_TABLE)
		f += motorVelPWM[omg];
#else
		if (omg < 0)
			f -= omg * ccForceK[i];
		else
			f += omg * ccForceK[i];
#endif

		if (f > 65535)
		{
			f = 65535;
		}

		uint32_t a, b;

		a = (((w >> 8) & 0x7f) * f) >> 8;

		if (w & 0x8000)
		{
			a |= 0x8000;
		}
		b = ((w & 0x7f) * f) >> 8;

		if (w & 0x80)
		{
			b |= 0x8000;
		}

		// if (ccOmegaF[i] == 0)
		// {
		// 	pwmData[i] = 0x0000;
		// }
		// else
		{
			pwmData[i] = (a & 0xff00) | ((b >> 8));
		}
	}

	gPwmFunc(pwmData, MOTOR_NUM, (ccFlags[0] & 0x80) ? 0x0001 : 0x0000);
}

uint8_t needReadLim = 0;
uint8_t displayPainting;

float accP = 0.0001f;

void updateCCMotors()
{

	readLimBytes();
	int32_t deltaPos;

	uint8_t limTestBit;
	uint16_t limByteIndex;
	// uint8_t zeroProgressGoing = 0;
	// uint32_t tp = totalPulse;

	uint32_t *zeroAccumPtr = ccZeroProgAccum;
	for (int i = 0; i < MOTOR_NUM; i++)
	{
		uint32_t totalPulse = ccTotalPulse[i];
		float omgF = ccOmegaF[i];
		float accF = ccAcc[i];
		int16_t omg;
		int32_t targetOmgPre = 0;
		float targetOmgSet = 0;

		uint8_t zps = ccZeroProgressState[i];

		// 检测电机的复位状态
		limByteIndex = i >> 3;
		limTestBit = 0x01 << (i & 0x07);
		uint8_t toReset = 0;

		histLimSeq[i] = histLimSeq[i] << 1;
		if (limBytes[limByteIndex] & limTestBit)
		{
			histLimSeq[i] |= 0x0001;
		}

		if (omgF > 0 && ((histLimSeq[i] & 0x0003) == 0x01))
		{
			toReset = 1;
		}
		else if (omgF < 0 && ((histLimSeq[i] & 0x0003) == 0x02))
		{
			toReset = 1;
		}
		if (ccZeroProgAccum[i] == 0xffffffff)
		{
			toReset = 1;
			ccZeroProgAccum[i] = 0;
		}

		//		|(omgF > ==00 && omgF < 900 && ((limBytes[limByteIndex] & limTestBit)) && !(histLimBytes[limByteIndex] & limTestBit)){
		//			toRest = 1;
		//		}else if ((omgF < 0) && omgF > -900 && ((limBytes[limByteIndex] & limTestBit) == 0) && (histLimBytes[limByteIndex] & limTestBit)){
		//			toRest = 1;
		//		}

		if (toReset)
		{
			// uint8_t ep = (unit->pos + unit->EPosOffset) &0xff;
			// unit->pos = unit->zeroPos;
			// 电角度与位置解耦
			// unit->EPosOffset = (ep - (unit->pos &0xff));
			if (zps == 2)
			{
				zps = 1;
				ccZeroProgressState[i] = 1;
			}
			else
			{
				uint8_t eDegBeforeReset = ((ccDegree[i] >> subEDegBits) + ccEDegOffset[i]) & 0xff;
				int32_t DegAfterReset = (ccZeroPosOffset[i]); //((int32_t)omgF <<2
				// int32_t eDegNew = ccEDegOffset[i] + eDegAfterReset - eDegBeforeReset;
				ccEDegOffset[i] = eDegBeforeReset - (DegAfterReset >> subEDegBits);
				ccDegree[i] = DegAfterReset;

				if (zps != 0)
				{
					zps = 0;
					ccZeroProgressState[i] = 0;
				}
			}
		}

		if (zps == 0)
		{
			deltaPos = (ccTargetPos[i] - ccDegree[i]);
			if (ccFlags[i] & CC_FLAG_LOOP)
			{
				// deltaPos = deltaPos % (totalPulse);
				if (totalPulse != 0)
				{
					int32_t halfMotorRoundDeg = totalPulse >> 1;

					while (deltaPos > halfMotorRoundDeg)
						deltaPos -= totalPulse;

					while (deltaPos < -halfMotorRoundDeg)
						deltaPos += totalPulse;
				}

				if (ccFlags[i] & CC_FLAG_SINGLE_DIRECTION)
				{
					if (deltaPos < -(totalPulse >> 3))
						deltaPos += totalPulse;
				}
			}
			// deltaPos = deltaPos >> 8;
			// 处理不同的高层运动模式
			if (!displayPainting)
			{
				switch (ccMode[i])
				{
				case CC_MODE_IDLE:
					break;
				case CC_MODE_CONST_OMG: // 恒定速度运动
					// 获取循环角度
					targetOmgPre = deltaPos >> 2; // 根据角度差计算合适的运转速度
					if (targetOmgPre > 20 || targetOmgPre < -20)
					{
						targetOmgSet = ccTargetOmega[i];

						if (targetOmgPre > 0)
						{
							// targetOmgPre = targetOmgSet;
							omgF = targetOmgSet;
						}
						else
						{
							// targetOmgPre = -targetOmgSet;
							omgF = -targetOmgSet;
						}
					}
					else
					{
						accF = 0;
						// omgF = 0;
						ccDegree[i] = ccTargetPos[i];
					}
					break;
				case CC_MODE_ORDER2: // 带震荡和阻尼的运动

					float tgtVel = deltaPos * velocityK;
					if (tgtVel > ccMaxOmega[i])
						tgtVel = ccMaxOmega[i];
					if (tgtVel < -ccMaxOmega[i])
						tgtVel = -ccMaxOmega[i];

					float deltaVel = tgtVel - omgF;
					accF = deltaVel * accK;
					if (!(ccFlags[i] & CC_FLAG_LOOP))
					{
						if (toReset)
						{
							// 如果是复位状态，则不进行加速度计算
							accF = 0;
							omgF = 0;
						}
					}
					break;
				case CC_MODE_OMG: // 纯角速度控制
					omgF = ccTargetOmega[i];
					ccOmegaF[i] = omgF;
					break;
				}
			}
		}
		else
		{
			int16_t zeroProgVel = (int32_t)(ccMaxOmega[i]) >> 2;
			if (zps == 1)
			{
				omgF = -zeroProgVel;
			}
			else if (zps == 2)
			{
				omgF = zeroProgVel;
			}

			if (ccZeroProgAccum[i] != 0xffffffff)
			{
				ccZeroProgAccum[i] += (zeroProgVel >> 1);
				if (ccZeroProgAccum[i] > totalPulse)
				{
					ccZeroProgAccum[i] = 0xffffffff;
				}
			}
			// zeroProgressGoing = 1;
			ccOmegaF[i] = omgF;
		}

		if (accF > ccMaxAcc[i])
			accF = ccMaxAcc[i];
		if (accF < -ccMaxAcc[i])
			accF = -ccMaxAcc[i];

		omgF = omgF + accF * accP;

		omg = omgF;
		ccDegree[i] += omg;

		ccOmegaF[i] = omgF;
		ccOmega[i] = omg;

		ccAccR[i] = accF;
	}

	// needReadLim = zeroProgressGoing;
	writeMotorPwm();
}

uint8_t readingLimBytes = 0;

inline void readLimBytes()
{
	if (readingLimBytes)
		return;
	readingLimBytes = 1;

	gInputFunc(limBytes, LIM_BYTE_NUM);

	readingLimBytes = 0;
}

// 将所有电机归零到限位位置
void zeroAllMotors()
{

	// 电机复位状态  0: 不在复位中 1：omg<0复位过程 2：omg>0复位过程
	// uint8_t ccZeroProgressState[MOTOR_NUM];

	// omg>0 0->1
	// omg<0 1->0
	uint8_t limTestBit;
	uint16_t limByteIndex;

	readLimBytes();

	for (int i = 0; i < MOTOR_NUM; i++)
	{
		limByteIndex = i >> 3;
		limTestBit = 0x01 << (i & 0x07);

		if (limBytes[limByteIndex] & limTestBit)
		{ // 限位状态为1
			ccZeroProgressState[i] = 1;
		}
		else
		{ // 限位状态为0
			ccZeroProgressState[i] = 2;
		}
		ccZeroProgAccum[i] = 0;
	}
}

// 将指定电机归零到限位位置
void zeroMotor(uint16_t i)
{

	// 电机复位状态  0: 不在复位中 1：omg<0复位过程 2：omg>0复位过程
	// uint8_t ccZeroProgressState[MOTOR_NUM];

	// omg>0 0->1
	// omg<0 1->0
	uint8_t limTestBit;
	uint16_t limByteIndex;

	readLimBytes();

	limByteIndex = i >> 3;
	limTestBit = 0x01 << (i & 0x07);

	if (limBytes[limByteIndex] & limTestBit)
	{ // 限位状态为1
		ccZeroProgressState[i] = 1;
	}
	else
	{ // 限位状态为0
		ccZeroProgressState[i] = 2;
	}
	ccZeroProgAccum[i] = 0;
}

// 初始化零点偏移值
void initZeroOffset(int32_t *zeroOffsetList)
{
	for (int i = 0; i < MOTOR_NUM; i++)
	{
		ccZeroPosOffset[i] = zeroOffsetList[i];
	}
}
