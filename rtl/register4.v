`timescale 1ns/1ps

module register4 (
    input        clk,
    input        reset,
    input  [3:0] d,
    output reg [3:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 4'b0000;
    else
        q <= d;
end

endmodule

module register4_enable (
    input        clk,
    input        reset,
    input        enable,
    input  [3:0] d,
    output reg [3:0] q
);

always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 4'b0000;
    else if (enable)
        q <= d;
end

endmodule

// A combinational mux chooses the next value. The register stores that value
// only at a rising clock edge.
module mux_register4 (
    input        clk,
    input        reset,
    input        select_b,
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] mux_y,
    output reg [3:0] q
);

assign mux_y = select_b ? b : a;

always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 4'b0000;
    else
        q <= mux_y;
end

endmodule
