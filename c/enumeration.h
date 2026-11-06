#ifndef CN_IVFZHOU_C_ENUMERATION_H
#define CN_IVFZHOU_C_ENUMERATION_H

#include "export.h"

// 枚举的声明
enum Week {
    MON, /* 值为 0 */
    TUES,
    WED,
    THURS,
    FRI,
    SAT,
    SUN
};

C_API enum Week TestEnumeration(void);

#endif
