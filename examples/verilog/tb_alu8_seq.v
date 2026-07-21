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
