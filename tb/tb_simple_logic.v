`timescale 1ns/1ps

module tb_simple_logic;

reg a;
reg b;

wire y_not_a;
wire y_and;
wire y_or;
wire y_xor;
wire y_mix;

simple_logic dut (
    .a(a),
    .b(b),
    .y_not_a(y_not_a),
    .y_and(y_and),
    .y_or(y_or),
    .y_xor(y_xor),
    .y_mix(y_mix)
);

initial begin
    $dumpfile("sim/simple_logic.vcd");
    $dumpvars(0, tb_simple_logic);

    $display("a b | ~a and or xor (~a)&b");
    $display("--------------------------");

    a = 0; b = 0; #10;
    $display("%b %b |  %b  %b   %b  %b     %b", a, b, y_not_a, y_and, y_or, y_xor, y_mix);

    a = 0; b = 1; #10;
    $display("%b %b |  %b  %b   %b  %b     %b", a, b, y_not_a, y_and, y_or, y_xor, y_mix);

    a = 1; b = 0; #10;
    $display("%b %b |  %b  %b   %b  %b     %b", a, b, y_not_a, y_and, y_or, y_xor, y_mix);

    a = 1; b = 1; #10;
    $display("%b %b |  %b  %b   %b  %b     %b", a, b, y_not_a, y_and, y_or, y_xor, y_mix);

    $finish;
end

endmodule
