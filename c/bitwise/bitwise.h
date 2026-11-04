#ifndef COM_GITEE_IVFZHOU_C_BITWISE_H
#define COM_GITEE_IVFZHOU_C_BITWISE_H

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

// 低位地址放低位字节就是小端序。
// 例如 0x11223344 存进地址 0x100
// 地址:  0x100  0x101  0x102  0x103
// 内容:   44     33     22     11
//        最低位              最高位

// 字节位从左到右打印，单个字节从左到右打印。
BITWISE_API void PrintBitLtrLtr(const void* target, size_t size);

// 字节位从左到右打印，单个字节从右到左打印。
BITWISE_API void PrintBitLtrRtl(const void* target, size_t size);

// 字节位从右到左打印，单个字节从左到右打印。
BITWISE_API void PrintBitRtlLtr(const void* target, size_t size);

// 字节位从右到左打印，单个字节从右到左打印。
BITWISE_API void PrintBitRtlRtl(const void* target, size_t size);

#endif
