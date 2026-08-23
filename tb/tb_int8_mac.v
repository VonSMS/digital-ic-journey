`timescale 1ns/1ps

module tb_int8_mac;

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
reg signed [17:0] expected_acc;
reg signed [17:0] expected_next;
reg signed [15:0] expected_product;

int8_mac dut (
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
    input [8*48-1:0] name;
    begin
        test_number = test_number + 1;
        if (acc !== expected_acc || product !== expected_product) begin
            if (displayed_failures < 20) begin
                $display("FAIL test %0d %-32s a=%0d b=%0d enable=%b clear=%b product=%0d expected_product=%0d acc=%0d expected_acc=%0d acc_bits=%h exp_bits=%h time=%0t",
                         test_number, name, a, b, enable, clear, product,
                         expected_product, acc, expected_acc, acc, expected_acc, $time);
                displayed_failures = displayed_failures + 1;
            end
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-32s product=%0d acc=%0d bits=%h",
                     test_number, name, product, acc, acc);
        end
    end
endtask

task apply_cycle;
    input [8*48-1:0] name;
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

initial begin
    $dumpfile("sim/int8_mac.vcd");
    $dumpvars(0, tb_int8_mac);

    clk = 1'b0;
    reset = 1'b1;
    clear = 1'b0;
    enable = 1'b0;
    a = 8'sd0;
    b = 8'sd0;
    errors = 0;
    displayed_failures = 0;
    test_number = 0;
    expected_acc = 18'sd0;
    expected_product = 16'sd0;
    expected_next = 18'sd0;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 6 CHECKS RUN");
    $display("1. Why does a two-product INT8 dot product need more than signed 16 bits?");
    $display("2. What should acc do when product changes but enable is 0?");
    $display("3. What should happen on clear?");
    $display("4. What first failure do you expect if negative products are zero-extended?");
    $display("============================================================");

    @(posedge clk);
    #1;
    check_state("reset clears accumulator");
    reset = 1'b0;

    apply_cycle("disabled enable holds zero", 8'sd7, 8'sd3, 1'b0, 1'b0);
    apply_cycle("positive accumulate 7*3", 8'sd7, 8'sd3, 1'b0, 1'b1);
    apply_cycle("positive accumulate 4*5", 8'sd4, 8'sd5, 1'b0, 1'b1);
    apply_cycle("disabled product changes hold", -8'sd8, 8'sd9, 1'b0, 1'b0);
    apply_cycle("clear accumulator", -8'sd8, 8'sd9, 1'b1, 1'b1);
    apply_cycle("negative accumulation", -8'sd7, 8'sd3, 1'b0, 1'b1);
    apply_cycle("mixed sign accumulation", 8'sd12, -8'sd5, 1'b0, 1'b1);
    apply_cycle("negative times negative", -8'sd9, -8'sd6, 1'b0, 1'b1);
    apply_cycle("clear before boundary", 8'sd0, 8'sd0, 1'b1, 1'b0);
    apply_cycle("max positive boundary", 8'sd127, 8'sd127, 1'b0, 1'b1);
    apply_cycle("min negative boundary one", -8'sd128, -8'sd128, 1'b0, 1'b1);
    apply_cycle("min negative boundary two", -8'sd128, -8'sd128, 1'b0, 1'b1);
    apply_cycle("minus one boundary", -8'sd1, 8'sd127, 1'b0, 1'b1);
    apply_cycle("final disabled hold", 8'sd100, 8'sd100, 1'b0, 1'b0);

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all int8_mac tests passed with %0d checks", test_number);
    else
        $display("FAIL: %0d int8_mac test(s) failed out of %0d checks", errors, test_number);
    $display("Open sim/int8_mac.vcd in GTKWave and inspect clk, clear, enable, product, acc, and expected_acc.");
    $display("============================================================");

    $finish;
end

endmodule
