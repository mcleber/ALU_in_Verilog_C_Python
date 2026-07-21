module alu_fsm_simple (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  enable_alu,
    output reg  done
);

    localparam IDLE = 2'd0;
    localparam EXEC = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    // State register.
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = EXEC;
            end

            EXEC: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic.
    always @(*) begin
        enable_alu = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                enable_alu = 1'b0;
                done = 1'b0;
            end

            EXEC: begin
                enable_alu = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule
