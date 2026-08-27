`timescale 1ns/1ps

module int8_processing_element (
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

wire signed [17:0] extended_product = {{2{product[15]}}, product};

always @(posedge clk or posedge reset) begin
    if (reset) begin
        acc <= 18'sd0;
`ifdef INTENTIONAL_PE_CLEAR_ENABLE_BUG
    end else if (enable) begin
        acc <= acc + extended_product;
    end else if (clear) begin
        acc <= 18'sd0;
`else
    end else if (clear) begin
        acc <= 18'sd0;
    end else if (enable) begin
        acc <= acc + extended_product;
`endif
    end
end

endmodule
