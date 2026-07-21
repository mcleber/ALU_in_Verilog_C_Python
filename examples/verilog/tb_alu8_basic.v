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
