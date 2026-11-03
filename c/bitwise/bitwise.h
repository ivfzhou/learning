#ifndef GITEE_COM_IVFZHOU_C_BITWISE_H
#define GITEE_COM_IVFZHOU_C_BITWISE_H

#include <stdlib.h>

// 构建动态库时定义 BITWISE_EXPORTS（/DBITWISE_EXPORTS 或 -DBITWISE_EXPORTS），
// 函数以 __declspec(dllexport) 导出；编译静态库、可执行文件或不定义时不做修饰。
#if defined(_WIN32) && defined(BITWISE_EXPORTS)
    #define BITWISE_API __declspec(dllexport)
#else
    #define BITWISE_API
#endif

// 将 flag 第 index 位保留，其他位置零。
BITWISE_API unsigned char BitMask(unsigned char flag, unsigned char index);

// 将 flag 第 index 位置为 1。
BITWISE_API unsigned char BitOpen(unsigned char flag, unsigned char index);

// 将 flag 第 index 位置为零。
BITWISE_API unsigned char BitClose(unsigned char flag, unsigned char index);

// 将 flag 第 index 位置反。
BITWISE_API unsigned char BitToggle(unsigned char flag, unsigned char index);

// 检查 flag 第 index 位是否为 1。
BITWISE_API _Bool BitCheck(unsigned char flag, unsigned char index);

// 从左到右打印每个字节，字节中从左到右打印每个位。
BITWISE_API void PrintBitFieldLayoutLeftToTight(const void* target, size_t size);

// 从左到右打印每个字节，字节中从右到左打印每个位。
BITWISE_API void PrintBitFieldLayoutRightToLeft(const void* target, size_t size);

// 从右到左打印每个字节，字节中从右到左打印每个位。
BITWISE_API void PrintBitFieldLayoutRightToLeftReverse(const void* target, size_t size);

// 从右到左打印每个字节，字节中从左到右打印每个位。
BITWISE_API void PrintBitFieldLayoutLeftToRightReverse(const void* target, size_t size);

#endif
