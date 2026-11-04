#include <stdio.h>

#include "flow_statement.h"

void TestFlowStatement(void) {
    // if () { ... } else if () { ... } else { ... }
    // switch () { case n: break; default: }
    // while () { ... }
    // do { ... } while();
    // for (;;) { ... }
    // goto flag;

    // 跨块跳转。
    goto F1;
    {
        printf("not print\n");
    F1:
        {
            printf("print\n");
        }
    }
}
