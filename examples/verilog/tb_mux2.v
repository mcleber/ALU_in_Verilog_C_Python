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
