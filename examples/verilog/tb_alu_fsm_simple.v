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
