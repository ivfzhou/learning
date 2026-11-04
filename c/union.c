#include <stdio.h>

#include "union.h"

// 联合体声明语法。编译器只分配占用最大字节类型字段的空间。
union Brand {
    char a;
    int b;
};

void TestUnion(void) {
    // 联合体的初始化。
    union Brand b = {33}; // 33 复制给了 a。
    printf("b.b = %d\n", b.b);

    union Brand b2 = {.a = 'c'};
    b2.a = 'd';
    printf("b2.b = %d\n", b2.b);

    // 匿名联合体的声明。
    union Brand2 {
        union {
            char x;
            float y;
        };
    };
    union Brand2 b3 = {.x = '1'};
    printf("b3.x = %c\n", b3.x);

    union Brand2* b4 = &b3;
    printf("b4->x = %c\n", b4->x);
}
