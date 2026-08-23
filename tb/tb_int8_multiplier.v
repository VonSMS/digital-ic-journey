`timescale 1ns/1ps

module tb_int8_multiplier;

reg  signed [7:0]  a;
reg  signed [7:0]  b;
wire signed [15:0] product;

integer errors;
integer displayed_failures;
integer test_number;
integer ai;
integer bi;
integer si;
reg signed [15:0] expected;

int8_multiplier dut (
    .a(a),
    .b(b),
    .product(product)
);

task check_product;
    input [8*48-1:0] name;
    input signed [7:0] test_a;
    input signed [7:0] test_b;
    begin
        a = test_a;
        b = test_b;
        expected = test_a * test_b;
        #1;
        test_number = test_number + 1;
        if (product !== expected) begin
            if (displayed_failures < 20) begin
                $display("FAIL test %0d %-32s a=%0d b=%0d product=%0d expected=%0d bits=%h exp_bits=%h time=%0t",
                         test_number, name, a, b, product, expected, product, expected, $time);
                displayed_failures = displayed_failures + 1;
            end
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-32s a=%0d b=%0d product=%0d bits=%h",
                     test_number, name, a, b, product, product);
        end
    end
endtask

task sampled_sweep;
    begin
        for (si = 0; si < 32; si = si + 1) begin
            check_product("sampled signed sweep", $signed((si * 17) - 128), $signed(127 - (si * 9)));
        end
    end
endtask

task exhaustive_sweep;
    begin
        for (ai = -128; ai <= 127; ai = ai + 1) begin
            for (bi = -128; bi <= 127; bi = bi + 1) begin
                a = ai[7:0];
                b = bi[7:0];
                expected = $signed(ai[7:0]) * $signed(bi[7:0]);
                #1;
                test_number = test_number + 1;
                if (product !== expected) begin
                    if (displayed_failures < 20) begin
                        $display("FAIL test %0d exhaustive a=%0d b=%0d product=%0d expected=%0d bits=%h exp_bits=%h time=%0t",
                                 test_number, a, b, product, expected, product, expected, $time);
                        displayed_failures = displayed_failures + 1;
                    end
                    errors = errors + 1;
                end
            end
        end
    end
endtask

initial begin
    $dumpfile("sim/int8_multiplier.vcd");
    $dumpvars(0, tb_int8_multiplier);

    errors = 0;
    displayed_failures = 0;
    test_number = 0;
    a = 8'sd0;
    b = 8'sd0;

    $display("============================================================");
    $display("PREDICT BEFORE THE DAY 5 CHECKS RUN");
    $display("1. 7 * 3 should produce which 16-bit signed value?");
    $display("2. -7 * 3 should produce which sign and magnitude?");
    $display("3. -128 * -128 needs why many product bits?");
    $display("4. What first failure do you expect if the RTL treats inputs as unsigned?");
    $display("============================================================");

    check_product("zero times positive", 8'sd0, 8'sd42);
    check_product("positive normal", 8'sd7, 8'sd3);
    check_product("negative times positive", -8'sd7, 8'sd3);
    check_product("positive times negative", 8'sd12, -8'sd5);
    check_product("negative times negative", -8'sd9, -8'sd6);
    check_product("max positive times one", 8'sd127, 8'sd1);
    check_product("max positive times max positive", 8'sd127, 8'sd127);
    check_product("min negative times one", -8'sd128, 8'sd1);
    check_product("min negative times minus one", -8'sd128, -8'sd1);
    check_product("minus one times max positive", -8'sd1, 8'sd127);
    check_product("minus one times minus one", -8'sd1, -8'sd1);
    check_product("min negative times min negative", -8'sd128, -8'sd128);

    sampled_sweep;
    exhaustive_sweep;

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all int8_multiplier tests passed with %0d checks", test_number);
    else
        $display("FAIL: %0d int8_multiplier test(s) failed out of %0d checks", errors, test_number);
    $display("Open sim/int8_multiplier.vcd in GTKWave and inspect a, b, product, and expected.");
    $display("============================================================");

    $finish;
end

endmodule
