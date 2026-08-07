`timescale 1ns/1ps

module tb_decoder2to4;

reg        enable;
reg  [1:0] select;
wire [3:0] y;

integer i;
integer errors;
reg [3:0] expected_y;

decoder2to4 dut (
    .enable(enable),
    .select(select),
    .y(y)
);

initial begin
    $dumpfile("sim/decoder2to4.vcd");
    $dumpvars(0, tb_decoder2to4);

    errors = 0;

    $display("Prediction warm-up before reading the results:");
    $display("A decoder turns an address into a one-hot output.");
    $display("1) enable=0 select=00 -> y should be ?");
    $display("2) enable=1 select=00 -> y should be ?");
    $display("3) enable=1 select=01 -> y should be ?");
    $display("4) enable=1 select=10 -> y should be ?");
    $display("5) enable=1 select=11 -> y should be ?");
    $display("");

    $display("Testing decoder2to4");
    $display("enable select | y    expected");
    $display("----------------------------");

    for (i = 0; i < 8; i = i + 1) begin
        {enable, select} = i[2:0];
        #10;

        if (enable) begin
            expected_y = 4'b0001 << select;
        end else begin
            expected_y = 4'b0000;
        end

        $display("   %b      %02b   | %04b   %04b",
                 enable, select, y, expected_y);

        if (y !== expected_y) begin
            $display("ERROR decoder2to4: enable=%b select=%b expected y=%b got y=%b",
                     enable, select, expected_y, y);
            errors = errors + 1;
        end
    end

    $display("");

    if (errors == 0) begin
        $display("PASS: all decoder2to4 tests passed");
    end else begin
        $display("FAIL: %0d decoder2to4 test(s) failed", errors);
    end

    $finish;
end

endmodule
