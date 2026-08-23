`timescale 1ns/1ps

module result_register4 (
    input        clk,
    input        reset,
    input        capture_enable,
    input  [3:0] result_in,
    output reg [3:0] result_out
);

always @(posedge clk or posedge reset) begin
    if (reset)
        result_out <= 4'b0000;
    else if (capture_enable)
        result_out <= result_in;
end

endmodule
