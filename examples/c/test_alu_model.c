#include <assert.h>
#include <stdio.h>
#include "alu_model.h"

static void test_add_simple(void)
{
    alu_result_t r = alu_execute(10, 20, ALU_ADD);

    assert(r.result == 30);
    assert(r.zero == 0);
    assert(r.carry == 0);
    assert(r.negative == 0);
}

static void test_add_carry(void)
{
    alu_result_t r = alu_execute(255, 1, ALU_ADD);

    // 255 + 1 in 8 bits becomes 0 with carry.
    assert(r.result == 0);
    assert(r.zero == 1);
    assert(r.carry == 1);
}

static void test_sub_simple(void)
{
    alu_result_t r = alu_execute(10, 3, ALU_SUB);

    assert(r.result == 7);
    assert(r.zero == 0);
    assert(r.carry == 0);
}

static void test_sub_borrow(void)
{
    alu_result_t r = alu_execute(3, 10, ALU_SUB);

    // 3 - 10 in 8 bits produces 249.
    assert(r.result == 249);
    assert(r.carry == 1);
    assert(r.negative == 1);
}

static void test_logic_ops(void)
{
    assert(alu_execute(0xF0, 0x0F, ALU_AND).result == 0x00);
    assert(alu_execute(0xF0, 0x0F, ALU_OR).result == 0xFF);
    assert(alu_execute(0xAA, 0xFF, ALU_XOR).result == 0x55);
    assert(alu_execute(0x55, 0x00, ALU_NOT).result == 0xAA);
}

static void test_shift_ops(void)
{
    alu_result_t shl = alu_execute(0x80, 0, ALU_SHL);
    assert(shl.result == 0x00);
    assert(shl.carry == 1);
    assert(shl.zero == 1);

    alu_result_t shr = alu_execute(0x01, 0, ALU_SHR);
    assert(shr.result == 0x00);
    assert(shr.carry == 1);
    assert(shr.zero == 1);
}

int main(void)
{
    test_add_simple();
    test_add_carry();
    test_sub_simple();
    test_sub_borrow();
    test_logic_ops();
    test_shift_ops();

    printf("All ALU tests in C passed.\n");
    return 0;
}
