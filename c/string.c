#include <locale.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include "string.h"

void TestString(void) {
    char str[11] = "hello";
    printf("str = %s, length = %zu\n", str, strlen(str));
    char str2[] = "world";
    printf("str2 = %s, length = %zu\n", str2, strlen(str2));
    char* str3 = strcat(str, str2);
    printf("str3 = %s, length = %zu\n", str3, strlen(str3));

    printf("\n===\n\n");

    printf("str pointer = %p\n", str);
    printf("str2 pointer = %p\n", str2);
    strcpy(str, str2);
    printf("str = %s, pointer = %p\n", str, str);

    printf("\n===\n\n");

    printf("str strcmp str2 = %d\n", strcmp(str, str2));

    char* str4 = "hello";
    printf("str4[last] = %c\n", str4[strlen(str4) - 1]);
    // str4[0] = 'H'; // 无法写入。该字符串在静态数据区。

    // 字符串拼接。
    char* str5 = "hello"
                 "world";

    printf("\n===\n\n");

    // 字符串转码。
    setlocale(LC_ALL, "zh_CN.utf8");
    char str6[] = "zß水🍌";
    char str7[] = "z\u00df\u6c34\U0001f34c";
    char str8[] = "\x7a\xc3\x9f\xe6\xb0\xb4\xf0\x9f\x8d\x8c";
    printf("str6 = %s\n", str6);
    printf("sizeof str6 = %zu\n", sizeof(str6));
    wchar_t wstr[sizeof str6 + 1] = {};
    swprintf(wstr, sizeof wstr / sizeof *wstr, L"%s", str6);
    wprintf(L"wstr = %ls\n", wstr);
    printf("strcmp(str6, str7) = %d\n", strcmp(str6, str7));
}
