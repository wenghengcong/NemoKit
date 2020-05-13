//
//  NMBFMathMacro.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBFMathMacro_h
#define NMBFMathMacro_h

// Math
/// 向下取整
#define NMBMathFloor(c) floorf(c)
///  四舍五入
#define NMBMathRound(c) roundf(c)
/// 向上取整
#define NMBMathCeil(c) ceilf(c)
/// 两数取余
#define NMBMathMod(c1,c2) fmodf(c1,c2)

#define NMBMathHalfRound(c)     (NMBMathRound(c*2)*0.5)
#define NMBMathHalfFloor(c)     (NMBMathFloor(c*2)*0.5)
#define NMBMathHalfCeil(c)      (NMBMathCeil(c*2)*0.5)

#pragma mark - 数学计算

#define AngleWithDegrees(deg) (M_PI * (deg) / 180.0)


#endif /* NMBFMathMacro_h */
