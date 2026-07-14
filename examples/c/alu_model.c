#include "alu_model.h"

static uint8_t sign_bit(uint8_t value)
{
    // In 8 bits, bit 7 is the sign bit.
    return (value >> 7) & 1u;
}

alu_result_t alu_execute(uint8_t a, uint8_t b, alu_op_t op)
{
    alu_result_t out;

    // Initialize all flags to zero.
    out.result = 0;
    out.zero = 0;
    out.carry = 0;
    out.negative = 0;
    out.overflow = 0;

    switch (op)
    {
    case ALU_ADD:
    {
        // Temporarily use 16 bits to detect carry.
        uint16_t temp = (uint16_t)a + (uint16_t)b;
        out.result = (uint8_t)temp;
        out.carry = (temp > 0xFFu);

        // Overflow in signed addition:
        // if A and B have the same sign, but the result has a different sign.
        uint8_t sa = sign_bit(a);
        uint8_t sb = sign_bit(b);
        uint8_t sr = sign_bit(out.result);
        out.overflow = ((sa == sb) && (sa != sr));
        break;
    }

    case ALU_SUB:
    {
        out.result = (uint8_t)(a - b);

        // For subtraction, we treat carry as borrow.
        // If a < b, a borrow occurred.
        out.carry = (a < b);

        // Overflow in signed subtraction:
        // if A and B have different signs and the result changed relative to A.
        uint8_t sa = sign_bit(a);
        uint8_t sb = sign_bit(b);
        uint8_t sr = sign_bit(out.result);
        out.overflow = ((sa != sb) && (sa != sr));
        break;
    }

    case ALU_AND:
        out.result = a & b;
        break;

    case ALU_OR:
        out.result = a | b;
        break;

    case ALU_XOR:
        out.result = a ^ b;
        break;

    case ALU_NOT:
        // This operation uses only A.
        out.result = (uint8_t)(~a);
        break;

    case ALU_SHL:
        // Carry receives the bit shifted out on the left.
        out.carry = (a >> 7) & 1u;
        out.result = (uint8_t)(a << 1);
        break;

    case ALU_SHR:
        // Carry receives the bit shifted out on the right.
        out.carry = a & 1u;
        out.result = (uint8_t)(a >> 1);
        break;

    default:
        out.result = 0;
        break;
    }

    out.zero = (out.result == 0);
    out.negative = sign_bit(out.result);

    return out;
}
