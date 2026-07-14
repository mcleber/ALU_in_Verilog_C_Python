#ifndef ALU_MODEL_H
#define ALU_MODEL_H

#include <stdint.h>

// ALU operation codes.
typedef enum
{
    ALU_ADD = 0,
    ALU_SUB = 1,
    ALU_AND = 2,
    ALU_OR = 3,
    ALU_XOR = 4,
    ALU_NOT = 5,
    ALU_SHL = 6,
    ALU_SHR = 7
} alu_op_t;

// Complete ALU result.
typedef struct
{
    uint8_t result;
    uint8_t zero;
    uint8_t carry;
    uint8_t negative;
    uint8_t overflow;
} alu_result_t;

alu_result_t alu_execute(uint8_t a, uint8_t b, alu_op_t op);

#endif
