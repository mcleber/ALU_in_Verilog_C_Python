#ifndef GEN_VECTORS_PARALLEL_H
#define GEN_VECTORS_PARALLEL_H

#include <stdint.h>
#include <stddef.h>

// Represents one test-vector line.
typedef struct
{
    uint8_t a;
    uint8_t b;
    uint8_t op;
    uint8_t expected_result;
    uint8_t zero;
    uint8_t carry;
    uint8_t negative;
    uint8_t overflow;
} vector_entry_t;

// Result of generating a block of vectors.
typedef struct
{
    vector_entry_t *entries;
    size_t count;
} vector_block_t;

#endif
