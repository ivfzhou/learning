#include <stdio.h>

#include "variable.h"

// 默认零值。
int FileVar = 1;

// 每个包含该头文件的文件都会获得一份变量的备份。
static int fileStaticVar = 1;

const int FileConstVar = 1;

volatile int FileVolatileVar = 1;

volatile const int FileVolatileConstVar = 1;

int* restrict FileRestrictPtr = NULL;

// 引用其它文件的变量。
extern int FileVar2;

// 线程私有变量。
_Thread_local int FileThreadVar = 1;

static int* blockStaticVarFn(void) {
    static int blockStaticVar;
    printf("blockStaticVar = %d\n", blockStaticVar);
    return &blockStaticVar;
}

static void blockExternVarFn(void) {
    // 引用外部变量。
    extern int fileVar;
}

static void blockAutoVarFn(void) { auto int fileVar; }

// 寄存器变量。
static void registerVarFn(void) {
    register int i = 99;
    // printf("%d, %p", i, &i); // 寄存器变量不可取址。
}

// 寄存器形参。
static void registerVar2Fn(register int i) { printf("register i = %d", i); }

void TestVariable(void) {
    blockStaticVarFn();
    blockStaticVarFn();
    blockStaticVarFn();
}
