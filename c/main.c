#include <stdio.h>

#include "alignment.h"
#include "array.h"
#include "assertion.h"
#include "bit_field.h"
#include "bitwise/bitwise.h"
#include "constant.h"
#include "enumeration.h"
#include "flow_statement.h"
#include "function.h"
#include "generic.h"
#include "macro.h"
#include "string.h"
#include "struct.h"
#include "type.h"
#include "typedef.h"
#include "union.h"
#include "varargs.h"
#include "variable.h"

static void testCast(void) {
    const char c = 5;
    char resultChar = (char)~c;
    char resultInt = ~c;
    printf("resultChar bit pattern is ");
    PrintBitLtrLtr((unsigned char*)&resultChar, sizeof(char));

    printf("resultInt bit pattern is ");
    PrintBitLtrLtr((unsigned char*)&resultInt, sizeof(char));
}

// scanf 输入格式中的空白表示跳过空白寻找下一个字符。
static void testScanf(void) {
    int value = 0;
    int res = scanf(" %d", &value);
    printf("res=%d, value=%d\n", res, value);
}

// scanf 遇到空格字符串就结束，末尾自动加 \0，而 gets 换行才算字符串结束。
static void testScanf2(void) {
    char str[4];
    int res = scanf("%3s", str);
    printf("res=%d, str=%s\n", res, str);
}

static void testScanf3(void) {
    char str[4];
    scanf("%3s", str);
    char str2[4];
    scanf("%3s", str2);
    printf("str2=%s\n", str2);
}

static void testAll() {
    TestAlignment();
    TestArray();
    TestAssertion();
    TestBitField();
    TestConstant();
    TestEnumeration();
    TestFlowStatement();
    TestFunction();
    TestGeneric();
    TestMacro();
    TestString();
    TestStruct();
    TestStruct2(1);
    TestType();
    TestTypedef();
    TestTypedef2();
    TestUnion();
    TestVarargs();
    TestVariable();
}

int main(const int argv, const char* argc[]) {
    testAll();
    printf("OK 完成\n");
    return 0;
}
