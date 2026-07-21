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
