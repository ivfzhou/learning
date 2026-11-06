#ifndef CN_IVFZHOU_C_EXPORT_H
#define CN_IVFZHOU_C_EXPORT_H

// 构建动态库时定义 C_EXPORTS（/DC_EXPORTS 或 -DC_EXPORTS），
// 函数以 __declspec(dllexport) 导出；编译静态库、可执行文件或不定义时不做修饰。
#if defined(_WIN32) && defined(C_EXPORTS)
    #define C_API __declspec(dllexport)
#else
    #define C_API
#endif

#endif
