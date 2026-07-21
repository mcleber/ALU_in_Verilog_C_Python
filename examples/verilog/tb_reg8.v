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
