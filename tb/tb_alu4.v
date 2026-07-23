`timescale 1ns/1ps

module tb_alu4;

localparam OP_ADD    = 3'b000;
localparam OP_SUB    = 3'b001;
localparam OP_AND    = 3'b010;
localparam OP_OR     = 3'b011;
localparam OP_XOR    = 3'b100;
localparam OP_PASS_A = 3'b101;

reg  [3:0] a;
reg  [3:0] b;
reg  [2:0] opcode;
wire [3:0] result;
wire       zero;
wire       carry;
wire       overflow;

integer errors;
integer test_number;
reg [3:0] expected_result;
reg expected_zero;
reg expected_carry;
reg expected_overflow;
reg [4:0] model_full;

alu4 dut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow)
);

function [8*8-1:0] opcode_name;
    input [2:0] op;
    begin
        case (op)
            OP_ADD:    opcode_name = "ADD";
            OP_SUB:    opcode_name = "SUB";
            OP_AND:    opcode_name = "AND";
            OP_OR:     opcode_name = "OR";
            OP_XOR:    opcode_name = "XOR";
            OP_PASS_A: opcode_name = "PASS_A";
            default:   opcode_name = "INVALID";
        endcase
    end
endfunction

task golden_model;
    input [3:0] model_a;
    input [3:0] model_b;
    input [2:0] model_opcode;
    output [3:0] model_result;
    output model_zero;
    output model_carry;
    output model_overflow;
    reg [4:0] full;
    begin
        model_result = 4'b0000;
        model_carry = 1'b0;
        model_overflow = 1'b0;

        case (model_opcode)
            OP_ADD: begin
                full = {1'b0, model_a} + {1'b0, model_b};
                model_result = full[3:0];
                model_carry = full[4];
                model_overflow = (model_a[3] == model_b[3]) &&
                                 (model_result[3] != model_a[3]);
            end
            OP_SUB: begin
                full = {1'b0, model_a} + {1'b0, ~model_b} + 5'b00001;
                model_result = full[3:0];
                model_carry = full[4];
                model_overflow = (model_a[3] != model_b[3]) &&
                                 (model_result[3] != model_a[3]);
            end
            OP_AND: begin
                model_result = model_a & model_b;
            end
            OP_OR: begin
                model_result = model_a | model_b;
            end
            OP_XOR: begin
                model_result = model_a ^ model_b;
            end
            OP_PASS_A: begin
                model_result = model_a;
            end
            default: begin
                model_result = 4'b0000;
                model_carry = 1'b0;
                model_overflow = 1'b0;
            end
        endcase

        model_zero = (model_result == 4'b0000);
    end
endtask

task apply_and_check;
    input [8*32-1:0] test_name;
    input [3:0] test_a;
    input [3:0] test_b;
    input [2:0] test_opcode;
    begin
        test_number = test_number + 1;
        a = test_a;
        b = test_b;
        opcode = test_opcode;
        #1;

        golden_model(test_a, test_b, test_opcode,
                     expected_result, expected_zero,
                     expected_carry, expected_overflow);

`ifdef WRONG_TB_EXPECTATION
        if (test_a == 4'hF && test_b == 4'h1 && test_opcode == OP_ADD) begin
            // Deliberately wrong: 4'hF + 4'h1 wraps to 0 and has unsigned carry.
            expected_carry = 1'b0;
        end
`endif

        if ((result !== expected_result) ||
            (zero !== expected_zero) ||
            (carry !== expected_carry) ||
            (overflow !== expected_overflow)) begin
            $display("FAIL test %0d %-32s op=%s opcode=%03b a=%h(%04b, u=%0d, s=%0d) b=%h(%04b, u=%0d, s=%0d)",
                     test_number, test_name, opcode_name(test_opcode), test_opcode,
                     test_a, test_a, test_a, $signed(test_a),
                     test_b, test_b, test_b, $signed(test_b));
            $display("     expected result=%h(%04b) zero=%b carry=%b overflow=%b",
                     expected_result, expected_result, expected_zero,
                     expected_carry, expected_overflow);
            $display("     actual   result=%h(%04b) zero=%b carry=%b overflow=%b time=%0t",
                     result, result, zero, carry, overflow, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-32s op=%s a=%h b=%h result=%h zero=%b carry=%b overflow=%b",
                     test_number, test_name, opcode_name(test_opcode),
                     test_a, test_b, result, zero, carry, overflow);
        end
    end
endtask

initial begin
    $dumpfile("sim/alu4.vcd");
    $dumpvars(0, tb_alu4);

    errors = 0;
    test_number = 0;
    a = 4'h0;
    b = 4'h0;
    opcode = OP_ADD;

    $display("============================================================");
    $display("PREDICT BEFORE RUNNING THE ALU CHECKS");
    $display("1. 4'hF + 4'h1: result? carry? overflow?");
    $display("2. 4'h7 + 4'h1: unsigned result? signed meaning? overflow?");
    $display("3. 4'h8 - 4'h1: result? signed meaning? overflow?");
    $display("4. For equal operands A-A, which flags should be high?");
    $display("5. Which operations should force carry=0 and overflow=0?");
    $display("============================================================");

    apply_and_check("all zero add",          4'h0, 4'h0, OP_ADD);
    apply_and_check("F plus 1 wraps",        4'hF, 4'h1, OP_ADD);
    apply_and_check("7 plus 1 signed ovf",   4'h7, 4'h1, OP_ADD);
    apply_and_check("8 plus 8 carry and ovf",4'h8, 4'h8, OP_ADD);
    apply_and_check("3 plus 4 normal",       4'h3, 4'h4, OP_ADD);

    apply_and_check("equal subtract zero",   4'hA, 4'hA, OP_SUB);
    apply_and_check("8 minus 1 signed ovf",  4'h8, 4'h1, OP_SUB);
    apply_and_check("0 minus 1 borrow",      4'h0, 4'h1, OP_SUB);
    apply_and_check("F minus 1",             4'hF, 4'h1, OP_SUB);
    apply_and_check("7 minus F signed ovf",  4'h7, 4'hF, OP_SUB);

    apply_and_check("all ones and all ones", 4'hF, 4'hF, OP_AND);
    apply_and_check("and clears bits",       4'hC, 4'h3, OP_AND);
    apply_and_check("or combines bits",      4'hC, 4'h3, OP_OR);
    apply_and_check("xor alternating",       4'hA, 4'h5, OP_XOR);
    apply_and_check("xor overlap",           4'hF, 4'hA, OP_XOR);
    apply_and_check("pass A ignores B",      4'h9, 4'h6, OP_PASS_A);
    apply_and_check("invalid opcode 110",    4'hF, 4'h1, 3'b110);
    apply_and_check("invalid opcode 111",    4'h7, 4'h8, 3'b111);

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all ALU tests passed");
    else
        $display("FAIL: %0d ALU test(s) failed", errors);
    $display("Open sim/alu4.vcd in GTKWave and inspect opcode, a, b, result, zero, carry, overflow.");
    $display("============================================================");
    $finish;
end

endmodule
