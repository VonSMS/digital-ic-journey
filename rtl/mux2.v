module mux2 (
    input  a,
    input  b,
    input  sel,
    output y
);

assign y = sel ? b : a;

endmodule

module mux2_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        sel,
    output [3:0] y
);

assign y = sel ? b : a;

endmodule

module muxed_adder_logic_block (
    input  [3:0] a,
    input  [3:0] b,
    input        choose_logic,
    output [3:0] y
);

wire [3:0] add_result;
wire [3:0] logic_result;

assign add_result   = a + b;
assign logic_result = a ^ b;

mux2_4bit result_mux (
    .a(add_result),
    .b(logic_result),
    .sel(choose_logic),
    .y(y)
);

endmodule
