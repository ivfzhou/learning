#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "xor_codec.h"

static void printErrMsg(const char* format, const char* file) {
    size_t len = strlen(format) + strlen(file) + 1;
    char* msg = malloc(len);
    if (!msg) {
        char fallback[256];
        snprintf(fallback, sizeof(fallback), format, file);
        perror(fallback);
        return;
    }
    snprintf(msg, len, format, file);
    perror(msg);
    free(msg);
}

int xorCodec(const char* secret, const char* inputFile, const char* outputFile) {
    if (!secret || !inputFile || !outputFile) {
        fprintf(stderr, "xor_codec: please check parameters\n");
        return 1;
    }
    if (!strlen(secret)) {
        fprintf(stderr, "xor_codec: please check secret parameter\n");
        return 1;
    }

    const size_t len = strlen(secret);
    size_t cursor = 0;
    unsigned char ch;

    // 简单判断输入输出文件相同。
    if (!strcmp(inputFile, outputFile)) {
        FILE* file = fopen(inputFile, "r+b");
        if (!file) {
            printErrMsg("xor_codec: can't open file %s", inputFile);
            return 1;
        }

        while (1) {
            ch = fgetc(file);
            if (feof(file)) break;
            if (ferror(file)) {
                printErrMsg("xor_codec: failed to read file %s", inputFile);
                fclose(file);
                return 1;
            }

            if (len == cursor) cursor = 0;
            ch ^= *(secret + cursor++);
            if (fseek(file, -1, SEEK_CUR)) {
                printErrMsg("xor_codec: can't seek file %s", inputFile);
                fclose(file);
                return 1;
            }
            fputc(ch, file);
            if (ferror(file)) {
                printErrMsg("xor_codec: failed to write file %s", inputFile);
                fclose(file);
                return 1;
            }

            if (fflush(file) == EOF) {
                printErrMsg("xor_codec: failed to flush file %s", inputFile);
                fclose(file);
            }
        }

        if (fclose(file) == EOF) {
            printErrMsg("xor_codec: failed to close file %s", outputFile);
            return 1;
        }

        return 0;
    }

    FILE* fileIn = fopen(inputFile, "rb");
    if (!fileIn) {
        printErrMsg("xor_codec: failed to open file %s", inputFile);
        return 1;
    }
    FILE* fileOut = fopen(outputFile, "wb");
    if (!fileOut) {
        printErrMsg("xor_codec: failed to open file %s", outputFile);
        fclose(fileIn);
        return 1;
    }

    while (1) {
        ch = fgetc(fileIn);
        if (feof(fileIn)) break;
        if (ferror(fileIn)) {
            printErrMsg("xor_codec: failed to read file %s", inputFile);
            fclose(fileIn);
            fclose(fileOut);
            return 1;
        }
        if (len == cursor) cursor = 0;
        ch ^= *(secret + cursor++);
        fputc(ch, fileOut);
        if (ferror(fileOut)) {
            printErrMsg("xor_codec: failed to write file %s", outputFile);
            fclose(fileIn);
            fclose(fileOut);
            return 1;
        }
    }

    if (fclose(fileIn) == EOF) {
        printErrMsg("xor_codec: failed to close file %s", inputFile);
        return 1;
    }
    if (fclose(fileOut) == EOF) {
        printErrMsg("xor_codec: failed to close file %s", outputFile);
        return 1;
    }
    return 0;
}
