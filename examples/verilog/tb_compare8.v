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
