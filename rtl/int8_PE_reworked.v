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

wire signed product_extended = {{2{product[15]}} , product};

always @(posedge clk or posedge reset) begin
    if (reset) begin
        acc <= 18'sd0;
    end else if (clear) begin
        acc <= 18'sd0;
    end else if (enbale) begin
        acc <= acc + product_extended
    end
end

endmodule