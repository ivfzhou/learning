// 位字段

#include <stdio.h>

#include "bit_field.h"
#include "bitwise/bitwise.h"

// C 以 unsigned int 作为位字段结构的基本布局单元，分配的内存为 int 长度的倍数。
struct HasBitField {
    int a : 2;
    int : 7; // 间隙
    int c : 2;
    int d;
};

void TestBitField(void) {
    printf("sizeof(struct HasBitField)=%zu\n", sizeof(struct HasBitField));

    struct HasBitField s = {0};
    printf("print bit layout ");
    PrintBitRtlLtr((unsigned char*)&s, sizeof(s));

    s.a = 1;
    s.c = -1;
    s.d = 2;
    printf("print bit layout ");
    PrintBitRtlLtr((unsigned char*)&s, sizeof(s));

    unsigned char* ptr = (unsigned char*)&s;
    *ptr = 1;
    printf("s.a is %d\n", s.a);
    printf("print bit layout ");
    PrintBitRtlLtr((unsigned char*)&s, sizeof(s));

    *(ptr + 1) = 4; // 加一就是加一个字节。
    printf("s.c is %d\n", s.c);
    printf("print bit layout ");
    PrintBitRtlLtr((unsigned char*)&s, sizeof(s));
}
