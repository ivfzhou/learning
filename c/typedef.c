#include "typedef.h"

// 声明语法。
typedef unsigned int Uint;

typedef struct {
    double real;
    double imag;
} Complex;

typedef void (*Func)(char*);

void TestTypedef(void) {
    // 仅供函数内使用。
    typedef unsigned char BYTE;
    Complex c; // 等价于 struct{double real; double imag;} c;
    Func fn;
}

// typedef 和 define 的区别。

#define BYTE char*

typedef char* Byte;

void TestTypedef2(void) {
    BYTE x, y; // 等价于 char *x, y;
    Byte x1, y1; // 等价于 char *x1, *y1;
}
