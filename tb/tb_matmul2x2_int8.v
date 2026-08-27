`timescale 1ns/1ps

module tb_matmul2x2_int8;

reg clk;
reg reset;
reg start;
reg signed [7:0] a00;
reg signed [7:0] a01;
reg signed [7:0] a10;
reg signed [7:0] a11;
reg signed [7:0] b00;
reg signed [7:0] b01;
reg signed [7:0] b10;
reg signed [7:0] b11;
wire busy;
wire done;
wire signed [17:0] c00;
wire signed [17:0] c01;
wire signed [17:0] c10;
wire signed [17:0] c11;

integer errors;
integer displayed_failures;
integer test_number;
reg signed [17:0] exp_c00;
reg signed [17:0] exp_c01;
reg signed [17:0] exp_c10;
reg signed [17:0] exp_c11;

matmul2x2_int8 dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .a00(a00),
    .a01(a01),
    .a10(a10),
    .a11(a11),
    .b00(b00),
    .b01(b01),
    .b10(b10),
    .b11(b11),
    .busy(busy),
    .done(done),
    .c00(c00),
    .c01(c01),
    .c10(c10),
    .c11(c11)
);

always #5 clk = ~clk;

task compute_expected;
    begin
        exp_c00 = (a00 * b00) + (a01 * b10);
        exp_c01 = (a00 * b01) + (a01 * b11);
        exp_c10 = (a10 * b00) + (a11 * b10);
        exp_c11 = (a10 * b01) + (a11 * b11);
    end
endtask

task check_matrix;
    input [8*56-1:0] name;
    begin
        test_number = test_number + 1;
        if (!done || c00 !== exp_c00 || c01 !== exp_c01 || c10 !== exp_c10 || c11 !== exp_c11) begin
            if (displayed_failures < 20) begin
                $display("FAIL test %0d %-36s done=%b c00=%0d exp=%0d c01=%0d exp=%0d c10=%0d exp=%0d c11=%0d exp=%0d time=%0t",
                         test_number, name, done, c00, exp_c00, c01, exp_c01,
                         c10, exp_c10, c11, exp_c11, $time);
                displayed_failures = displayed_failures + 1;
            end
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-36s C=[[%0d,%0d],[%0d,%0d]]",
                     test_number, name, c00, c01, c10, c11);
        end
    end
endtask

task run_matrix;
    input [8*56-1:0] name;
    input signed [7:0] ta00;
    input signed [7:0] ta01;
    input signed [7:0] ta10;
    input signed [7:0] ta11;
    input signed [7:0] tb00;
    input signed [7:0] tb01;
    input signed [7:0] tb10;
    input signed [7:0] tb11;
    begin
        a00 = ta00;
        a01 = ta01;
        a10 = ta10;
        a11 = ta11;
        b00 = tb00;
        b01 = tb01;
        b10 = tb10;
        b11 = tb11;
        compute_expected;

        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;

        repeat (3) begin
            @(posedge clk);
            #1;
        end

        check_matrix(name);

        @(posedge clk);
        #1;
        if (done !== 1'b0 || busy !== 1'b0) begin
            $display("FAIL post-done idle check done=%b busy=%b time=%0t", done, busy, $time);
            errors = errors + 1;
        end
    end
endtask

initial begin
    $dumpfile("sim/matmul2x2_int8.vcd");
    $dumpvars(0, tb_matmul2x2_int8);

    clk = 1'b0;
    reset = 1'b1;
    start = 1'b0;
    a00 = 8'sd0;
    a01 = 8'sd0;
    a10 = 8'sd0;
    a11 = 8'sd0;
    b00 = 8'sd0;
    b01 = 8'sd0;
    b10 = 8'sd0;
    b11 = 8'sd0;
    errors = 0;
    displayed_failures = 0;
    test_number = 0;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 8 MATMUL CHECKS RUN");
    $display("1. Which A row and B column feed C00?");
    $display("2. What should an identity matrix do to another matrix?");
    $display("3. Why does done wait until after MAC1 has reached the PE accumulators?");
    $display("4. Which four PE accumulators should you inspect in GTKWave?");
    $display("============================================================");

    @(posedge clk);
    #1;
    reset = 1'b0;

    run_matrix("zero matrix", 8'sd0, 8'sd0, 8'sd0, 8'sd0,
               8'sd7, -8'sd3, 8'sd4, 8'sd5);
    run_matrix("identity times mixed", 8'sd1, 8'sd0, 8'sd0, 8'sd1,
               8'sd2, -8'sd3, 8'sd4, 8'sd5);
    run_matrix("positive matrix", 8'sd1, 8'sd2, 8'sd3, 8'sd4,
               8'sd5, 8'sd6, 8'sd7, 8'sd8);
    run_matrix("mixed signs", 8'sd2, -8'sd3, -8'sd4, 8'sd5,
               8'sd6, -8'sd7, 8'sd8, -8'sd9);
    run_matrix("boundary values", 8'sd127, -8'sd128, -8'sd1, 8'sd64,
               -8'sd128, 8'sd127, 8'sd127, -8'sd1);

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all matmul2x2_int8 tests passed with %0d checks", test_number);
    else
        $display("FAIL: %0d matmul2x2_int8 test(s) failed out of %0d checks", errors, test_number);
    $display("Open sim/matmul2x2_int8.vcd in GTKWave and inspect start, busy, done, the state path, PE inputs, and c00-c11.");
    $display("============================================================");

    $finish;
end

endmodule
