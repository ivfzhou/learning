// 泛型选择。

#include <stdio.h>

#include "generic.h"

static char* selectStr() { return "fn"; }

void TestGeneric(void) {
    unsigned x = 9;
    char* s = _Generic(x, int: "int", long: "long", default: selectStr()); // 根据 x 的类型返回冒号后的值。
    printf("x type is %s\n", s);
}
