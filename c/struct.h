#ifndef COM_GITEE_IVFZHOU_C_STRUCT_H
#define COM_GITEE_IVFZHOU_C_STRUCT_H

#include "export.h"

// 声明结构体语法。
struct user {
    int age;
};

C_API void test_struct(void);

C_API struct user test_struct0(int x);

#endif
