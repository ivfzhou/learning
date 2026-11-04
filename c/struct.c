#include <stdio.h>

#include "struct.h"

void TestStruct(void) {
    // 使用结构体。
    struct User u = {.age = 18 /*, 123 多余元素 */};
    struct User u2 = {18};

    // 声明及使用语法。
    struct User2 {
        int age;
    } u3 = {.age = 18};
    struct {
        int age;
        struct User s;
    } u4 = {18, {18}};
    struct User3 {
        struct User2 s;
    } u5 = {{18}};

    // 结构体指针访问字段。
    struct User* u6 = &(struct User){0};
    printf("u6->age = %d\n", u6->age);

    // 结构体中的不定长数组声明语法。
    struct User4 {
        int x;
        int y[]; // 不占空间，不传递值。
    };

    // 结构体中的匿名结构体声明语法。
    struct User5 {
        struct {
            int age;
        };
    };
    // 使用匿名成员字段方法。
    struct User5 u7 = {.age = 1};
    printf("u7.age = %d\n", u7.age);
}

// 结构体在函数中的传递和返回。
struct User TestStruct2(const int x) {
    // 结构体的复合字面量。
    // return &(struct user){x};
    return (struct User){x};
}
