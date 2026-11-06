#ifndef CN_IVFZHOU_C_STRUCT_H
#define CN_IVFZHOU_C_STRUCT_H

#include "export.h"

// 声明结构体语法。
struct User {
    int age;
};

C_API void TestStruct(void);

C_API struct User TestStruct2(int x);

#endif
