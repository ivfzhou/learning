#ifndef CN_IVFZHOU_C_VARIABLE_H
#define CN_IVFZHOU_C_VARIABLE_H

#include "export.h"

extern int FileVar;

extern const int FileConstVar;

extern volatile int FileVolatileVar;

extern volatile const int FileVolatileConstVar;

extern int* restrict FileRestrictPtr;

extern _Thread_local int FileThreadVar;

C_API void TestVariable(void);

#endif
