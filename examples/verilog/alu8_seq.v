module alu8_seq (
    input  wire       clk,
    input  wire       rst,

    input  wire       in_valid,
    output reg        in_ready,
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [2:0] op_in,

    output reg        out_valid,
    input  wire       out_ready,
    output reg  [7:0] result_out,
    output reg        zero_out,
    output reg        carry_out,
    output reg        negative_out,
    output reg        overflow_out,
    output reg        busy
);

    localparam IDLE       = 2'd0;
    localparam EXEC       = 2'd1;
    localparam WAIT_READY = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    reg [7:0] a_reg;
    reg [7:0] b_reg;
    reg [2:0] op_reg;

    wire [7:0] alu_result;
    wire alu_zero;
    wire alu_carry;
    wire alu_negative;
    wire alu_overflow;

    alu8 alu_core (
        .a(a_reg),
        .b(b_reg),
        .op(op_reg),
        .result(alu_result),
        .zero(alu_zero),
        .carry(alu_carry),
        .negative(alu_negative),
        .overflow(alu_overflow)
    );

    // Current state.
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Input capture and registered output.
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 8'h00;
            b_reg <= 8'h00;
            op_reg <= 3'd0;
            result_out <= 8'h00;
            zero_out <= 1'b0;
            carry_out <= 1'b0;
            negative_out <= 1'b0;
            overflow_out <= 1'b0;
        end else begin
            // Accept a new input only when the input handshake occurs.
            if (in_valid && in_ready) begin
                a_reg <= a_in;
                b_reg <= b_in;
                op_reg <= op_in;
            end

            // Register the result when leaving the EXEC state.
            if (state == EXEC) begin
                result_out <= alu_result;
                zero_out <= alu_zero;
                carry_out <= alu_carry;
                negative_out <= alu_negative;
                overflow_out <= alu_overflow;
            end
        end
    end

    // Next state.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (in_valid)
                    next_state = EXEC;
            end

            EXEC: begin
                next_state = WAIT_READY;
            end

            WAIT_READY: begin
                if (out_ready)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Control outputs.
    always @(*) begin
        in_ready = 1'b0;
        out_valid = 1'b0;
        busy = 1'b0;

        case (state)
            IDLE: begin
                in_ready = 1'b1;
                out_valid = 1'b0;
                busy = 1'b0;
            end

            EXEC: begin
                in_ready = 1'b0;
                out_valid = 1'b0;
                busy = 1'b1;
            end

            WAIT_READY: begin
                in_ready = 1'b0;
                out_valid = 1'b1;
                busy = 1'b1;
            end
        endcase
    end

endmodule
