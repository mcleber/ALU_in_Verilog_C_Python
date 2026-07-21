<a id="top"></a>

| Title | Part 4 — Verilog  |
|-------|-------|
| File  | `vol1_part_4.md` |
| Date  | 21 Jul 2026 |

---

# Part 4 — Verilog

## Chapter 13 — Basic Verilog

### 13.1 First module

File: `examples/verilog/and2.v`

```verilog
// Two-input AND gate.
module and2 (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

### 13.2 Understanding the module

```verilog
module and2 (...);
```

Defines a hardware block named `and2`.

```verilog
input wire a;
```

Defines an input.

```verilog
output wire y;
```

Defines an output.

```verilog
assign y = a & b;
```

Creates a combinational connection.

### 13.3 Basic testbench

File: `examples/verilog/tb_and2.v`

```verilog
`timescale 1ns/1ps

module tb_and2;

    reg a;
    reg b;
    wire y;
    integer errors;

    and2 dut (
        .a(a),
        .b(b),
        .y(y)
    );

    task check;
        input expected;
        begin
            #1;
            if (y !== expected) begin
                $display("ERROR: a=%b b=%b y=%b expected=%b", a, b, y, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("and2.vcd");
        $dumpvars(0, tb_and2);

        a = 0; b = 0; check(0);
        a = 0; b = 1; check(0);
        a = 1; b = 0; check(0);
        a = 1; b = 1; check(1);

        if (errors == 0)
            $display("TEST OK: and2 passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

Compile:

```bash
iverilog -o tb_and2 and2.v tb_and2.v

vvp tb_and2
```

### 13.4 Important concept: DUT

DUT means:

```text
Device Under Test
```

That is, the circuit being tested.

In the testbench:

```verilog
and2 dut (...);
```

We are creating an instance of the `and2` module to test it.

---

## Chapter 14 — Basic and self-checking testbench

### 14.1 What is a testbench?

A testbench is simulation code that applies stimuli to the circuit and observes the outputs.

A typical testbench does three things:

```text
1. Generates inputs
2. Waits for the response
3. Checks whether the response is correct
```

### 14.2 Manual versus automated testbench

Manual:

```text
Look at the waveform and decide whether it is correct.
```

Automated:

```text
The testbench itself compares and prints PASS or FAIL.
```

We will prioritize the second.

### 14.3 Example: 2:1 MUX

File: `examples/verilog/mux2.v`

```verilog
module mux2 (
    input  wire a,
    input  wire b,
    input  wire sel,
    output reg  y
);

    always @(*) begin
        if (sel == 1'b0)
            y = a;
        else
            y = b;
    end

endmodule
```

Testbench: `examples/verilog/tb_mux2.v`

```verilog
`timescale 1ns/1ps

module tb_mux2;

    reg a;
    reg b;
    reg sel;
    wire y;
    integer errors;

    mux2 dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    task check;
        input expected;
        begin
            #1;
            if (y !== expected) begin
                $display("ERROR: a=%b b=%b sel=%b y=%b expected=%b", a, b, sel, y, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("mux2.vcd");
        $dumpvars(0, tb_mux2);

        a = 0; b = 1; sel = 0; check(0);
        a = 0; b = 1; sel = 1; check(1);
        a = 1; b = 0; sel = 0; check(1);
        a = 1; b = 0; sel = 1; check(0);

        if (errors == 0)
            $display("TEST OK: mux2 passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

Compile:

```bash
iverilog -o tb_mux2 mux2.v tb_mux2.v

vvp tb_mux2
```

### 14.4 What is a task?

A `task` in Verilog allows reusing code inside the testbench.

Instead of writing several times:

```verilog
#1;
if (y !== expected) begin
    ...
end
```

We create a `check` task.

This makes the testbench cleaner.

---

## Chapter 15 — Combinational logic

### 15.1 What is combinational logic?

Combinational logic has no memory.

The output depends only on the current inputs.

Examples:

```text
AND
OR
XOR
MUX
adder
comparator
combinational ALU
```

### 15.2 Always initialize outputs in

`always @(*)`

Dangerous example:

```verilog
always @(*) begin
    if (sel)
        y = a;
end
```

If `sel` is zero, `y` never receives a value. This can create an unwanted latch.

Better:

```verilog
always @(*) begin
    y = 0;

    if (sel)
        y = a;
end
```

### 15.3 Simple comparator

File: `examples/verilog/compare8.v`

```verilog
module compare8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire       eq,
    output wire       gt,
    output wire       lt
);

    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);

