#include <locale.h>
#include <stdio.h>
#include <uchar.h>
#include <wchar.h>

#include "type.h"

// 数据类型
void TestType(void) {
    char c = 'C';
    short s = 1;
    unsigned short us = 1;
    int i = 1;
    unsigned u = 1U;
    long l = 1L;
    unsigned long ul = 1UL;
    long long ll = 1LL;
    unsigned long long ull = 1ULL;
    float f = 1.1F;
    double d = 1.1;
    long double ld = 1.1L;
    char* str = "hello world";
    char str2[11] = "hello world";
    wchar_t wt\u4f60 = L'\u4f60'; // UCN
    char16_t ct = u'\u07F7';
    char32_t ct4 = U' ';

    printf("char size = %zu\n", sizeof(char));
    printf("short size = %zu\n", sizeof(short));
    printf("int size = %zu\n", sizeof(int));
    printf("long size = %zu\n", sizeof(long));
    printf("long long size = %zu\n", sizeof(long long));
    printf("float size = %zu\n", sizeof(float));
    printf("double size = %zu\n", sizeof(double));
    printf("long double size = %zu\n", sizeof(long double));
    printf("char* size = %zu\n", sizeof(char*));
    printf("char[11] size = %zu\n", sizeof(char[11]));
    printf("wchar_t size = %zu\n", sizeof(wchar_t));
    printf("char16_t size = %zu\n", sizeof(char16_t));
    printf("char32_t size = %zu\n", sizeof(char32_t));

    printf("\n===\n\n");

    setlocale(LC_ALL, "" /* en_US.utf8 */);
    wprintf(L"wt\u4f60 = %lc\n", wt\u4f60);
    wchar_t* ws = L"hello world 你好世界";
    wprintf(L"ws is %ls\n", ws);
}
