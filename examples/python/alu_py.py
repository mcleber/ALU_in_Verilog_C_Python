from dataclasses import dataclass


ALU_ADD = 0
ALU_SUB = 1
ALU_AND = 2
ALU_OR = 3
ALU_XOR = 4
ALU_NOT = 5
ALU_SHL = 6
ALU_SHR = 7


@dataclass
class AluResult:
    result: int
    zero: int
    carry: int
    negative: int
    overflow: int


def mask8(value: int) -> int:
    """Keeps only the 8 least significant bits."""
    return value & 0xFF


def sign_bit(value: int) -> int:
    """Returns bit 7, used as the sign bit in 8 bits."""
    return (value >> 7) & 1


def alu_execute(a: int, b: int, op: int) -> AluResult:
    """Executes one operation of the 8-bit ALU."""
    a = mask8(a)
    b = mask8(b)

    result = 0
    carry = 0
    overflow = 0

    if op == ALU_ADD:
        temp = a + b
        result = mask8(temp)
        carry = 1 if temp > 0xFF else 0

        sa = sign_bit(a)
        sb = sign_bit(b)
        sr = sign_bit(result)
        overflow = 1 if (sa == sb and sa != sr) else 0

    elif op == ALU_SUB:
        result = mask8(a - b)
        carry = 1 if a < b else 0

        sa = sign_bit(a)
        sb = sign_bit(b)
        sr = sign_bit(result)
        overflow = 1 if (sa != sb and sa != sr) else 0

    elif op == ALU_AND:
        result = a & b

    elif op == ALU_OR:
        result = a | b

    elif op == ALU_XOR:
        result = a ^ b

    elif op == ALU_NOT:
        result = mask8(~a)

    elif op == ALU_SHL:
        carry = sign_bit(a)
        result = mask8(a << 1)

    elif op == ALU_SHR:
        carry = a & 1
        result = a >> 1

    zero = 1 if result == 0 else 0
    negative = sign_bit(result)

    return AluResult(result, zero, carry, negative, overflow)
