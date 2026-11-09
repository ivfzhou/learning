// 泛型选择。

#include <stdio.h>

#include "generic.h"

static char* selectStr(void) { return "fn"; }

static int getX(void) {
    printf("get x\n");
    return 1;
}

static int getY(void) {
    printf("get y\n");
    return 0;
}

void TestGeneric(void) {
    unsigned x = 9;
    char* s = _Generic(x, int: "int", long: "long", default: selectStr()); // 根据 x 的类型返回冒号后的值。
    printf("x type is %s\n", s);
}

void TestGeneric2(void) {
    // 没有运行计算表达式，只是求取类型。
    printf("%s\n", _Generic(getX() / getY(), int: "ok"));
}
