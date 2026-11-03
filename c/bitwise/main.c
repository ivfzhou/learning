#include <stdio.h>

#include "bitwise.h"

int main(const int argc, const char* argv[]) {
    int x = 1;
    printf("int 1 layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&x, sizeof(x));

    x = -1;
    printf("int -1 layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&x, sizeof(x));

    x = -2;
    printf("int -2 layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&x, sizeof(x));

    struct {
        int x;
        float y;
    } s = {.x = 1, .y = 1.1f};
    printf("struct{int, float} layout ");
    PrintBitFieldLayoutLeftToRightReverse((unsigned char*)&s, sizeof(s));

    return 0;
}
