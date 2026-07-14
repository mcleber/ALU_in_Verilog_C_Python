#include <assert.h>
#include <stdio.h>
#include "calc.h"

static void test_add(void)
{
    assert(add(2, 3) == 5);
    assert(add(0, 0) == 0);
    assert(add(-1, 1) == 0);
}

static void test_sub(void)
{
    assert(sub(10, 3) == 5);
    assert(sub(3, 10) == -7);
    assert(sub(0, 0) == 0);
}

int main(void)
{
    test_add();
    test_sub();

    printf("All tests passed.\n");

    return 0;
}
