#include <assert.h>
#include <stdio.h>
#include "vector_sum.h"

int main(void)
{
    int a[] = {1, 2, 3, 4};
    int b[] = {-1, 1, -2, 2};

    assert(vector_sum(a, 4) == 10);
    assert(vector_sum(b, 4) == 0);

    printf("vector_sum test passed.\n");
    return 0;
}
