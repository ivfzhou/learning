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

static void test_cast(void) {
    const char c = 5;
    char result_char = (char)~c;
    char result_int = ~c;
    printf("result_char bit pattern is ");
    print_bit_field_layout_left_to_right_reverse((unsigned char*)&result_char, sizeof(char));

    printf("result_int bit pattern is ");
    print_bit_field_layout_left_to_right_reverse((unsigned char*)&result_int, sizeof(char));
}

// scanf 输入格式中的空白表示跳过空白寻找下一个字符。
static void test_scanf(void) {
    int value = 0;
    int res = scanf(" %d", &value);
    printf("res=%d, value=%d\n", res, value);
}

// scanf 遇到空格字符串就结束，末尾自动加 \0，而 gets 换行才算字符串结束。
static void test_scanf2(void) {
    char str[4];
    int res = scanf("%3s", str);
    printf("res=%d, str=%s\n", res, str);
}

int main(const int argv, const char* argc[]) {
    test_alignment();
    printf("OK 完成\n");
    return 0;
}
