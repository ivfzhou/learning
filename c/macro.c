// 宏：替换除引号包含的文本外的所有文本内容。

#define X PI* PI
#define PI 3.14

// 类函数宏，只替换不计算和函数有区别。
#define FN(a) ((a) * (a))

// 末尾自动加 \0。
#define STR "hello"

// 包含多行。
#define STR2 \
    "hello \
2"

// 宏参数。
#define FN2(x) printf("print " #x " is %d\n", x)

// 粘合剂。
#define Y(n) y##n

// 变参宏。
#define PRINT(p, ...) printf(p, __VA_ARGS__)

// 空宏。
#define GOOD

// 把当前行号重置为 1000。
// #line 1000
// 把行号重置为 10，把文件名重置为 macro_reset.c。
// #line 10 "macro_reset.c"

// 编译器指令。
#pragma message "Hello"
// #pragma STDC CX_LIMITED_RANGE ON // 使用普通的数学公式。
// #error compile error // 终止编译。

// 预处理指令，用于在编译时插入特定的编译器指令。编译时会输出一条消息。
// _Pragma("message(\"Hello\")")

// 条件编译
#ifdef GOOD
#else
#endif

#ifndef GOOD
#else
#endif

#undef GOOD
#ifndef GOOD
    #pragma message "no GOOD defined"
#endif

#if GOOD == 1
#elif GOOD == 0
#else
#endif

#if defined(GOOD)
#elif defined(GOOD)
#endif

#include <stdio.h>

#include "macro.h"

void test_macro(void) {
    printf("macro X is %lf\n", X);
    printf("macro PI is %lf\n", PI);
    printf("macro FN(a) is %d\n", FN(2 + 2));
    printf("macro STR is %s\n", STR);
    printf("macro STR2 is %s\n", STR2);

    printf("call macro FN1 is ");
    FN2(1);

    int Y(1) = 2;
    printf("macro Y(n) is %d\n", Y(1));

    printf("call macro PRINT is ");
    PRINT("%s\n", "hello");

    // 预定义宏。
    printf("__DATE__ is %s\n", __DATE__);
    printf("__FILE__ is %s\n", __FILE__);
    printf("__LINE__ is %d\n", __LINE__);
#ifdef __STDC__
    printf("__STDC__ is %d\n", __STDC__);
#endif
    printf("__STDC_HOSTED__ is %d\n", __STDC_HOSTED__);
    printf("__STDC_VERSION__ is %ld\n", __STDC_VERSION__);
    printf("__TIME__ is %s\n", __TIME__);
#ifdef __STDC_NO_THREADS__
    printf("__STDC_NO_THREADS__ is %s\n", __STDC_NO_THREADS__);
#endif
#ifdef __STDC_NO_ATOMICS__
    printf("__STDC_NO_ATOMICS__ is %s\n", __STDC_NO_ATOMICS__);
#endif
}
