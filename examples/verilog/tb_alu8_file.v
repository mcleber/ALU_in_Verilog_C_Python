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
