`timescale 1ns/1ps

module tb_tiny_execution_unit;

localparam OP_ADD    = 3'b000;
localparam OP_SUB    = 3'b001;
localparam OP_XOR    = 3'b100;
localparam OP_APLUS  = 3'b111;

localparam STATE_IDLE    = 2'b00;
localparam STATE_EXECUTE = 2'b01;
localparam STATE_DONE    = 2'b10;

reg        clk;
reg        reset;
reg        start;
reg        write_enable;
reg  [1:0] write_addr;
reg  [3:0] write_data;
reg  [1:0] read_addr_a;
reg  [1:0] read_addr_b;
reg  [2:0] opcode;
wire       busy;
wire       done;
wire [1:0] state_debug;
wire [3:0] read_data_a;
wire [3:0] read_data_b;
wire [3:0] alu_result;
wire       zero;
wire       carry;
wire       overflow;
wire       negative;
wire       capture_result_debug;
wire [3:0] result_out;

integer errors;
integer test_number;

tiny_execution_unit dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr_a(read_addr_a),
    .read_addr_b(read_addr_b),
    .opcode(opcode),
    .busy(busy),
    .done(done),
    .state_debug(state_debug),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b),
    .alu_result(alu_result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow),
    .negative(negative),
    .capture_result_debug(capture_result_debug),
    .result_out(result_out)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task golden_model;
    input [3:0] model_a;
    input [3:0] model_b;
    input [2:0] model_opcode;
    output [3:0] model_result;
    output model_zero;
    output model_carry;
    output model_overflow;
    output model_negative;
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
            OP_XOR: begin
                model_result = model_a ^ model_b;
            end
            OP_APLUS: begin
                full = {1'b0, model_a} + 5'b00001;
                model_result = full[3:0];
                model_carry = full[4];
                model_overflow = (model_a[3] == 1'b0) &&
                                 (model_result[3] != model_a[3]);
            end
            default: begin
                model_result = 4'b0000;
            end
        endcase

        model_zero = (model_result == 4'b0000);
        model_negative = model_result[3];
    end
endtask

task check_unit;
    input [8*56-1:0] name;
    input [1:0] expected_state;
    input expected_busy;
    input expected_done;
    input expected_capture;
    input [3:0] expected_read_a;
    input [3:0] expected_read_b;
    input [3:0] expected_alu_result;
    input expected_zero;
    input expected_carry;
    input expected_overflow;
    input expected_negative;
    input [3:0] expected_result_out;
    begin
        test_number = test_number + 1;
        if (state_debug !== expected_state ||
            busy !== expected_busy ||
            done !== expected_done ||
            capture_result_debug !== expected_capture ||
            read_data_a !== expected_read_a ||
            read_data_b !== expected_read_b ||
            alu_result !== expected_alu_result ||
            zero !== expected_zero ||
            carry !== expected_carry ||
            overflow !== expected_overflow ||
            negative !== expected_negative ||
            result_out !== expected_result_out) begin
            $display("FAIL test %0d %-42s state=%02b exp=%02b busy=%b exp=%b done=%b exp=%b capture=%b exp=%b",
                     test_number, name, state_debug, expected_state, busy, expected_busy,
                     done, expected_done, capture_result_debug, expected_capture);
            $display("     read_a=%h exp=%h read_b=%h exp=%h alu=%h exp=%h result_out=%h exp=%h",
                     read_data_a, expected_read_a, read_data_b, expected_read_b,
                     alu_result, expected_alu_result, result_out, expected_result_out);
            $display("     flags z=%b exp=%b c=%b exp=%b v=%b exp=%b n=%b exp=%b time=%0t",
                     zero, expected_zero, carry, expected_carry, overflow, expected_overflow,
                     negative, expected_negative, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-42s alu=%h result_out=%h state=%02b done=%b",
                     test_number, name, alu_result, result_out, state_debug, done);
        end
    end
endtask

task write_reg;
    input [1:0] addr;
    input [3:0] data;
    begin
        @(negedge clk);
        write_enable = 1'b1;
        write_addr = addr;
        write_data = data;
        @(posedge clk);
        #1;
        write_enable = 1'b0;
    end
endtask

task disabled_write_check;
    begin
        @(negedge clk);
        write_enable = 1'b0;
        write_addr = 2'b00;
        write_data = 4'hE;
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;
        opcode = OP_ADD;
        @(posedge clk);
        #1;
        check_unit("disabled write keeps r0 unchanged", STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   4'h7, 4'h1, 4'h8, 1'b0, 1'b0, 1'b1, 1'b1, result_out);
    end
endtask

task apply_reset;
    begin
        @(negedge clk);
        reset = 1'b1;
        start = 1'b0;
        write_enable = 1'b0;
        write_addr = 2'b00;
        write_data = 4'h0;
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;
        opcode = OP_ADD;
        #1;
        check_unit("reset clears datapath storage", STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   4'h0, 4'h0, 4'h0, 1'b1, 1'b0, 1'b0, 1'b0, 4'h0);
        @(negedge clk);
        reset = 1'b0;
    end
endtask

task run_transaction;
    input [8*40-1:0] name;
    input [1:0] addr_a;
    input [1:0] addr_b;
    input [2:0] op;
    input [3:0] expected_a;
    input [3:0] expected_b;
    input [3:0] previous_result;
    reg [3:0] expected_result;
    reg expected_zero;
    reg expected_carry;
    reg expected_overflow;
    reg expected_negative;
    begin
        golden_model(expected_a, expected_b, op, expected_result,
                     expected_zero, expected_carry, expected_overflow, expected_negative);

        @(negedge clk);
        read_addr_a = addr_a;
        read_addr_b = addr_b;
        opcode = op;
        start = 1'b1;
        @(posedge clk);
        #1;
        check_unit({name, " execute"}, STATE_EXECUTE, 1'b1, 1'b0, 1'b1,
                   expected_a, expected_b, expected_result, expected_zero,
                   expected_carry, expected_overflow, expected_negative, previous_result);

        @(negedge clk);
        start = 1'b0;
        @(posedge clk);
        #1;
        check_unit({name, " done"}, STATE_DONE, 1'b0, 1'b1, 1'b0,
                   expected_a, expected_b, expected_result, expected_zero,
                   expected_carry, expected_overflow, expected_negative, expected_result);

        @(posedge clk);
        #1;
        check_unit({name, " idle hold"}, STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   expected_a, expected_b, expected_result, expected_zero,
                   expected_carry, expected_overflow, expected_negative, expected_result);
    end
endtask

task check_idle_alu_changes_without_capture;
    begin
        @(negedge clk);
        read_addr_a = 2'b10;
        read_addr_b = 2'b11;
        opcode = OP_XOR;
        #1;
        check_unit("idle ALU changes but result register holds", STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   4'hA, 4'h5, 4'hF, 1'b0, 1'b0, 1'b0, 1'b1, 4'h0);
    end
endtask

task check_held_start_no_retrigger;
    begin
        @(negedge clk);
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;
        opcode = OP_ADD;
        start = 1'b1;
        @(posedge clk);
        #1;
        check_unit("held start enters execute", STATE_EXECUTE, 1'b1, 1'b0, 1'b1,
                   4'h7, 4'h1, 4'h8, 1'b0, 1'b0, 1'b1, 1'b1, 4'h0);
        @(posedge clk);
        #1;
        check_unit("held start reaches done", STATE_DONE, 1'b0, 1'b1, 1'b0,
                   4'h7, 4'h1, 4'h8, 1'b0, 1'b0, 1'b1, 1'b1, 4'h8);
        @(posedge clk);
        #1;
        check_unit("held start returns idle", STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   4'h7, 4'h1, 4'h8, 1'b0, 1'b0, 1'b1, 1'b1, 4'h8);
        @(posedge clk);
        #1;
        check_unit("held start does not retrigger", STATE_IDLE, 1'b0, 1'b0, 1'b0,
                   4'h7, 4'h1, 4'h8, 1'b0, 1'b0, 1'b1, 1'b1, 4'h8);
        @(negedge clk);
        start = 1'b0;
    end
endtask

initial begin
    $dumpfile("sim/tiny_execution_unit.vcd");
    $dumpvars(0, tb_tiny_execution_unit);

    errors = 0;
    test_number = 0;
    reset = 1'b0;
    start = 1'b0;
    write_enable = 1'b0;
    write_addr = 2'b00;
    write_data = 4'h0;
    read_addr_a = 2'b00;
    read_addr_b = 2'b01;
    opcode = OP_ADD;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 4 CHECKS RUN");
    $display("1. With r0=7 and r1=1, what should ADD produce?");
    $display("2. Does F+1 set carry, zero, overflow, and negative?");
    $display("3. Should IDLE read-address changes alter result_out?");
    $display("4. Which signal tells the result register to capture?");
    $display("============================================================");

    apply_reset;

    write_reg(2'b00, 4'h7);
    write_reg(2'b01, 4'h1);
    write_reg(2'b10, 4'hA);
    write_reg(2'b11, 4'h5);

    check_idle_alu_changes_without_capture;
    disabled_write_check;
    check_held_start_no_retrigger;

    run_transaction("A plus 1 normal", 2'b10, 2'b01, OP_ADD, 4'hA, 4'h1, 4'h8);
    write_reg(2'b10, 4'hF);
    run_transaction("F plus 1 boundary", 2'b10, 2'b01, OP_ADD, 4'hF, 4'h1, 4'hB);
    run_transaction("7 minus 1", 2'b00, 2'b01, OP_SUB, 4'h7, 4'h1, 4'h0);
    run_transaction("F xor 5", 2'b10, 2'b11, OP_XOR, 4'hF, 4'h5, 4'h6);
    run_transaction("A plus 1 opcode", 2'b00, 2'b11, OP_APLUS, 4'h7, 4'h5, 4'hA);

    apply_reset;

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all tiny_execution_unit tests passed");
    else
        $display("FAIL: %0d tiny_execution_unit test(s) failed", errors);
    $display("Open sim/tiny_execution_unit.vcd in GTKWave and inspect start -> execute -> done.");
    $display("============================================================");

    $finish;
end

endmodule
