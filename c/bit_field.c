// 位字段

#include <stdio.h>

#include "bit_field.h"
#include "bitwise/bitwise.h"

void TestBitField(void) {
    // C 以 unsigned int 作为位字段结构的基本布局单元，分配的内存为 int 长度的倍数。
    // 实测表现，内存布局中前 21 位为填充，接着 2 位是 c 的，接着 7 位为填充，接着 2 位是 a 的。
    struct HasBitField {
        int a : 2;
        int : 7; // 间隙
        int c : 2;
    };

    printf("sizeof(struct HasBitField)=%zu\n", sizeof(struct HasBitField));

    struct HasBitField s = {0};
    printf("print bit layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&s, sizeof(s));

    s.a = 1;
    s.c = -1;
    printf("print bit layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&s, sizeof(s));

    unsigned char* ptr = (unsigned char*)&s;
    *ptr = 1;
    printf("s.a is %d\n", s.a);
    printf("print bit layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&s, sizeof(s));

    *(ptr + 1) = 4; // 加一就是加一个字节。
    printf("s.c is %d\n", s.c);
    printf("print bit layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&s, sizeof(s));
}
