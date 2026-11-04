// 设置宏将会关闭断言，前于 assert.h。
// #define NDEBUG

#include <assert.h>

#include "assertion.h"

// 编译期间断言。第一个参数要是常量表达式。表达式为 false 则终止编译。
_Static_assert(1 > 0, "assertion message");

void TestAssertion(void) {
    int x = 10;
    int y = x - 9;
    assert(y > 0);
}
