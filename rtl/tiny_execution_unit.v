`timescale 1ns/1ps

module tiny_execution_unit (
    input        clk,
    input        reset,
    input        start,
    input        write_enable,
    input  [1:0] write_addr,
    input  [3:0] write_data,
    input  [1:0] read_addr_a,
    input  [1:0] read_addr_b,
    input  [2:0] opcode,
    output       busy,
    output       done,
    output [1:0] state_debug,
    output [3:0] read_data_a,
    output [3:0] read_data_b,
    output [3:0] alu_result,
    output       zero,
    output       carry,
    output       overflow,
    output       negative,
    output       capture_result_debug,
    output [3:0] result_out
);

wire capture_result;
wire capture_enable;

assign capture_result_debug = capture_result;

`ifdef INTENTIONAL_TINY_CAPTURE_BUG
// Teaching bug: capturing in DONE is one cycle late for this one-cycle ALU path.
assign capture_enable = done;
`else
assign capture_enable = capture_result;
`endif

register_file4x4 registers (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr_a(read_addr_a),
    .read_addr_b(read_addr_b),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b)
);

alu4 alu (
    .a(read_data_a),
    .b(read_data_b),
    .opcode(opcode),
    .result(alu_result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow),
    .negative(negative)
);

controller_fsm controller (
    .clk(clk),
    .reset(reset),
    .start(start),
    .busy(busy),
    .done(done),
    .capture_result(capture_result),
    .state_debug(state_debug)
);

result_register4 result_register (
    .clk(clk),
    .reset(reset),
    .capture_enable(capture_enable),
    .result_in(alu_result),
    .result_out(result_out)
);

endmodule
