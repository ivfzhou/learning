#ifndef CN_IVFZHOU_C_XOR_CODEC_H
#define CN_IVFZHOU_C_XOR_CODEC_H

// 构建动态库时定义 BITWISE_NEGATION_EXPORTS（/DBITWISE_NEGATION_EXPORTS 或 -DBITWISE_NEGATION_EXPORTS），
// 函数以 __declspec(dllexport) 导出；编译静态库、可执行文件或不定义时不做修饰。
#if defined(_WIN32) && defined(XOR_CODEC_EXPORTS)
    #define XOR_CODEC_API __declspec(dllexport)
#else
    #define XOR_CODEC_API
#endif

// 将文件 input_file 内容的每一位
XOR_CODEC_API int xorCodec(const char* secret, const char* inputFile, const char* outputFile);

#endif
