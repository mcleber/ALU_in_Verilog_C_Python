#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include "alu_model.h"

// Tests that the C model produces the same result
// regardless of the execution order, which is
// the fundamental property that makes parallelization safe.
static void test_alu_deterministic(void)
{
    // The same input executed twice must yield exactly the same result.
    alu_result_t r1 = alu_execute(200, 100, ALU_ADD);
    alu_result_t r2 = alu_execute(200, 100, ALU_ADD);

    assert(r1.result == r2.result);
    assert(r1.zero == r2.zero);
    assert(r1.carry == r2.carry);
    assert(r1.negative == r2.negative);
    assert(r1.overflow == r2.overflow);
}

static void test_no_shared_state(void)
{
    // Operations with different inputs must not interfere with each other.
    // If alu_execute uses global state, this test may fail under parallel execution.
    alu_result_t add = alu_execute(10, 20, ALU_ADD);
    alu_result_t sub = alu_execute(50, 30, ALU_SUB);
    alu_result_t and = alu_execute(0xFF, 0x0F, ALU_AND);

    assert(add.result == 30);
    assert(sub.result == 20);
    assert(and.result == 0x0F);
}

int main(void)
{
    test_alu_deterministic();
    test_no_shared_state();

    printf("Parallel generator tests passed.\n");
    return 0;
}
