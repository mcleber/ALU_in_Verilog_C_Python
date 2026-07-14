#include <stdint.h>
#include <stdio.h>

int main(void)
{
    uint8_t a = 255;
    uint8_t b = 1;
    uint8_t result = a + b;

    // The result will be 0, because of an 8-bit overflow.
    printf("result = %u\n", result);

    return 0;
}
