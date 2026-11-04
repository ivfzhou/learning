#include "enumeration.h"

enum Level {
    LOW = 100,
    MEDIUM = 500,
    HIGH = 2000,
    HIGHEST /* 值为 2001 */
};

enum Week TestEnumeration(void) {
    enum InnerWeek { INNER_MON, INNER_TUES, INNER_WED, INNER_THURS, INNER_FRI, INNER_SAT, INNER_SUN };
    enum InnerWeek w = INNER_TUES;
    return (enum Week)w;
}
