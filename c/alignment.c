#include <stdalign.h>
#include <stdint.h>
#include <stdio.h>

#include "alignment.h"

// 内存对齐是指在计算机内存中，数据的存储地址必须是某个特定值的倍数。
// 内存对齐的目的是为了提高内存访问的效率，减少 CPU 访问内存时的延迟。
// 对齐要求是指数据在内存中存储时，地址必须是某个特定值的倍数。

// S 的对齐值是 16，S.a 的对齐值是 4，S.b 的对齐值是 16，S.c 的对齐值是 8。
// 所以 a 在偏移 0 占 4 字节，b 在偏移 16 占 1 字节（前面填充 12 字节），c 在偏移 24 占 8 字节（前面填充 7 字节）。
// 每个字段地址都是其对齐值的倍数，sizeof(struct S) = 32，总大小是结构体对齐值 16 的倍数。
struct S {
    int a;
    alignas(16) char b;
    double c;
};

void TestAlignment(void) {
    printf("_Alignof(char)=%zu, sizeof(char)=%zu\n", alignof(char), sizeof(char));
    printf("_Alignof(unsigned char)=%zu, sizeof(unsigned char)=%zu\n", _Alignof(unsigned char), sizeof(unsigned char));
    printf("_Alignof(short)=%zu, sizeof(short)=%zu\n", _Alignof(short), sizeof(short));
    printf(
        "_Alignof(unsigned short)=%zu, sizeof(unsigned short)=%zu\n", _Alignof(unsigned short), sizeof(unsigned short));
    printf("_Alignof(int)=%zu, sizeof(int)=%zu\n", _Alignof(int), sizeof(int));
    printf("_Alignof(unsigned int)=%zu, sizeof(unsigned int)=%zu\n", _Alignof(unsigned int), sizeof(unsigned int));
    printf("_Alignof(long)=%zu, sizeof(long)=%zu\n", _Alignof(long), sizeof(long));
    printf("_Alignof(unsigned long)=%zu, sizeof(unsigned long)=%zu\n", _Alignof(unsigned long), sizeof(unsigned long));
    printf("_Alignof(long long)=%zu, sizeof(long long)=%zu\n", _Alignof(long long), sizeof(long long));
    printf("_Alignof(unsigned long long)=%zu, sizeof(unsigned long long)=%zu\n",
           _Alignof(unsigned long long),
           sizeof(unsigned long long));
    printf("_Alignof(float)=%zu, sizeof(float)=%zu\n", _Alignof(float), sizeof(float));
    printf("_Alignof(double)=%zu, sizeof(double)=%zu\n", _Alignof(double), sizeof(double));
    printf("_Alignof(long double)=%zu, sizeof(long double)=%zu\n", _Alignof(long double), sizeof(long double));
    printf("_Alignof(struct S)=%zu, sizeof(struct S)=%zu\n", _Alignof(struct S), sizeof(struct S));

    printf("\n===\n\n");

    char _Alignas(8) c = 'a'; // 使 c 的对齐值是 8，地址会是 8 的整数倍。
    printf("sizeof(c)=%zu\n", sizeof(c));
    printf("&c address = %p\n", &c);
    printf("&c %% 8 = %llu\n", (unsigned long long)(uintptr_t)&c % 8);
    printf("&c %% 16 = %llu\n", (unsigned long long)(uintptr_t)&c % 16);
}