endmodule
```

Testbench: `examples/verilog/tb_compare8.v`

```verilog
`timescale 1ns/1ps

module tb_compare8;

    reg [7:0] a;
    reg [7:0] b;
    wire eq;
    wire gt;
    wire lt;
    integer errors;

    compare8 dut (
        .a(a), 
        .b(b), 
        .eq(eq), 
        .gt(gt), 
        .lt(lt)
    );

    task check;
        input expected_eq;
        input expected_gt;
        input expected_lt;
        begin
            #1;
            if (eq !== expected_eq || gt !== expected_gt || lt !== expected_lt) begin
                $display("ERROR: a=%0d b=%0d eq=%b gt=%b lt=%b", a, b, eq, gt, lt);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("compare8.vcd");
        $dumpvars(0, tb_compare8);

        a = 10; b = 10; check(1, 0, 0);
        a = 20; b = 10; check(0, 1, 0);
        a = 5;  b = 10; check(0, 0, 1);

        if (errors == 0)
            $display("TEST OK: compare8 passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

Compile:

```bash
iverilog -o tb_compare8 compare8.v tb_compare8.v

vvp tb_compare8
```

---

## Chapter 16 — Sequential logic

### 16.1 What is sequential logic?

Sequential logic uses memory.

Example:

```text
a register stores a value
a counter remembers the previous count
an FSM remembers the current state
```

### 16.2 8-bit register

File: `examples/verilog/reg8.v`

```verilog
module reg8 (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    input  wire [7:0] d,
    output reg  [7:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= 8'h00;
        else if (en)
            q <= d;
    end

endmodule
```

File: `examples/verilog/tb_reg8.v`

```verilog
`timescale 1ns/1ps

module tb_reg8;

    reg clk;
    reg rst;
    reg en;
    reg [7:0] d;
    wire [7:0] q;
    integer errors;

    reg8 dut (
        .clk(clk), 
        .rst(rst), 
        .en(en), 
        .d(d), 
        .q(q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check;
        input [7:0] expected;
        begin
            #1;
            if (q !== expected) begin
                $display("ERROR: q=%h expected=%h", q, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        rst = 1;
        en = 0;
        d = 8'hAA;

        @(posedge clk);
        check(8'h00);

        rst = 0;
        en = 1;
        d = 8'h55;

        @(posedge clk);
        check(8'h55);

        en = 0;
        d = 8'hFF;

        @(posedge clk);
        check(8'h55);

        if (errors == 0)
            $display("TEST OK: reg8 passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

### 16.4 Difference between `=` and `<=`

Use `=` in combinational logic:

```verilog
always @(*) begin
    y = a & b;
end
```

Use `<=` in sequential logic:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

This rule avoids many bugs.

---

## Chapter 17 — Combinational ALU in Verilog

### 17.1 ALU interface

Our ALU in Verilog will have:

```text
a        8-bit input
b        8-bit input
op       3-bit operation
result   8-bit result
zero     zero flag
carry    carry/borrow flag
negative negative flag
overflow overflow flag
```

### 17.2 ALU code

File: `examples/verilog/alu8.v`

```verilog
module alu8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] result,
    output reg        zero,
    output reg        carry,
    output reg        negative,
    output reg        overflow
);

    localparam ALU_ADD = 3'd0;
    localparam ALU_SUB = 3'd1;
    localparam ALU_AND = 3'd2;
    localparam ALU_OR  = 3'd3;
    localparam ALU_XOR = 3'd4;
    localparam ALU_NOT = 3'd5;
    localparam ALU_SHL = 3'd6;
    localparam ALU_SHR = 3'd7;

    reg [8:0] temp;

    always @(*) begin
        // Default values avoid unwanted latches.
        result = 8'h00;
        zero = 1'b0;
        carry = 1'b0;
        negative = 1'b0;
        overflow = 1'b0;
        temp = 9'h000;

        case (op)
            ALU_ADD: begin
                temp = {1'b0, a} + {1'b0, b};
                result = temp[7:0];
                carry = temp[8];

                // Signed addition overflow.
                overflow = (~(a[7] ^ b[7])) & (a[7] ^ result[7]);
            end

            ALU_SUB: begin
                result = a - b;
                carry = (a < b); // borrow

                // Signed subtraction overflow.
                overflow = (a[7] ^ b[7]) & (a[7] ^ result[7]);
            end

            ALU_AND: begin
                result = a & b;
            end

            ALU_OR: begin
                result = a | b;
            end

            ALU_XOR: begin
                result = a ^ b;
            end

            ALU_NOT: begin
                result = ~a;
            end

            ALU_SHL: begin
                carry = a[7];
                result = a << 1;
            end

            ALU_SHR: begin
                carry = a[0];
                result = a >> 1;
            end

            default: begin
                result = 8'h00;
            end
        endcase

        zero = (result == 8'h00);
        negative = result[7];
    end

endmodule
```

### 17.3 Basic ALU testbench

File: `examples/verilog/tb_alu8_basic.v`

```verilog
`timescale 1ns/1ps

module tb_alu8_basic;

    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] op;

    wire [7:0] result;
    wire zero;
    wire carry;
    wire negative;
    wire overflow;

    integer errors;

    alu8 dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow)
    );

    task check;
        input [7:0] expected_result;
        input expected_zero;
        input expected_carry;
        input expected_negative;
        input expected_overflow;
        begin
            #1;
            if (result !== expected_result ||
                zero !== expected_zero ||
                carry !== expected_carry ||
                negative !== expected_negative ||
                overflow !== expected_overflow) begin

                $display("ERROR: a=%h b=%h op=%0d result=%h expected=%h", a, b, op, result, expected_result);
                $display("      flags: z=%b c=%b n=%b v=%b expected z=%b c=%b n=%b v=%b",
                    zero, carry, negative, overflow,
                    expected_zero, expected_carry, expected_negative, expected_overflow);

                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("alu8_basic.vcd");
        $dumpvars(0, tb_alu8_basic);

        // ADD: 10 + 20 = 30
        a = 8'd10; b = 8'd20; op = 3'd0;
        check(8'd30, 0, 0, 0, 0);

        // ADD with carry: 255 + 1 = 0 with carry
        a = 8'd255; b = 8'd1; op = 3'd0;
        check(8'd0, 1, 1, 0, 0);

        // SUB: 10 - 3 = 7
        a = 8'd10; b = 8'd3; op = 3'd1;
        check(8'd7, 0, 0, 0, 0);

        // SUB with borrow: 3 - 10 = 249
        a = 8'd3; b = 8'd10; op = 3'd1;
        check(8'd249, 0, 1, 1, 0);

        // AND
        a = 8'hF0; b = 8'h0F; op = 3'd2;
        check(8'h00, 1, 0, 0, 0);

        // OR
        a = 8'hF0; b = 8'h0F; op = 3'd3;
        check(8'hFF, 0, 0, 1, 0);

        // XOR
        a = 8'hAA; b = 8'hFF; op = 3'd4;
        check(8'h55, 0, 0, 0, 0);

        // NOT
        a = 8'h55; b = 8'h00; op = 3'd5;
        check(8'hAA, 0, 0, 1, 0);

        // SHL
        a = 8'h80; b = 8'h00; op = 3'd6;
        check(8'h00, 1, 1, 0, 0);

        // SHR
        a = 8'h01; b = 8'h00; op = 3'd7;
        check(8'h00, 1, 1, 0, 0);

        if (errors == 0)
            $display("TEST OK: basic ALU passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

Compile:

```bash
iverilog -o tb_alu8_basic alu8.v tb_alu8_basic.v

vvp tb_alu8_basic
```

### 17.4 What does this testbench teach?

It teaches:

- how to instantiate the ALU;
- how to apply inputs;
- how to compare outputs;
- how to test flags;
- how to create a verification task;
- how to detect errors automatically.

But it still has a limitation: the cases are written manually.

In the next chapter, we will automate further.

---

## Chapter 18 — Automated testbench with a vector file

### 18.1 Idea

Instead of writing each test manually in Verilog, we will use a file:

```text
A B OP RESULT ZERO CARRY NEGATIVE OVERFLOW
```

The testbench reads each line, applies it to the ALU, and compares.

### 18.2 Example vector file

File: `examples/verilog/alu_vectors.txt`

```text
0A 14 0 1E 0 0 0 0
FF 01 0 00 1 1 0 0
0A 03 1 07 0 0 0 0
03 0A 1 F9 0 1 1 0
F0 0F 2 00 1 0 0 0
F0 0F 3 FF 0 0 1 0
AA FF 4 55 0 0 0 0
55 00 5 AA 0 0 1 0
80 00 6 00 1 1 0 0
01 00 7 00 1 1 0 0
```

### 18.3 Automated testbench

File: `examples/verilog/tb_alu8_file.v`

```verilog
`timescale 1ns/1ps

module tb_alu8_file;

    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] op;

    wire [7:0] result;
    wire zero;
    wire carry;
    wire negative;
    wire overflow;

    integer file;
    integer scan_count;
    integer total;
    integer errors;

    reg [7:0] expected_result;
    reg expected_zero;
    reg expected_carry;
    reg expected_negative;
    reg expected_overflow;

    alu8 dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow)
    );

    initial begin
        total = 0;
        errors = 0;

        $dumpfile("alu8_file.vcd");
        $dumpvars(0, tb_alu8_file);

        file = $fopen("alu_vectors.txt", "r");

        if (file == 0) begin
            $display("ERROR: could not open alu_vectors.txt");
            $finish;
        end

        while (!$feof(file)) begin
            scan_count = $fscanf(
                file,
                "%h %h %h %h %b %b %b %b\n",
                a,
                b,
                op,
                expected_result,
                expected_zero,
                expected_carry,
                expected_negative,
                expected_overflow
            );

            if (scan_count == 8) begin
                #1;
                total = total + 1;

                if (result !== expected_result ||
                    zero !== expected_zero ||
                    carry !== expected_carry ||
                    negative !== expected_negative ||
                    overflow !== expected_overflow) begin

                    errors = errors + 1;

                    $display("FAIL line %0d: a=%h b=%h op=%0d", total, a, b, op);
                    $display("  got      result=%h z=%b c=%b n=%b v=%b",
                        result, zero, carry, negative, overflow);
                    $display("  expected result=%h z=%b c=%b n=%b v=%b",
                        expected_result, expected_zero, expected_carry, expected_negative, expected_overflow);
                end
            end
        end

        $fclose(file);

        if (errors == 0)
            $display("TEST OK: %0d vectors passed.", total);
        else
            $display("TEST FAILED: %0d error(s) in %0d vector(s).", errors, total);

        $finish;
    end

endmodule
```

Compile:

```bash
iverilog -o tb_alu8_file alu8.v tb_alu8_file.v

vvp tb_alu8_file
```

### 18.4 What does this chapter teach?

This chapter is central to learning verification.

It teaches that the testbench can:

- read data from a file;
- run tens, hundreds, or thousands of tests;
- compare automatically;
- report exactly which case failed.

This is the path from small examples to more serious verification.

---

## Chapter 19 — Simple FSM

FSM means Finite State Machine.

An FSM has:

```text
states
inputs
outputs
transition rules
```

Everyday example:

```text
State: idle
If start = 1, go to working
When it finishes, go to ready
Then go back to idle
```

### 19.2 Simple FSM to control an ALU

We will create an FSM that receives `start`, waits one cycle, and asserts `done`.

States:

```text
IDLE -> waits for start
EXEC -> executes the operation
DONE -> signals completion
```

### 19.3 Simple FSM code

File: `examples/verilog/alu_fsm_simple.v`

```verilog
module alu_fsm_simple (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  enable_alu,
    output reg  done
);

    localparam IDLE = 2'd0;
    localparam EXEC = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    // State register.
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = EXEC;
            end

            EXEC: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic.
    always @(*) begin
        enable_alu = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                enable_alu = 1'b0;
                done = 1'b0;
            end

            EXEC: begin
                enable_alu = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule
```

### 19.4 Simple FSM testbench

File: `examples/verilog/tb_alu_fsm_simple.v`

```verilog
`timescale 1ns/1ps

module tb_alu_fsm_simple;

    reg clk;
    reg rst;
    reg start;
    wire enable_alu;
    wire done;
    integer errors;

    alu_fsm_simple dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .enable_alu(enable_alu),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check;
        input expected_enable;
        input expected_done;
        begin
            #1;
            if (enable_alu !== expected_enable || done !== expected_done) begin
                $display("ERROR: enable=%b done=%b expected enable=%b done=%b",
                    enable_alu, done, expected_enable, expected_done);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("alu_fsm_simple.vcd");
        $dumpvars(0, tb_alu_fsm_simple);

        rst = 1;
        start = 0;

        @(posedge clk);
        check(0, 0);

        rst = 0;

        // IDLE state.
        @(posedge clk);
        check(0, 0);

        // Apply start.
        start = 1;
        @(posedge clk);
        start = 0;

        // EXEC state.
        check(1, 0);

        @(posedge clk);
        // DONE state.
        check(0, 1);

        @(posedge clk);
        // Back to IDLE.
        check(0, 0);

        if (errors == 0)
            $display("TEST OK: simple FSM passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

```bash
iverilog -o tb_alu_fsm_simple alu_fsm_simple.v tb_alu_fsm_simple.v

vvp tb_alu_fsm_simple
```

### 19.5 What did we learn?

We learned to split an FSM into three blocks:

```text
1. current state
2. next state
3. outputs
```

This organization makes the design clearer and reduces errors.

---

### Chapter 20 — Advanced FSM

### 20.1 What makes an FSM more advanced?

An FSM becomes more advanced when it needs to handle:

- `valid/ready` handshake;
- variable latency;
- waiting for a busy resource;
- input and output registers;
- cancellation;
- errors;
- multiple execution cycles.

### 20.2 Sequential ALU with handshake

Now we will create a more realistic controller for the ALU.

Inputs:

```text
in_valid   -> the input has valid data
out_ready  -> the consumer is ready to receive the result
```

Outputs:

```text
in_ready   -> the controller can accept input
out_valid  -> the output has a valid result
busy       -> the controller is busy
```

An input transfer occurs when:

```text
in_valid && in_ready
```

An output transfer occurs when:

```text
out_valid && out_ready
```

### 20.3 States of the advanced FSM

```text
IDLE        waits for valid input
LOAD        captures operands
EXEC        executes the operation
WAIT_READY  holds the result until the consumer accepts it
```

### 20.4 Code of the sequential ALU with the advanced FSM

File: `examples/verilog/alu8_seq.v`

```verilog
module alu8_seq (
    input  wire       clk,
    input  wire       rst,

    input  wire       in_valid,
    output reg        in_ready,
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [2:0] op_in,

    output reg        out_valid,
    input  wire       out_ready,
    output reg  [7:0] result_out,
    output reg        zero_out,
    output reg        carry_out,
    output reg        negative_out,
    output reg        overflow_out,
    output reg        busy
);

    localparam IDLE       = 2'd0;
    localparam EXEC       = 2'd1;
    localparam WAIT_READY = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    reg [7:0] a_reg;
    reg [7:0] b_reg;
    reg [2:0] op_reg;

    wire [7:0] alu_result;
    wire alu_zero;
    wire alu_carry;
    wire alu_negative;
    wire alu_overflow;

    alu8 alu_core (
        .a(a_reg),
        .b(b_reg),
        .op(op_reg),
        .result(alu_result),
        .zero(alu_zero),
        .carry(alu_carry),
        .negative(alu_negative),
        .overflow(alu_overflow)
    );

    // Current state.
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Input capture and registered output.
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 8'h00;
            b_reg <= 8'h00;
            op_reg <= 3'd0;
            result_out <= 8'h00;
            zero_out <= 1'b0;
            carry_out <= 1'b0;
            negative_out <= 1'b0;
            overflow_out <= 1'b0;
        end else begin
            // Accept a new input only when the input handshake occurs.
            if (in_valid && in_ready) begin
                a_reg <= a_in;
                b_reg <= b_in;
                op_reg <= op_in;
            end

            // Register the result when leaving the EXEC state.
            if (state == EXEC) begin
                result_out <= alu_result;
                zero_out <= alu_zero;
                carry_out <= alu_carry;
                negative_out <= alu_negative;
                overflow_out <= alu_overflow;
            end
        end
    end

    // Next state.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (in_valid)
                    next_state = EXEC;
            end

            EXEC: begin
                next_state = WAIT_READY;
            end

            WAIT_READY: begin
                if (out_ready)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Control outputs.
    always @(*) begin
        in_ready = 1'b0;
        out_valid = 1'b0;
        busy = 1'b0;

        case (state)
            IDLE: begin
                in_ready = 1'b1;
                out_valid = 1'b0;
                busy = 1'b0;
            end

            EXEC: begin
                in_ready = 1'b0;
                out_valid = 1'b0;
                busy = 1'b1;
            end

            WAIT_READY: begin
                in_ready = 1'b0;
                out_valid = 1'b1;
                busy = 1'b1;
            end
        endcase
    end

endmodule
```

### 20.5 Important observation about this FSM

This FSM has a handshake, but it still executes one operation at a time.

This is educational and realistic for learning.

Later, you can evolve it into:

```text
pipeline
input queue
output queue
multiple ALUs
operations with different latencies
```

### 20.6 Advanced FSM testbench

File: `examples/verilog/tb_alu8_seq.v`

```verilog
`timescale 1ns/1ps

module tb_alu8_seq;

    reg clk;
    reg rst;
    reg in_valid;
    wire in_ready;
    reg [7:0] a_in;
    reg [7:0] b_in;
    reg [2:0] op_in;

    wire out_valid;
    reg out_ready;
    wire [7:0] result_out;
    wire zero_out;
    wire carry_out;
    wire negative_out;
    wire overflow_out;
    wire busy;

    integer errors;

    alu8_seq dut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .a_in(a_in),
        .b_in(b_in),
        .op_in(op_in),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .result_out(result_out),
        .zero_out(zero_out),
        .carry_out(carry_out),
        .negative_out(negative_out),
        .overflow_out(overflow_out),
        .busy(busy)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task send_op;
        input [7:0] a;
        input [7:0] b;
        input [2:0] op;
        begin
            // Wait for the circuit to be ready for input.
            while (in_ready !== 1'b1)
                @(posedge clk);

            a_in = a;
            b_in = b;
            op_in = op;
            in_valid = 1'b1;

            @(posedge clk);
            #1;
            in_valid = 1'b0;
        end
    endtask

    task expect_result;
        input [7:0] expected_result;
        input expected_zero;
        input expected_carry;
        input expected_negative;
        input expected_overflow;
        begin
            // Wait for the result to become valid.
            while (out_valid !== 1'b1)
                @(posedge clk);

            #1;
            if (result_out !== expected_result ||
                zero_out !== expected_zero ||
                carry_out !== expected_carry ||
                negative_out !== expected_negative ||
                overflow_out !== expected_overflow) begin

                $display("ERROR: result=%h expected=%h", result_out, expected_result);
                errors = errors + 1;
            end

            // The consumer accepts the result.
            out_ready = 1'b1;
            @(posedge clk);
            #1;
            out_ready = 1'b0;
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("alu8_seq.vcd");
        $dumpvars(0, tb_alu8_seq);

        rst = 1;
        in_valid = 0;
        out_ready = 0;
        a_in = 0;
        b_in = 0;
        op_in = 0;

        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        // ADD: 10 + 20 = 30
        send_op(8'd10, 8'd20, 3'd0);
        expect_result(8'd30, 0, 0, 0, 0);

        // ADD with carry: 255 + 1 = 0
        send_op(8'd255, 8'd1, 3'd0);
        expect_result(8'd0, 1, 1, 0, 0);

        // AND
        send_op(8'hF0, 8'h0F, 3'd2);
        expect_result(8'h00, 1, 0, 0, 0);

        if (errors == 0)
            $display("TEST OK: sequential ALU with advanced FSM passed.");
        else
            $display("TEST FAILED: %0d error(s).", errors);

        $finish;
    end

endmodule
```

```bash
iverilog -o tb_alu8_seq alu8_seq.v alu8.v tb_alu8_seq.v

vvp tb_alu8_seq
```

### 20.7 What does this testbench teach?

It teaches important concepts:

- waiting for `in_ready`;
- sending `in_valid`;
- waiting for `out_valid`;
- applying `out_ready`;
- testing a circuit with timing control;
- using tasks to make the testbench readable.

This is much closer to a real project.

---

← [Back to Index](../README_vol1.md) | [↑ Back to top](#top)

Previous: [Part 3 — Python](vol1_part_3.md) | Next: [Part 5 — Integrated project](vol1_part_5.md)
