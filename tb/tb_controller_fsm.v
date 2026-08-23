`timescale 1ns/1ps

module tb_controller_fsm;

reg        clk;
reg        reset;
reg        start;
reg  [3:0] result_in;
wire       busy;
wire       done;
wire       capture_result;
wire [1:0] state_debug;
wire [3:0] result_out;

integer errors;
integer test_number;

localparam STATE_IDLE    = 2'b00;
localparam STATE_EXECUTE = 2'b01;
localparam STATE_DONE    = 2'b10;

controller_fsm controller (
    .clk(clk),
    .reset(reset),
    .start(start),
    .busy(busy),
    .done(done),
    .capture_result(capture_result),
    .state_debug(state_debug)
);

result_register4 result_reg (
    .clk(clk),
    .reset(reset),
    .capture_enable(capture_result),
    .result_in(result_in),
    .result_out(result_out)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task check_signals;
    input [8*64-1:0] name;
    input [1:0] expected_state;
    input expected_busy;
    input expected_done;
    input expected_capture;
    input [3:0] expected_result;
    begin
        test_number = test_number + 1;
        if (state_debug !== expected_state ||
            busy !== expected_busy ||
            done !== expected_done ||
            capture_result !== expected_capture ||
            result_out !== expected_result) begin
            $display("FAIL test %0d %-40s state=%02b exp=%02b busy=%b exp=%b done=%b exp=%b capture=%b exp=%b result=%04b exp=%04b time=%0t",
                     test_number, name,
                     state_debug, expected_state,
                     busy, expected_busy,
                     done, expected_done,
                     capture_result, expected_capture,
                     result_out, expected_result,
                     $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-40s state=%02b busy=%b done=%b capture=%b result=%04b time=%0t",
                     test_number, name, state_debug, busy, done, capture_result, result_out, $time);
        end
    end
endtask

task tick_and_check;
    input [8*64-1:0] name;
    input [1:0] expected_state;
    input expected_busy;
    input expected_done;
    input expected_capture;
    input [3:0] expected_result;
    begin
        @(posedge clk);
        #1;
        check_signals(name, expected_state, expected_busy, expected_done, expected_capture, expected_result);
    end
endtask

task apply_reset;
    begin
        reset = 1'b1;
        start = 1'b0;
        result_in = 4'h0;
        #1;
        check_signals("async reset clears controller and result", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h0);
        @(negedge clk);
        reset = 1'b0;
        #1;
        check_signals("after reset release stays idle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h0);
    end
endtask

task pulse_start;
    input [3:0] value;
    begin
        @(negedge clk);
        result_in = value;
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
    end
endtask

task check_one_cycle_start;
    begin
        pulse_start(4'hA);
        #1;
        check_signals("one-cycle start enters execute", STATE_EXECUTE, 1'b1, 1'b0, 1'b1, 4'h0);
        tick_and_check("execute captures then enters done", STATE_DONE, 1'b0, 1'b1, 1'b0, 4'hA);
        tick_and_check("done lasts one cycle then idle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hA);
        tick_and_check("idle holds captured result", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hA);
    end
endtask

task check_disabled_capture;
    begin
        @(negedge clk);
        result_in = 4'h3;
        start = 1'b0;
        tick_and_check("idle does not capture new input", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hA);
    end
endtask

task check_held_start;
    begin
        @(negedge clk);
        result_in = 4'h5;
        start = 1'b1;
        tick_and_check("held start enters execute once", STATE_EXECUTE, 1'b1, 1'b0, 1'b1, 4'hA);
        tick_and_check("held start reaches done", STATE_DONE, 1'b0, 1'b1, 1'b0, 4'h5);
        result_in = 4'h6;
        tick_and_check("held start returns idle without retrigger", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h5);
        tick_and_check("still held start remains idle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h5);
        @(negedge clk);
        start = 1'b0;
        result_in = 4'h7;
        tick_and_check("released start remains idle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h5);
    end
endtask

task check_start_while_busy;
    begin
        @(negedge clk);
        result_in = 4'hC;
        start = 1'b1;
        tick_and_check("new transaction enters execute", STATE_EXECUTE, 1'b1, 1'b0, 1'b1, 4'h5);
        result_in = 4'hD;
        tick_and_check("start while busy ignored and capture occurs", STATE_DONE, 1'b0, 1'b1, 1'b0, 4'hD);
        result_in = 4'hE;
        tick_and_check("held busy-start returns idle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hD);
        tick_and_check("held busy-start does not retrigger", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hD);
        @(negedge clk);
        start = 1'b0;
        tick_and_check("release after busy-start", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'hD);
    end
endtask

task check_done_duration_with_new_pulse;
    begin
        pulse_start(4'h2);
        #1;
        check_signals("second pulse enters execute", STATE_EXECUTE, 1'b1, 1'b0, 1'b1, 4'hD);
`ifdef INTENTIONAL_CHECKER_BUG
        tick_and_check("intentional checker bug expects done too early", STATE_EXECUTE, 1'b1, 1'b0, 1'b1, 4'hD);
`else
        tick_and_check("second pulse reaches done", STATE_DONE, 1'b0, 1'b1, 1'b0, 4'h2);
`endif
        tick_and_check("second pulse done clears", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h2);
        tick_and_check("done stays low after one cycle", STATE_IDLE, 1'b0, 1'b0, 1'b0, 4'h2);
    end
endtask

initial begin
    $dumpfile("sim/controller_fsm.vcd");
    $dumpvars(0, tb_controller_fsm);

    errors = 0;
    test_number = 0;
    reset = 1'b0;
    start = 1'b0;
    result_in = 4'h0;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 3 CHECKS RUN");
    $display("1. For a one-cycle start pulse, which cycle is EXECUTE?");
    $display("2. Which edge captures result_in into result_out?");
    $display("3. If start is held high, should the FSM retrigger without a release?");
    $display("4. How many cycles should done stay high?");
    $display("============================================================");

    apply_reset;
    check_one_cycle_start;
    check_disabled_capture;
    check_held_start;
    check_start_while_busy;
    check_done_duration_with_new_pulse;

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all controller_fsm/result_register4 tests passed");
    else
        $display("FAIL: %0d controller_fsm/result_register4 test(s) failed", errors);
    $display("Open sim/controller_fsm.vcd in GTKWave and inspect IDLE -> EXECUTE -> DONE -> IDLE.");
    $display("============================================================");

    $finish;
end

endmodule
