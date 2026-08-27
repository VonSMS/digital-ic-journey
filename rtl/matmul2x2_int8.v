`timescale 1ns/1ps

module matmul2x2_int8 (
    input  wire               clk,
    input  wire               reset,
    input  wire               start,
    input  wire signed [7:0]  a00,
    input  wire signed [7:0]  a01,
    input  wire signed [7:0]  a10,
    input  wire signed [7:0]  a11,
    input  wire signed [7:0]  b00,
    input  wire signed [7:0]  b01,
    input  wire signed [7:0]  b10,
    input  wire signed [7:0]  b11,
    output wire               busy,
    output wire               done,
    output wire signed [17:0] c00,
    output wire signed [17:0] c01,
    output wire signed [17:0] c10,
    output wire signed [17:0] c11
);

localparam STATE_IDLE  = 3'b000;
localparam STATE_CLEAR = 3'b001;
localparam STATE_MAC0  = 3'b010;
localparam STATE_MAC1  = 3'b011;
localparam STATE_DONE  = 3'b100;

reg [2:0] state;
reg [2:0] next_state;

wire pe_clear = (state == STATE_CLEAR);
wire pe_enable = (state == STATE_MAC0) || (state == STATE_MAC1);

wire signed [7:0] pe00_a = (state == STATE_MAC0) ? a00 : a01;
wire signed [7:0] pe00_b = (state == STATE_MAC0) ? b00 : b10;
wire signed [7:0] pe01_a = (state == STATE_MAC0) ? a00 : a01;
wire signed [7:0] pe01_b = (state == STATE_MAC0) ? b01 : b11;
wire signed [7:0] pe10_a = (state == STATE_MAC0) ? a10 : a11;
wire signed [7:0] pe10_b = (state == STATE_MAC0) ? b00 : b10;
wire signed [7:0] pe11_a = (state == STATE_MAC0) ? a10 : a11;
wire signed [7:0] pe11_b = (state == STATE_MAC0) ? b01 : b11;

wire signed [15:0] pe00_product;
wire signed [15:0] pe01_product;
wire signed [15:0] pe10_product;
wire signed [15:0] pe11_product;

assign busy = (state != STATE_IDLE);
assign done = (state == STATE_DONE);

always @(posedge clk or posedge reset) begin
    if (reset)
        state <= STATE_IDLE;
    else
        state <= next_state;
end

always @(*) begin
    next_state = state;
    case (state)
        STATE_IDLE: begin
            if (start)
                next_state = STATE_CLEAR;
        end
        STATE_CLEAR: begin
            next_state = STATE_MAC0;
        end
        STATE_MAC0: begin
            next_state = STATE_MAC1;
        end
        STATE_MAC1: begin
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

int8_processing_element pe00 (
    .clk(clk),
    .reset(reset),
    .clear(pe_clear),
    .enable(pe_enable),
    .a(pe00_a),
    .b(pe00_b),
    .product(pe00_product),
    .acc(c00)
);

int8_processing_element pe01 (
    .clk(clk),
    .reset(reset),
    .clear(pe_clear),
    .enable(pe_enable),
    .a(pe01_a),
    .b(pe01_b),
    .product(pe01_product),
    .acc(c01)
);

int8_processing_element pe10 (
    .clk(clk),
    .reset(reset),
    .clear(pe_clear),
    .enable(pe_enable),
    .a(pe10_a),
    .b(pe10_b),
    .product(pe10_product),
    .acc(c10)
);

int8_processing_element pe11 (
    .clk(clk),
    .reset(reset),
    .clear(pe_clear),
    .enable(pe_enable),
    .a(pe11_a),
    .b(pe11_b),
    .product(pe11_product),
    .acc(c11)
);

endmodule
