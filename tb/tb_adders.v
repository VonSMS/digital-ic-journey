`timescale 1ns/1ps

module tb_adders;

reg ha_a;
reg ha_b;
wire ha_sum;
wire ha_carry;

reg fa_a;
reg fa_b;
reg fa_cin;
wire fa_sum;
wire fa_cout;

reg [1:0] rca_a;
reg [1:0] rca_b;
reg       rca_cin;
wire [1:0] rca_sum;
wire       rca_cout;

reg [2:0] trca_a;
reg [2:0] trca_b;
reg       trca_cin;
wire [2:0] trca_sum;
wire       trca_cout;

integer i;
integer j;
integer k;

integer errors;
reg expected_sum;
reg expected_carry;
reg [2:0] expected_total;
reg [3:0] expected_3total;

half_adder dut_half_adder (
    .a(ha_a),
    .b(ha_b),
    .sum(ha_sum),
    .carry(ha_carry)
);

full_adder dut_full_adder (
    .a(fa_a),
    .b(fa_b),
    .cin(fa_cin),
    .sum(fa_sum),
    .cout(fa_cout)
);

ripple_carry_adder_2bit dut_ripple_carry_adder_2bit (
    .a(rca_a),
    .b(rca_b),
    .cin(rca_cin),
    .sum(rca_sum),
    .cout(rca_cout)
);

ripple_carry_adder_3bit dut_ripple_carry_adder_3bit (
    .a(trca_a),
    .b(trca_b),
    .cin(trca_cin),
    .sum(trca_sum),
    .cout(trca_cout)
);

initial begin
    $dumpfile("sim/adders.vcd");
    $dumpvars(0, tb_adders);

    errors = 0;

    $display("Testing half_adder");
    $display("a b | sum carry");
    $display("---------------");

    for (i = 0; i < 4; i = i + 1) begin
        {ha_a, ha_b} = i[1:0];
        #10;

        expected_sum   = ha_a ^ ha_b;
        expected_carry = ha_a & ha_b;

        $display("%b %b |  %b    %b", ha_a, ha_b, ha_sum, ha_carry);

        if (ha_sum !== expected_sum || ha_carry !== expected_carry) begin
            $display("ERROR half_adder: a=%b b=%b expected sum=%b carry=%b got sum=%b carry=%b",
                     ha_a, ha_b, expected_sum, expected_carry, ha_sum, ha_carry);
            errors = errors + 1;
        end
    end

    $display("");
    $display("Testing full_adder");
    $display("a b cin | sum cout");
    $display("------------------");

    for (i = 0; i < 8; i = i + 1) begin
        {fa_a, fa_b, fa_cin} = i[2:0];
        #10;

        expected_total = fa_a + fa_b + fa_cin;

        $display("%b %b  %b  |  %b    %b", fa_a, fa_b, fa_cin, fa_sum, fa_cout);

        if ({fa_cout, fa_sum} !== expected_total[1:0]) begin
            $display("ERROR full_adder: a=%b b=%b cin=%b expected cout=%b sum=%b got cout=%b sum=%b",
                     fa_a, fa_b, fa_cin, expected_total[1], expected_total[0], fa_cout, fa_sum);
            errors = errors + 1;
        end
    end

    $display("");
    $display("Testing ripple_carry_adder_2bit");
    $display(" a   b  cin | cout sum");
    $display("----------------------");

    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            for (k = 0; k < 2; k = k + 1) begin
                rca_a   = i[1:0];
                rca_b   = j[1:0];
                rca_cin = k[0];
                #10;

                expected_total = rca_a + rca_b + rca_cin;

                $display("%02b  %02b  %b   |   %b   %02b", rca_a, rca_b, rca_cin, rca_cout, rca_sum);

                if ({rca_cout, rca_sum} !== expected_total) begin
                    $display("ERROR ripple_carry_adder_2bit: a=%b b=%b cin=%b expected=%b got=%b",
                             rca_a, rca_b, rca_cin, expected_total, {rca_cout, rca_sum});
                    errors = errors + 1;
                end
            end
        end
    end

    $display("");
    $display("Testing ripple_carry_adder_3bit");
    $display(" a    b   cin | cout  sum");
    $display("--------------------------");

    for (i = 0; i < 8; i = i + 1) begin
        for (j = 0; j < 8; j = j + 1) begin
            for (k = 0; k < 2; k = k + 1) begin
                trca_a   = i[2:0];
                trca_b   = j[2:0];
                trca_cin = k[0];
                #10;

                expected_3total = trca_a + trca_b + trca_cin;

                $display("%03b  %03b   %b  |   %b   %03b", trca_a, trca_b, trca_cin, trca_cout, trca_sum);

                if ({trca_cout, trca_sum} !== expected_3total) begin
                    $display("ERROR ripple_carry_adder_3bit: a=%b b=%b cin=%b expected=%b got=%b",
                             trca_a, trca_b, trca_cin, expected_3total, {trca_cout, trca_sum});
                             errors = errors + 1;
                end
            end
        end
    end

    $display("");

    if (errors == 0) begin
        $display("PASS: all adder tests passed");
    end else begin
        $display("FAIL: %0d adder test(s) failed", errors);
    end

    $finish;
end

endmodule
