#include "constant.h"

void test_constant(void) {
    const int I = 0;
    const int* P1 = 0; // 指针指向值不能修改。
    int const* P2 = 0; // 同上。
    int* const P3 = 0; // 指针本身不能修改。
    const int* const P4 = 0; // 指针值和指向值都不能修改。
    int const* const P5 = 0; // 同上。
}
