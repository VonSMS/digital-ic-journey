`timescale 1ns/1ps

module tb_sequential;

reg clk;
reg reset;
reg d;
reg [3:0] reg_d;
reg reg_enable;
reg counter_enable;
reg select_b;
reg [3:0] mux_a;
reg [3:0] mux_b;

wire dff_q;
wire dff_q_negedge;
wire [3:0] reg_q;
wire [3:0] reg_enable_q;
wire [3:0] count;
wire [3:0] count_enable;
wire [3:0] count_terminal;
wire terminal_count;
wire [3:0] mux_y;
wire [3:0] mux_reg_q;

integer errors;
integer test_number;
reg expected_dff;
reg [3:0] expected_reg;
reg [3:0] expected_reg_enable;
reg [3:0] expected_count;
reg [3:0] expected_count_enable;
reg [3:0] expected_count_terminal;
reg [3:0] expected_mux_reg;

dff dut_dff (
    .clk(clk), .reset(reset), .d(d), .q(dff_q)
);

dff_negedge dut_dff_negedge (
    .clk(clk), .reset(reset), .d(d), .q(dff_q_negedge)
);

register4 dut_register4 (
    .clk(clk), .reset(reset), .d(reg_d), .q(reg_q)
);

register4_enable dut_register4_enable (
    .clk(clk), .reset(reset), .enable(reg_enable),
    .d(reg_d), .q(reg_enable_q)
);

counter4 dut_counter4 (
    .clk(clk), .reset(reset), .count(count)
);

counter4_enable dut_counter4_enable (
    .clk(clk), .reset(reset), .enable(counter_enable),
    .count(count_enable)
);

counter4_terminal dut_counter4_terminal (
    .clk(clk), .reset(reset), .enable(counter_enable),
    .count(count_terminal), .terminal_count(terminal_count)
);

mux_register4 dut_mux_register4 (
    .clk(clk), .reset(reset), .select_b(select_b),
    .a(mux_a), .b(mux_b), .mux_y(mux_y), .q(mux_reg_q)
);

// 10 ns clock period: rising edges at 5, 15, 25, ... ns.
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task check_bit;
    input [8*32-1:0] name;
    input actual;
    input expected;
    begin
        test_number = test_number + 1;
        if (actual !== expected) begin
            $display("FAIL test %0d %-32s expected=%b actual=%b time=%0t",
                     test_number, name, expected, actual, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-32s value=%b time=%0t",
                     test_number, name, actual, $time);
        end
    end
endtask

task check_bus4;
    input [8*32-1:0] name;
    input [3:0] actual;
    input [3:0] expected;
    begin
        test_number = test_number + 1;
        if (actual !== expected) begin
            $display("FAIL test %0d %-32s expected=%04b actual=%04b time=%0t",
                     test_number, name, expected, actual, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-32s value=%04b time=%0t",
                     test_number, name, actual, $time);
        end
    end
endtask

// Drive on the falling edge so inputs are stable before the next rising edge.
task drive_before_posedge;
    input next_d;
    input [3:0] next_reg_d;
    input next_reg_enable;
    input next_counter_enable;
    input next_select_b;
    input [3:0] next_mux_a;
    input [3:0] next_mux_b;
    begin
        @(negedge clk);
        d = next_d;
        reg_d = next_reg_d;
        reg_enable = next_reg_enable;
        counter_enable = next_counter_enable;
        select_b = next_select_b;
        mux_a = next_mux_a;
        mux_b = next_mux_b;
    end
endtask

// Sample one timestep after posedge so non-blocking assignments have updated.
task sample_after_posedge;
    begin
        @(posedge clk);
        #1;

        expected_dff = d;
        expected_reg = reg_d;
        expected_count = expected_count + 4'b0001;
        if (reg_enable)
            expected_reg_enable = reg_d;
        if (counter_enable) begin
            expected_count_enable = expected_count_enable + 4'b0001;
            expected_count_terminal = expected_count_terminal + 4'b0001;
        end
        expected_mux_reg = select_b ? mux_b : mux_a;

        check_bit("DFF samples at posedge", dff_q, expected_dff);
        check_bus4("register4 loads at posedge", reg_q, expected_reg);
        check_bus4("register4 enable/hold", reg_enable_q, expected_reg_enable);
        check_bus4("counter4 increments", count, expected_count);
        check_bus4("counter4 enable/hold", count_enable, expected_count_enable);
        check_bus4("terminal counter value", count_terminal, expected_count_terminal);
        check_bit("terminal count flag", terminal_count,
                  (expected_count_terminal == 4'b1111));
        check_bus4("mux-selected registered value", mux_reg_q, expected_mux_reg);
    end
endtask

initial begin
    $dumpfile("sim/sequential.vcd");
    $dumpvars(0, tb_sequential);

    errors = 0;
    test_number = 0;
    reset = 1'b1;
    d = 1'b0;
    reg_d = 4'b0000;
    reg_enable = 1'b0;
    counter_enable = 1'b0;
    select_b = 1'b0;
    mux_a = 4'b0000;
    mux_b = 4'b0000;

    expected_dff = 1'b0;
    expected_reg = 4'b0000;
    expected_reg_enable = 4'b0000;
    expected_count = 4'b0000;
    expected_count_enable = 4'b0000;
    expected_count_terminal = 4'b0000;
    expected_mux_reg = 4'b0000;

    $display("============================================================");
    $display("PREDICT BEFORE THE CHECKS RUN");
    $display("1. While reset=1, what are q, register, and counter?");
    $display("2. If d changes between rising edges, does posedge q change?");
    $display("3. Starting at 0000, list the next five counter values.");
    $display("4. Why can mux_y change now while mux_reg_q must wait?");
    $display("============================================================");

    // Asynchronous reset is visible without waiting for a clock edge.
    #1;
    check_bit("async reset clears DFF", dff_q, 1'b0);
    check_bus4("async reset clears register", reg_q, 4'b0000);
    check_bus4("async reset clears counter", count, 4'b0000);

    // Release reset at a falling edge. No untracked rising edge occurs between
    // reset release, stimulus setup, and the first checked rising edge.
    @(negedge clk);
    reset = 1'b0;
    d = 1'b1;
    reg_d = 4'b1010;
    reg_enable = 1'b1;
    counter_enable = 1'b1;
    select_b = 1'b0;
    mux_a = 4'b0011;
    mux_b = 4'b1100;
    #1;
    check_bit("reset release does not load", dff_q, 1'b0);
    check_bus4("reset release keeps register", reg_q, 4'b0000);

`ifdef WRONG_TB_EXPECTATION
    // Deliberately wrong: non-blocking assignments update after the posedge
    // event. This check runs in the same time slot and expects the new value.
    @(posedge clk);
    check_bit("INTENTIONAL early TB check", dff_q, d);
    #1;
    // Resynchronize the golden model after the one deliberate bad check so
    // later failures are not merely cascading consequences of this demo.
    expected_dff = dff_q;
    expected_reg = reg_q;
    expected_reg_enable = reg_enable_q;
    expected_count = count;
    expected_count_enable = count_enable;
    expected_count_terminal = count_terminal;
    expected_mux_reg = mux_reg_q;
