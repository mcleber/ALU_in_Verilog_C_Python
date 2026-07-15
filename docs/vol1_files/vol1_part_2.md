
| Title | Part 2 — C  |
|-------|-------|
| File  | `vol1_part_2.md` |
| Date  | 13 Jul 2026 |

---

# Part 2 — C

## Chapter 4 — Basic C with a focus on hardware models

### 4.1 First program in C

File: `examples/c/hello.c`

```c
#include <stdio.h>

int main(void) {
    printf("Hello, C!\n");
    return 0;
}
```

Compile:

```bash
gcc -Wall -Wextra -std=c2x hello.c -o hello
./hello
```

### 4.2 Understanding the program

```c
#include <stdio.h>
```

Includes input and output functions, such as `printf`.

```c
int main(void)
```

It is the main function. Every C program starts from it.

```c
return 0;
```

Indicates that the program finished correctly.

### 4.3 Integer variables

File: `examples/c/integer.c`

```c
#include <stdio.h>

int main(void) {
    int a = 10;
    int b = 3;

    printf("a + b = %d\n", a + b);
    printf("a - b = %d\n", a - b);
    printf("a & b = %d\n", a & b);
    printf("a | b = %d\n", a | b);
    printf("a ^ b = %d\n", a ^ b);

    return 0;
}
```

This example is already close to an ALU, because an ALU performs precisely arithmetic and logic operations.

### 4.4 Useful operations for an ALU

| Operation          | C         | Description |
|-------------------|-----------|-------------|
| Addition          | `a + b`   | Adds two operands. |
| Subtraction       | `a - b`   | Subtracts the second operand from the first. |
| Multiplication    | `a * b`   | Multiplies two operands. |
| Division          | `a / b`   | Divides the first operand by the second (integer division for integers). |
| Modulus           | `a % b`   | Returns the remainder of an integer division. |
| Bitwise AND       | `a & b`   | Sets each bit to 1 only if both corresponding bits are 1. |
| Bitwise OR        | `a \| b`  | Sets each bit to 1 if at least one corresponding bit is 1. |
| Bitwise XOR       | `a ^ b`   | Sets each bit to 1 only if the corresponding bits are different. |
| Bitwise NOT       | `~a`      | Inverts every bit of the operand (1 becomes 0, 0 becomes 1). |
| Left Shift        | `a << 1`  | Shifts all bits to the left by one position, inserting zeros on the right. Equivalent to multiplying by 2 (when no overflow occurs). |
| Right Shift       | `a >> 1`  | Shifts all bits to the right by one position. For positive integers, it is equivalent to dividing by 2. |

### 4.5 Beware of data size

In hardware, size matters a lot.

An 8-bit ALU does not store just any value. It stores only 8 bits.

Example:

```text
255 + 1 = 256
```

But in 8 bits:

```text
11111111 + 00000001 = 00000000 with carry
```

In C, we can simulate this using `uint8_t`.

File: `examples/c/uint8_exemple.c`

```c
#include <stdint.h>
#include <stdio.h>

int main(void) {
    uint8_t a = 255;
    uint8_t b = 1;
    uint8_t result = a + b;

    // The result will be 0, because of an 8-bit overflow.
    printf("result = %u\n", result);

    return 0;
}
```

---

## Chapter 5 — Code organization in C

### 5.1 Why split files?

A small project can live in a single file. But larger projects need organization.

We will separate:

```text
.h -> declarations
.c -> implementation
```

### 5.2 Simple example: calculator

File: `examples/c/calc.h`

```c
#ifndef CALC_H
#define CALC_H

int add(int a, int b);
int sub(int a, int b);

#endif
```

File: `examples/c/calc.c`

```c
#include "calc.h"

int add(int a, int b) {
    return a + b;
}

int sub(int a, int b) {
    return a - b;
}
```

File: `examples/c/main_calc.c`

```c
#include <stdio.h>
#include "calc.h"

int main(void) {
    int a = 10;
    int b = 3;

    printf("add = %d\n", add(a, b));
    printf("sub = %d\n", sub(a, b));

    return 0;
}
```

Compilation:

```bash
gcc -Wall -Wextra -std=c2x main_calc.c calc.c -o main_calc
./main_calc
```

### 5.3 What is a header?

The `.h` file tells other files which functions exist.

The `.c` file contains how those functions work.

This helps organize and reuse code.

---

## Chapter 6 — Unit tests in C

### 6.1 What is a unit test?

A unit test verifies a small unit of the program.

Example:

```text
The function add(2, 3) must return 5.
```

We do not want to test everything at once. We want to test small pieces.

### 6.2 Testing with `assert`

File: `examples/c/test_calc.c`

```c
#include <assert.h>
#include <stdio.h>
#include "calc.h"

static void test_add(void) {
    assert(add(2, 3) == 5);
    assert(add(0, 0) == 0);
    assert(add(-1, 1) == 0);
}

static void test_sub(void) {
    assert(sub(10, 3) == 7);
    assert(sub(3, 10) == -7);
    assert(sub(0, 0) == 0);
}

int main(void) {
    test_add();
    test_sub();

    printf("All tests passed.\n");
    return 0;
}
```

Compile:

```bash
gcc -Wall -Wextra -std=c2x test_calc.c calc.c -o test_calc
./test_calc
```

### 6.3 How to read a test error?

If an `assert` condition fails, the program stops and shows where it failed.

For example:

