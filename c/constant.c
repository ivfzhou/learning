#include "constant.h"

void TestConstant(void) {
    const int C = 0;
    const int* C2 = 0; // 指针指向值不能修改。
    int const* C3 = 0; // 同上。
    int* const C4 = 0; // 指针本身不能修改。
    const int* const C5 = 0; // 指针值和指向值都不能修改。
    int const* const C6 = 0; // 同上。
}
