`timescale 1ns/1ps

module int8_multiplier (
    input  signed [7:0]  a,
    input  signed [7:0]  b,
    output signed [15:0] product
);

`ifdef INTENTIONAL_INT8_SIGN_BUG
// Teaching bug: treating the same bits as unsigned breaks negative operands.
assign product = a[7:0] * b[7:0];
`else
assign product = a * b;
`endif

endmodule
