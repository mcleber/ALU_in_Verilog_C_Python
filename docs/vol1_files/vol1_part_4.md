| Title | Part 4 — Verilog  |
|-------|-------|
| File  | `vol1_part_4.md` |
| Date  | 20 Jul 2026 |

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

    compare8 dut (.a(a), .b(b), .eq(eq), .gt(gt), .lt(lt));

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

    reg8 dut (.clk(clk), .rst(rst), .en(en), .d(d), .q(q));

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








---

← [Back to Index](../README_vol1.md)

Previous: [Part 3 — Python](vol1_part_3.md) | Next: [Part 5 — Integrated project](vol1_part_5.md)


