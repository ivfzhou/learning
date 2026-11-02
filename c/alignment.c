#include <stdint.h>
#include <stdio.h>

#include "alignment.h"

// 内存对齐是指在计算机内存中，数据的存储地址必须是某个特定值的倍数。
// 内存对齐的目的是为了提高内存访问的效率，减少 CPU 访问内存时的延迟。
// 对齐要求是指数据在内存中存储时，地址必须是某个特定值的倍数。

struct S {
    int a;
    char b;
    double c;
};

void test_alignment(void) {
    printf("_Alignof(int) is %zu\n", _Alignof(int)); // 4
    char _Alignas(8) c = 'a'; // 使 c 的对齐值是 8，地址会是 8 的整数倍。
    printf("sizeof(c) is %zu\n", sizeof(c)); // 1
    printf("&c address is %p\n", &c);
    printf("&c %% 8 is %llu\n", (unsigned long long)(uintptr_t)&c % 8); // 0
    printf("&c %% 16 is %llu\n", (unsigned long long)(uintptr_t)&c % 16);

    printf("\n===\n\n");

    printf("_Alignof(int) is %zu\n", _Alignof(int)); // _Alignof 不允许传递表达式，s.a 不允许。
    printf("_Alignof(char) is %zu\n", _Alignof(char));
    printf("_Alignof(double) is %zu\n", _Alignof(double));
    printf("_Alignof(struct S) is %zu\n", _Alignof(struct S));
    printf("sizeof(struct S) is %zu\n", sizeof(struct S));

    // S 的对齐值是 8，S.a 的对齐值是 4，S.b 的对齐值是 1，S.c 的对齐值是 8。
    // 所以 a 占用 4 字节，b 占 4 字节，c 占 8 字节，总计 16 字节，每个字段地址都是对齐值的倍数。

    printf("\n===\n\n");

    printf("_Alignof(char) is %zu\n", _Alignof(char)); // 1
    printf("_Alignof(unsigned char) is %zu\n", _Alignof(unsigned char)); // 1
    printf("_Alignof(short int) is %zu\n", _Alignof(short int)); // 2
    printf("_Alignof(unsigned short int) is %zu\n", _Alignof(unsigned short int)); // 2
    printf("_Alignof(int) is %zu\n", _Alignof(int)); // 4
    printf("_Alignof(unsigned int) is %zu\n", _Alignof(unsigned int)); // 4
    printf("_Alignof(long) is %zu\n", _Alignof(long)); // 4
    printf("_Alignof(unsigned long) is %zu\n", _Alignof(unsigned long)); // 4
    printf("_Alignof(long long) is %zu\n", _Alignof(long long)); // 8
    printf("_Alignof(unsigned long long) is %zu\n", _Alignof(unsigned long long)); // 8
    printf("_Alignof(float) is %zu\n", _Alignof(float)); // 4
    printf("_Alignof(double) is %zu\n", _Alignof(double)); // 8
    printf("_Alignof(long double) is %zu\n", _Alignof(long double)); // 16
}
