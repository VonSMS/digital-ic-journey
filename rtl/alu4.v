`timescale 1ns/1ps

module alu4 (
    input      [3:0] a,
    input      [3:0] b,
    input      [2:0] opcode,
    output reg [3:0] result,
    output           zero,
    output reg       carry,
    output reg       overflow
);

localparam OP_ADD    = 3'b000;
localparam OP_SUB    = 3'b001;
localparam OP_AND    = 3'b010;
localparam OP_OR     = 3'b011;
localparam OP_XOR    = 3'b100;
localparam OP_PASS_A = 3'b101;

wire [4:0] add_full;
wire [4:0] sub_full;
wire [3:0] add_result;
wire [3:0] sub_result;
wire [3:0] and_result;
wire [3:0] or_result;
wire [3:0] xor_result;
wire [3:0] pass_a_result;

assign add_full = {1'b0, a} + {1'b0, b};
assign sub_full = {1'b0, a} + {1'b0, ~b} + 5'b00001;

assign add_result    = add_full[3:0];
assign sub_result    = sub_full[3:0];
assign and_result    = a & b;
assign or_result     = a | b;
`ifdef INTENTIONAL_ALU_BUG
// Teaching bug: XOR was accidentally wired as OR. The testbench should catch it.
assign xor_result    = a | b;
`else
assign xor_result    = a ^ b;
`endif
assign pass_a_result = a;

assign zero = (result == 4'b0000);

always @(*) begin
    result = 4'b0000;
    carry = 1'b0;
    overflow = 1'b0;

    case (opcode)
        OP_ADD: begin
            result = add_result;
            carry = add_full[4];
            overflow = (a[3] == b[3]) && (result[3] != a[3]);
        end
        OP_SUB: begin
            result = sub_result;
            carry = sub_full[4];
            overflow = (a[3] != b[3]) && (result[3] != a[3]);
        end
        OP_AND: begin
            result = and_result;
        end
        OP_OR: begin
            result = or_result;
        end
        OP_XOR: begin
            result = xor_result;
        end
        OP_PASS_A: begin
            result = pass_a_result;
        end
        default: begin
            result = 4'b0000;
            carry = 1'b0;
            overflow = 1'b0;
        end
    endcase
end

endmodule
