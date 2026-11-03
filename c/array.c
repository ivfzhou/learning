#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "array.h"

void TestArray(void) {
    // str 是一个指向字符串字面量的指针。
    // 字符串字面量 "hello world" 存储在只读的内存区域（通常是程序的文本段或只读数据段）。
    char* str = "hello world"; // 等价于 char (*str)[12]; str[11] = '\x00'

    // str2 是一个字符数组。
    // 编译器会根据字符串的内容自动分配足够的内存来存储字符串，包括结尾的空字符 \0。
    // 是一个可修改的字符数组。
    char str2[] = "hello world";

    // 如果字符串的长度超过 11 个字符（不包括空字符），则会导致数组溢出，产生未定义行为。
    // 如果字符串的长度小于 11 个字符，剩余的空间将被填充为 \0。
    char str4[12] = "hello world";

    char str5[] = "hello\0world"; // 字符串打印只有 hello。
    printf("str5 = ");
    for (size_t i = 0; i < sizeof(str5); i++) {
        printf("%c", str5[i]);
    }
    printf("\n");

    char str6[] = {'\0'};
    char str7[1] = {'h'};
    char str8[12] = {'h'}; // 第 0 位是 h，其他位是空字符。
    char str9[12] = {"hello world"};
    char str10[12] = {[10] = 'h'};
    // str11[0] 到 str11[9] 的内容未被初始化，可能包含随机值（未定义行为）。
    char str11[12][12] = {
        [10] = {'h'}, // 也可以 'h'，不要大括号，但会编译器警告，应为 C 语言要求每一维的初始化都要用大括号 {} 包裹起来。
        [1] = "abc",
    }; // str11[10][0] = 'h'

    int arr[2][3] = {
        {1, 2, 3},
        {4, 5, 6},
    };
    printf("sizeof(arr)=%zu\n", sizeof(arr));
    printf("sizeof(int[3])=%zu\n", sizeof(int[3]));
    printf("arr[2][3] + 1 => %llu\n",
           (unsigned long long)((uintptr_t)(arr + 1) - (uintptr_t)arr)); // 表示加 sizeof(int[3])
    printf("arr[0] + 1 => %llu\n",
           (unsigned long long)((uintptr_t)(arr[0] + 1) - (uintptr_t)arr[0])); // 表示加 sizeof(int)

    printf("\n===\n\n");

    int* ptr = NULL;
    printf("sizeof(ptr) = %zu\n", sizeof(ptr));

    printf("\n===\n\n");

    struct HasFlexibleArayMember {
        int x;
        char arr[]; // 末尾的不定长数组。
    };
    printf("sizeof(struct HasFlexibleArayMember) = %zu\n", sizeof(struct HasFlexibleArayMember));
    struct HasFlexibleArayMember* hfam = malloc(sizeof(struct HasFlexibleArayMember) + 12 * sizeof(char));
    printf("sizeof(hfam) = %zu\n", sizeof(*hfam));
    hfam->arr[0] = 'h';
    hfam->arr[1] = 'e';
    hfam->arr[2] = 'l';
    hfam->arr[3] = 'l';
    hfam->arr[4] = 'o';
    hfam->arr[5] = '\0';
    printf("hfam->arr = %s\n", hfam->arr);
    printf("&hfam.x = %p\n", (void*)&hfam->x);
    printf("hfam.arr = %p\n", hfam->arr);
    free(hfam);
}
