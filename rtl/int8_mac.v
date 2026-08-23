`timescale 1ns/1ps

module int8_mac (
    input  wire               clk,
    input  wire               reset,
    input  wire               clear,
    input  wire               enable,
    input  wire signed [7:0]  a,
    input  wire signed [7:0]  b,
    output wire signed [15:0] product,
    output reg  signed [17:0] acc
);

assign product = a * b;

`ifdef INTENTIONAL_MAC_EXTEND_BUG
wire signed [17:0] extended_product = {2'b00, product};
`else
wire signed [17:0] extended_product = {{2{product[15]}}, product};
`endif

always @(posedge clk or posedge reset) begin
    if (reset) begin
        acc <= 18'sd0;
    end else if (clear) begin
        acc <= 18'sd0;
    end else if (enable) begin
        acc <= acc + extended_product;
    end
end

endmodule
