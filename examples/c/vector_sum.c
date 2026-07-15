#include "vector_sum.h"

long long vector_sum(const int *v, size_t n)
{
    long long sum = 0;

    for (size_t i = 0; i < n; i++)
    {
        sum += v[i];
    }

    return sum;
}
