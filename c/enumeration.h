#ifndef COM_GITEE_IVFZHOU_C_ENUMERATION_H
#define COM_GITEE_IVFZHOU_C_ENUMERATION_H

#include "export.h"

// 枚举的声明
enum week {
    MON, /* 值为0 */
    TUES,
    WED,
    THURS,
    FRI,
    SAT,
    SUN
};

enum level {
    LOW = 100,
    MEDIUM = 500,
    HIGH = 2000,
    HIGHEST /* 值为2001 */
};

C_API enum week test_enumeration(void);

#endif
