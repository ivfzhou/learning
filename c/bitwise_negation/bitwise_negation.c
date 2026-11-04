#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bitwise_negation.h"

#define BUF_LEN (128 * 1024)

static void printErrMsg(const char* format, const char* filename) {
    const size_t len = strlen(format) + strlen(filename) + 1;
    char* msg = malloc(len);
    if (!msg) {
        char fallback[256];
        snprintf(fallback, sizeof(fallback), format, filename);
        perror(fallback);
        return;
    }
    snprintf(msg, len, format, filename);
    perror(msg);
    free(msg);
}

int BitwiseNegation(const char* filename) {
    FILE* file = fopen(filename, "r+b");
    if (!file) {
        printErrMsg("bitwise_negation: failed to open file %s", filename);
        return 1;
    }

    char buf[BUF_LEN];
    while (1) {
        const size_t len = fread(buf, sizeof(char), BUF_LEN, file);
        if (ferror(file)) {
            printErrMsg("bitwise_negation: failed to read file data %s", filename);
            fclose(file);
            return 1;
        }
        if (len <= 0) break;

        for (size_t i = 0; i < len; i++) buf[i] = ~buf[i];

        if (fseek(file, -(long)len, SEEK_CUR)) {
            printErrMsg("bitwise_negation: failed to seek file position %s", filename);
            fclose(file);
            return 1;
        }
        if (fwrite(buf, sizeof(char), len, file) != len) {
            printErrMsg("bitwise_negation: failed to write file data %s", filename);
            fclose(file);
            return 1;
        }
        if (fflush(file) == EOF) {
            printErrMsg("bitwise_negation: failed to flush file %s", filename);
            fclose(file);
            return 1;
        }

        if (len < BUF_LEN) break;
    }

    if (fclose(file) == EOF) {
        printErrMsg("bitwise_negation: failed to close file %s", filename);
        return 1;
    }

    return 0;
}
