`timescale 1ns/1ps

module counter4 (
    input        clk,
    input        reset,
    output reg [3:0] count
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 4'b0000;
    else
        count <= count + 4'b0001;
end

endmodule

module counter4_enable (
    input        clk,
    input        reset,
    input        enable,
    output reg [3:0] count
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 4'b0000;
    else if (enable)
        count <= count + 4'b0001;
end

endmodule

module counter4_terminal (
    input        clk,
    input        reset,
    input        enable,
    output reg [3:0] count,
    output       terminal_count
);

assign terminal_count = (count == 4'b1111);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 4'b0000;
    else if (enable)
        count <= count + 4'b0001;
end

endmodule
