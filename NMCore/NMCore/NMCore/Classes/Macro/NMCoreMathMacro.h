//
//  NMCoreMathMacro.h
//  Pods
//
//  Created by Hunt on 2020/7/2.
//

#import "NMCoreMacro.h"

#ifndef NMCoreMathMacro_h
#define NMCoreMathMacro_h

NM_EXTERN_C_BEGIN

#ifndef NM_CLAMP // return the clamped value
#define NM_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef NM_SWAP // swap two value, add do while block to avoid _tmp_ var dumplicate
#define NM_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

/// 向下取整
#ifndef NM_ANGLE_BY_DEGRESS
#define NM_ANGLE_BY_DEGRESS(deg)    ( (M_PI * (deg)) / 180.0)
#endif


NM_EXTERN_C_END
#endif /* NMCoreMathMacro_h */