```text
Assertion `add(2, 3) == 6' failed
```

This means:

```text
The test expected 6, but the function did not produce that behavior.
```

### 6.4 Why test C in this guide?

Because C will be used as the ALU reference.

If the C model is wrong, the Verilog testbench may compare against a wrong result.

Therefore, before trusting the C model, we test the C model.

---

## Chapter 7 — Reference model of the ALU in C

### 7.1 What is an ALU?

ALU means Arithmetic Logic Unit.

It receives operands and an operation.

```text
Input A
Input B
Operation code
```

And produces:

```text
Result
Flags
```

### 7.2 Operations of our ALU

Our ALU will have 8 operations:

| Code | Operation | Description |
| ---- | --------- | ----------- |
| 0    | ADD       | `A + B`     |
| 1    | SUB       | `A - B`     |
| 2    | AND       | `A & B`     |
| 3    | OR        | `A \| B`    |
| 4    | XOR       | `A ^ B`     |
| 5    | NOT       | `~A`        |
| 6    | SHL       | `A << 1`    |
| 7    | SHR       | `A >> 1`    |

The ALU will be 8 bits wide.

### 7.3 Flags

We will generate four flags:

```text
zero     -> result is zero
carry    -> there was a carry in addition or a borrow in subtraction
negative -> most significant bit of the result is 1
overflow -> signed arithmetic overflow
```

For an initial study, the most important thing is to understand `zero`, `carry`, and `negative`. The `overflow` flag is more advanced.

### 7.4 ALU header

File: `examples/c/alu_model.h`

```c
#ifndef ALU_MODEL_H
#define ALU_MODEL_H

#include <stdint.h>

// ALU operation codes.
typedef enum {
    ALU_ADD = 0,
    ALU_SUB = 1,
    ALU_AND = 2,
    ALU_OR  = 3,
    ALU_XOR = 4,
    ALU_NOT = 5,
    ALU_SHL = 6,
    ALU_SHR = 7
} alu_op_t;

// Complete ALU result.
typedef struct {
    uint8_t result;
    uint8_t zero;
    uint8_t carry;
    uint8_t negative;
    uint8_t overflow;
} alu_result_t;

alu_result_t alu_execute(uint8_t a, uint8_t b, alu_op_t op);

#endif
```

### 7.5 ALU implementation in C

File: `examples/c/alu_model.c`

```c
#include "alu_model.h"

static uint8_t sign_bit(uint8_t value) {
    // In 8 bits, bit 7 is the sign bit.
    return (value >> 7) & 1u;
}

alu_result_t alu_execute(uint8_t a, uint8_t b, alu_op_t op) {
    alu_result_t out;

    // Initialize all flags to zero.
    out.result = 0;
    out.zero = 0;
    out.carry = 0;
    out.negative = 0;
    out.overflow = 0;

    switch (op) {
        case ALU_ADD: {
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

        case ALU_SUB: {
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
```

### 7.6 ALU unit tests in C

File: `examples/c/test_alu_model.c`

```c
#include <assert.h>
#include <stdio.h>
#include "alu_model.h"

static void test_add_simple(void) {
    alu_result_t r = alu_execute(10, 20, ALU_ADD);

    assert(r.result == 30);
    assert(r.zero == 0);
    assert(r.carry == 0);
    assert(r.negative == 0);
}

static void test_add_carry(void) {
    alu_result_t r = alu_execute(255, 1, ALU_ADD);

    // 255 + 1 in 8 bits becomes 0 with carry.
    assert(r.result == 0);
    assert(r.zero == 1);
    assert(r.carry == 1);
}

static void test_sub_simple(void) {
    alu_result_t r = alu_execute(10, 3, ALU_SUB);

    assert(r.result == 7);
    assert(r.zero == 0);
    assert(r.carry == 0);
}

static void test_sub_borrow(void) {
    alu_result_t r = alu_execute(3, 10, ALU_SUB);

    // 3 - 10 in 8 bits produces 249.
    assert(r.result == 249);
    assert(r.carry == 1);
    assert(r.negative == 1);
}

static void test_logic_ops(void) {
    assert(alu_execute(0xF0, 0x0F, ALU_AND).result == 0x00);
    assert(alu_execute(0xF0, 0x0F, ALU_OR).result  == 0xFF);
    assert(alu_execute(0xAA, 0xFF, ALU_XOR).result == 0x55);
    assert(alu_execute(0x55, 0x00, ALU_NOT).result == 0xAA);
}

static void test_shift_ops(void) {
    alu_result_t shl = alu_execute(0x80, 0, ALU_SHL);
    assert(shl.result == 0x00);
    assert(shl.carry == 1);
    assert(shl.zero == 1);

    alu_result_t shr = alu_execute(0x01, 0, ALU_SHR);
    assert(shr.result == 0x00);
    assert(shr.carry == 1);
    assert(shr.zero == 1);
}

int main(void) {
    test_add_simple();
    test_add_carry();
    test_sub_simple();
    test_sub_borrow();
    test_logic_ops();
    test_shift_ops();

    printf("All ALU tests in C passed.\n");
    return 0;
}
```

Compile:

```bash
gcc -Wall -Wextra -std=c2x test_alu_model.c alu_model.c -o test_alu_model
./test_alu_model
```

### 7.7 Important lesson

At this point, we have not built any hardware yet.

But we already have something very valuable:

```text
A reliable model of the ALU in C.
```

This model will later be used to verify the ALU in Verilog.

---

## Chapter 8 — Concurrency and parallelism in C

### 8.1 Concurrency is not exactly parallelism

Concurrency means structuring the program into several tasks that can make progress independently.

Parallelism means executing tasks truly at the same time on multiple cores.

Simple example:

```text
Concurrency: a cook prepares rice while waiting for the water to boil.
Parallelism: two cooks work at the same time.
```

### 8.2 Threads in C with pthread

Threads share memory. This is useful, but dangerous if several threads modify the same variable.





---

← [Back to Index](../README_vol1.md)

Previous: [Part 1 — Fundamentals](vol1_part_1.md) | Next: [Part 3 — Python](vol1_part_3.md)
