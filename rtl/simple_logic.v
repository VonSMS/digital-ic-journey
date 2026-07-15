module simple_logic (
    input  a,
    input  b,
    output y_not_a,
    output y_and,
    output y_or,
    output y_xor,
    output y_mix,
    output y_nand,
    output y_nor
);

wire not_a;

assign not_a   = ~a;
assign y_not_a = not_a;
assign y_and   = a & b;
assign y_or    = a | b;
assign y_xor   = a ^ b;
assign y_mix   = not_a & b;
assign y_nand  = ~(a & b);
assign y_nor   = ~(a | b);

endmodule
