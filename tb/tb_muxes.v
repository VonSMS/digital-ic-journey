`timescale 1ns/1ps

module tb_muxes;

reg mux2_a;
reg mux2_b;
reg mux2_sel;
wire mux2_y;

reg mux4_d0;
reg mux4_d1;
reg mux4_d2;
reg mux4_d3;
reg [1:0] mux4_sel;
wire mux4_y_direct;
wire mux4_y_from_mux2;

reg [3:0] bus_a;
reg [3:0] bus_b;
reg       bus_sel;
wire [3:0] bus_y;

reg [3:0] block_a;
reg [3:0] block_b;
reg       choose_logic;
wire [3:0] block_y;

integer i;
integer j;
integer errors;
reg expected_bit;
reg [3:0] expected_bus;
reg [3:0] expected_block;

mux2 dut_mux2 (
    .a(mux2_a),
    .b(mux2_b),
    .sel(mux2_sel),
    .y(mux2_y)
);

mux4 dut_mux4_direct (
    .d0(mux4_d0),
    .d1(mux4_d1),
    .d2(mux4_d2),
    .d3(mux4_d3),
    .sel(mux4_sel),
    .y(mux4_y_direct)
);

mux4_from_mux2 dut_mux4_from_mux2 (
    .d0(mux4_d0),
    .d1(mux4_d1),
    .d2(mux4_d2),
    .d3(mux4_d3),
    .sel(mux4_sel),
    .y(mux4_y_from_mux2)
);

mux2_4bit dut_mux2_4bit (
    .a(bus_a),
    .b(bus_b),
    .sel(bus_sel),
    .y(bus_y)
);

muxed_adder_logic_block dut_muxed_adder_logic_block (
    .a(block_a),
    .b(block_b),
    .choose_logic(choose_logic),
    .y(block_y)
);

initial begin
    $dumpfile("sim/muxes.vcd");
    $dumpvars(0, tb_muxes);

    errors = 0;

    $display("Prediction warm-up before reading the results:");
    $display("1) mux2: a=0 b=1 sel=0 -> y should be ?");
    $display("2) mux2: a=0 b=1 sel=1 -> y should be ?");
    $display("3) mux4: d0d1d2d3=1010 sel=10 -> y should be ?");
    $display("");

    $display("Testing mux2");
    $display("a b sel | y");
    $display("-----------");

    for (i = 0; i < 8; i = i + 1) begin
        {mux2_a, mux2_b, mux2_sel} = i[2:0];
        #10;

        expected_bit = mux2_sel ? mux2_b : mux2_a;

        $display("%b %b  %b  | %b", mux2_a, mux2_b, mux2_sel, mux2_y);

        if (mux2_y !== expected_bit) begin
            $display("ERROR mux2: a=%b b=%b sel=%b expected y=%b got y=%b",
                     mux2_a, mux2_b, mux2_sel, expected_bit, mux2_y);
            errors = errors + 1;
        end
    end

    $display("");
    $display("Testing mux4 direct and mux4_from_mux2");
    $display("d3 d2 d1 d0 sel | direct built");
    $display("-------------------------------");

    for (i = 0; i < 16; i = i + 1) begin
        {mux4_d3, mux4_d2, mux4_d1, mux4_d0} = i[3:0];

        for (j = 0; j < 4; j = j + 1) begin
            mux4_sel = j[1:0];
            #10;

            case (mux4_sel)
                2'b00: expected_bit = mux4_d0;
                2'b01: expected_bit = mux4_d1;
                2'b10: expected_bit = mux4_d2;
                2'b11: expected_bit = mux4_d3;
                default: expected_bit = 1'b0;
            endcase

            $display(" %b  %b  %b  %b   %02b  |   %b      %b",
                     mux4_d3, mux4_d2, mux4_d1, mux4_d0, mux4_sel,
                     mux4_y_direct, mux4_y_from_mux2);

            if (mux4_y_direct !== expected_bit) begin
                $display("ERROR mux4 direct: d3d2d1d0=%b%b%b%b sel=%b expected y=%b got y=%b",
                         mux4_d3, mux4_d2, mux4_d1, mux4_d0, mux4_sel,
                         expected_bit, mux4_y_direct);
                errors = errors + 1;
            end

            if (mux4_y_from_mux2 !== expected_bit) begin
                $display("ERROR mux4_from_mux2: d3d2d1d0=%b%b%b%b sel=%b expected y=%b got y=%b",
                         mux4_d3, mux4_d2, mux4_d1, mux4_d0, mux4_sel,
                         expected_bit, mux4_y_from_mux2);
                errors = errors + 1;
            end

            if (mux4_y_direct !== mux4_y_from_mux2) begin
                $display("ERROR mux4 compare: direct=%b built=%b for d3d2d1d0=%b%b%b%b sel=%b",
                         mux4_y_direct, mux4_y_from_mux2,
                         mux4_d3, mux4_d2, mux4_d1, mux4_d0, mux4_sel);
                errors = errors + 1;
            end
        end
    end

    $display("");
    $display("Testing mux2_4bit bus selection");
    $display(" a     b   sel | y");
    $display("-------------------");

    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            bus_a = i[3:0];
            bus_b = j[3:0];

            bus_sel = 1'b0;
            #10;
            expected_bus = bus_a;
            $display("%04b  %04b   %b  | %04b", bus_a, bus_b, bus_sel, bus_y);
            if (bus_y !== expected_bus) begin
                $display("ERROR mux2_4bit: a=%b b=%b sel=%b expected y=%b got y=%b",
                         bus_a, bus_b, bus_sel, expected_bus, bus_y);
                errors = errors + 1;
            end

            bus_sel = 1'b1;
            #10;
            expected_bus = bus_b;
            $display("%04b  %04b   %b  | %04b", bus_a, bus_b, bus_sel, bus_y);
            if (bus_y !== expected_bus) begin
                $display("ERROR mux2_4bit: a=%b b=%b sel=%b expected y=%b got y=%b",
                         bus_a, bus_b, bus_sel, expected_bus, bus_y);
                errors = errors + 1;
            end
        end
    end

    $display("");
    $display("Testing muxed_adder_logic_block");
    $display(" a     b   choose_logic | y");
    $display("----------------------------");

    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            block_a = i[3:0];
            block_b = j[3:0];

            choose_logic = 1'b0;
            #10;
            expected_block = block_a + block_b;
            $display("%04b  %04b       %b       | %04b", block_a, block_b, choose_logic, block_y);
            if (block_y !== expected_block) begin
                $display("ERROR muxed_adder_logic_block add path: a=%b b=%b expected y=%b got y=%b",
                         block_a, block_b, expected_block, block_y);
                errors = errors + 1;
            end

            choose_logic = 1'b1;
            #10;
            expected_block = block_a ^ block_b;
            $display("%04b  %04b       %b       | %04b", block_a, block_b, choose_logic, block_y);
            if (block_y !== expected_block) begin
                $display("ERROR muxed_adder_logic_block logic path: a=%b b=%b expected y=%b got y=%b",
                         block_a, block_b, expected_block, block_y);
                errors = errors + 1;
            end
        end
    end

    $display("");

    if (errors == 0) begin
        $display("PASS: all mux tests passed");
    end else begin
        $display("FAIL: %0d mux test(s) failed", errors);
    end

    $finish;
end

endmodule
