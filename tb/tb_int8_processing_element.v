`timescale 1ns/1ps

module tb_int8_processing_element;

reg clk;
reg reset;
reg clear;
reg enable;
reg signed [7:0] a;
reg signed [7:0] b;
wire signed [15:0] product;
wire signed [17:0] acc;

integer errors;
integer displayed_failures;
integer test_number;
reg signed [15:0] expected_product;
reg signed [17:0] expected_acc;
reg signed [17:0] expected_next;

int8_processing_element dut (
    .clk(clk),
    .reset(reset),
    .clear(clear),
    .enable(enable),
    .a(a),
    .b(b),
    .product(product),
    .acc(acc)
);

always #5 clk = ~clk;

task check_state;
    input [8*56-1:0] name;
    begin
        test_number = test_number + 1;
        if (product !== expected_product || acc !== expected_acc) begin
            if (displayed_failures < 20) begin
                $display("FAIL test %0d %-36s a=%0d b=%0d clear=%b enable=%b product=%0d expected_product=%0d acc=%0d expected_acc=%0d time=%0t",
                         test_number, name, a, b, clear, enable, product,
                         expected_product, acc, expected_acc, $time);
                displayed_failures = displayed_failures + 1;
            end
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-36s product=%0d acc=%0d",
                     test_number, name, product, acc);
        end
    end
endtask

task apply_cycle;
    input [8*56-1:0] name;
    input signed [7:0] test_a;
    input signed [7:0] test_b;
    input test_clear;
    input test_enable;
    begin
        a = test_a;
        b = test_b;
        clear = test_clear;
        enable = test_enable;
        expected_product = test_a * test_b;

        if (test_clear)
            expected_next = 18'sd0;
        else if (test_enable)
            expected_next = expected_acc + {{2{expected_product[15]}}, expected_product};
        else
            expected_next = expected_acc;

        @(posedge clk);
        #1;
        expected_acc = expected_next;
        check_state(name);
    end
endtask

task clear_accumulator;
    begin
        apply_cycle("clear before dot product", 8'sd0, 8'sd0, 1'b1, 1'b0);
    end
endtask

task two_product_dot;
    input [8*56-1:0] name;
    input signed [7:0] a0;
    input signed [7:0] b0;
    input signed [7:0] a1;
    input signed [7:0] b1;
    begin
        clear_accumulator;
        apply_cycle({name, " product 0"}, a0, b0, 1'b0, 1'b1);
        apply_cycle({name, " product 1"}, a1, b1, 1'b0, 1'b1);
    end
endtask

initial begin
//create the waveform file，dumpvars指定要把哪些模块层级信号写进VCD
    $dumpfile("sim/int8_processing_element.vcd");
    $dumpvars(0, tb_int8_processing_element);

    clk = 1'b0;
    reset = 1'b1;
    clear = 1'b0;
    enable = 1'b0;
    a = 8'sd0;
    b = 8'sd0;
    errors = 0;
    displayed_failures = 0;
    test_number = 0;
    expected_product = 16'sd0;
    expected_acc = 18'sd0;
    expected_next = 18'sd0;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 7 PE CHECKS RUN");
    $display("1. C00 = 2*4 + (-3)*5 should equal what signed value?");
    $display("2. If clear and enable are both 1, should the PE clear or accumulate?");
    $display("3. What should acc do when enable is 0 but a and b change?");
    $display("4. Which waveform signals identify a clear/enable priority bug?");
    $display("============================================================");

    @(posedge clk);
    #1;
    check_state("reset clears PE accumulator");
    reset = 1'b0;

    apply_cycle("disabled hold from zero", 8'sd7, 8'sd3, 1'b0, 1'b0);
    apply_cycle("normal positive product", 8'sd7, 8'sd3, 1'b0, 1'b1);
    apply_cycle("disabled product change hold", -8'sd8, 8'sd9, 1'b0, 1'b0);
    apply_cycle("clear and enable clear wins", 8'sd4, 8'sd5, 1'b1, 1'b1);

    two_product_dot("dot mixed signs", 8'sd2, 8'sd4, -8'sd3, 8'sd5);
    apply_cycle("hold finished dot", 8'sd100, 8'sd100, 1'b0, 1'b0);
    two_product_dot("dot negative positive", -8'sd7, 8'sd3, 8'sd12, -8'sd5);
    two_product_dot("dot negative positive two", 8'sd3, -8'sd2, 8'sd4, 8'sd5);
    two_product_dot("dot boundary positive", 8'sd127, 8'sd127, -8'sd128, -8'sd128);
    two_product_dot("dot boundary negative", -8'sd128, 8'sd127, 8'sd127, -8'sd128);

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all int8_processing_element tests passed with %0d checks", test_number);
    else
        $display("FAIL: %0d int8_processing_element test(s) failed out of %0d checks", errors, test_number);
    $display("Open sim/int8_processing_element.vcd in GTKWave and inspect clk, clear, enable, a, b, product, acc, and expected_acc.");
    $display("============================================================");

    $finish;
end

endmodule