`else
    sample_after_posedge;
`endif

    // Change D and mux inputs between rising edges. Combinational mux_y moves;
    // posedge state must hold. The negedge DFF intentionally samples here.
    #2;
    d = 1'b0;
    select_b = 1'b1;
    mux_b = 4'b0101;
    #1;
    check_bit("posedge DFF holds between edges", dff_q, 1'b1);
    check_bus4("mux output changes immediately", mux_y, 4'b0101);
    check_bus4("mux register waits for edge", mux_reg_q, 4'b0011);
    @(negedge clk);
    #1;
    check_bit("negedge DFF samples at negedge", dff_q_negedge, d);

    // Exercise register hold, enabled counters, mux B path, and wraparound.
    d = 1'b0;
    reg_d = 4'b1111;
    reg_enable = 1'b0;
    counter_enable = 1'b1;
    select_b = 1'b1;
    mux_a = 4'b1001;
    mux_b = 4'b0101;
    sample_after_posedge;

    drive_before_posedge(1'b1, 4'b0110, 1'b1, 1'b0,
                         1'b0, 4'b1001, 4'b0101);
    sample_after_posedge;

    // Run enough enabled cycles to observe terminal_count at 1111 and wrap.
    repeat (15) begin
        drive_before_posedge(d, reg_d, 1'b0, 1'b1,
                             select_b, mux_a, mux_b);
        sample_after_posedge;
    end

    // Assert reset between edges to prove asynchronous behavior again.
    @(negedge clk);
    #2 reset = 1'b1;
    #1;
    check_bit("mid-cycle async reset DFF", dff_q, 1'b0);
    check_bus4("mid-cycle async reset register", reg_q, 4'b0000);
    check_bus4("mid-cycle async reset counter", count, 4'b0000);

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all sequential logic tests passed");
    else
        $display("FAIL: %0d sequential logic test(s) failed", errors);
    $display("Open sim/sequential.vcd in GTKWave and zoom around posedges.");
    $display("============================================================");
    $finish;
end

endmodule
