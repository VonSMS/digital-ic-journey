`timescale 1ns/1ps

module dff (
    input  clk,
    input  reset,
    input  d,
    output reg q
);

// Asynchronous, active-high reset. The teaching macro deliberately changes
// the sampling edge so the self-checking testbench can demonstrate a failure.
`ifdef INTENTIONAL_BUG
always @(negedge clk or posedge reset) begin
`else
always @(posedge clk or posedge reset) begin
`endif
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end

endmodule

module dff_negedge (
    input  clk,
    input  reset,
    input  d,
    output reg q
);

always @(negedge clk or posedge reset) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end

endmodule
