#include <limits.h>
#include <stdio.h>

#include "bitwise.h"

static const unsigned char MASK = 1;

static void printByteInBinaryLeftToRight(const unsigned char byte) {
    for (int bit = CHAR_BIT - 1; bit >= 0; bit--) {
        printf("%d", byte >> bit & 1);
    }
}

static void printByteInBinaryRightToLeft(const unsigned char byte) {
    for (int bit = 0; bit < CHAR_BIT; bit++) {
        printf("%d", byte >> bit & 1);
    }
}

unsigned char BitMask(const unsigned char flag, const unsigned char index) { return MASK << index & flag; }

unsigned char BitOpen(const unsigned char flag, const unsigned char index) { return MASK << index | flag; }

unsigned char BitClose(const unsigned char flag, const unsigned char index) { return flag & ~(MASK << index); }

unsigned char BitToggle(const unsigned char flag, const unsigned char index) { return MASK << index ^ flag; }

_Bool BitCheck(const unsigned char flag, const unsigned char index) {
    const unsigned char mask = MASK << index;
    return (flag & mask) == mask;
}

void PrintBitFieldLayoutLeftToTight(const void* target, const size_t size) {
    if (!size || size < 0) return;
    if (!target) return;

    const unsigned char* ptr = (unsigned char*)target;
    for (size_t i = 0; i < size - 1; i++) {
        printByteInBinaryLeftToRight(ptr[i]);
        printf("_");
    }
    printByteInBinaryLeftToRight(ptr[size - 1]);
    printf("\n");
}

void PrintBitFieldLayoutRightToLeft(const void* target, const size_t size) {
    if (!size || size < 0) return;
    if (!target) return;

    const unsigned char* ptr = (unsigned char*)target;
    for (size_t i = 0; i < size - 1; i++) {
        printByteInBinaryRightToLeft(ptr[i]);
        printf("_");
    }
    printByteInBinaryRightToLeft(ptr[size - 1]);
    printf("\n");
}

void PrintBitFieldLayoutRightToLeftReverse(const void* target, const size_t size) {
    if (!size || size < 0) return;
    if (!target) return;

    const unsigned char* ptr = (unsigned char*)target;
    for (size_t i = size - 1;;) {
        printByteInBinaryRightToLeft(ptr[i]);
        if (!i) break;
        printf("_");
        i--;
    }
    printf("\n");
}

void PrintBitFieldLayoutLeftToRightReverse(const void* target, const size_t size) {
    if (!size || size < 0) return;
    if (!target) return;

    const unsigned char* ptr = (unsigned char*)target;
    for (size_t i = size - 1;;) {
        printByteInBinaryLeftToRight(ptr[i]);
        if (!i) break;
        printf("_");
        i--;
    }
    printf("\n");
}
