`timescale 1ns/1ps

module controller_fsm (
    input        clk,
    input        reset,
    input        start,
    output reg   busy,
    output reg   done,
    output reg   capture_result,
    output [1:0] state_debug
);

localparam STATE_IDLE = 2'b00;
localparam STATE_EXECUTE = 2'b01;
localparam STATE_DONE = 2'b10;

reg [1:0] state;
reg [1:0] next_state;
reg       start_d;

wire start_pulse;

assign start_pulse = start & ~start_d;
assign state_debug = state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE_IDLE;
        start_d <= 1'b0;
    end else begin
        state <= next_state;
        start_d <= start;
    end
end

always @(*) begin
    //默认如果没有跳转，state保持不变
    next_state = state;

    case(state)
        STATE_IDLE: begin
            if (start_pulse)
                next_state = STATE_EXECUTE;
        end
        STATE_EXECUTE: begin
            next_state = STATE_DONE;
        end 
        STATE_DONE: begin
            next_state = STATE_IDLE;
        end
        default: begin
            next_state = STATE_IDLE;
        end
    endcase
end


always @(*) begin
    busy = 1'b0;
    done = 1'b0;
    capture_result = 1'b0;

    case (state)
        STATE_EXECUTE: begin
            busy = 1'b1;
            capture_result = 1'b1;
        end
        STATE_DONE: begin
            done = 1'b1;
        end
        default: begin
            busy = 1'b0;
            done = 1'b0;
            capture_result = 1'b0;
        end
    endcase
end

endmodule
