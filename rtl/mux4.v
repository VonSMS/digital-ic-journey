module mux4 (
    input        d0,
    input        d1,
    input        d2,
    input        d3,
    input  [1:0] sel,
    output reg   y
);

always @(*) begin
    case (sel)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        2'b11: y = d3;
        default: y = 1'b0;
    endcase
end

endmodule

module mux4_from_mux2 (
    input        d0,
    input        d1,
    input        d2,
    input        d3,
    input  [1:0] sel,
    output       y
);

wire low_pair_y;
wire high_pair_y;

mux2 mux_low_pair (
    .a(d0),
    .b(d1),
    .sel(sel[0]),
    .y(low_pair_y)
);

mux2 mux_high_pair (
    .a(d2),
    .b(d3),
    .sel(sel[0]),
    .y(high_pair_y)
);

mux2 mux_final (
    .a(low_pair_y),
    .b(high_pair_y),
    .sel(sel[1]),
    .y(y)
);

endmodule
