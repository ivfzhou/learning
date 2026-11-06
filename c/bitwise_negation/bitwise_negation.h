#ifndef CN_IVFZHOU_C_BITWISE_NEGATION_H
#define CN_IVFZHOU_C_BITWISE_NEGATION_H

// 构建动态库时定义 BITWISE_NEGATION_EXPORTS（/DBITWISE_NEGATION_EXPORTS 或 -DBITWISE_NEGATION_EXPORTS），
// 函数以 __declspec(dllexport) 导出；编译静态库、可执行文件或不定义时不做修饰。
#if defined(_WIN32) && defined(BITWISE_NEGATION_EXPORTS)
    #define BITWISE_NEGATION_API __declspec(dllexport)
#else
    #define BITWISE_NEGATION_API
#endif

// 将 filename 文件的每一位置反。
BITWISE_NEGATION_API int BitwiseNegation(const char* filename);

#endif
