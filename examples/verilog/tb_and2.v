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
