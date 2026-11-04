#include <stdio.h>

#include "function.h"

// inline 函数在每个使用它们的编译单元中都有自己的实例。
static inline void inlineFunc(void) { printf("hello world\n"); }

// static 函数只能在一个源文件中可见。
static void staticFunc(void) {}

// 引用其它文件的函数。
extern void ExternFunc(void) {}

// 不会返回控制权给主调函数。
_Noreturn void NoreturnFunc(void) { printf("hello world\n"); }

void TestFunction(void) {
    staticFunc();
    inlineFunc();
}
