`timescale 1ns/1ps

module tb_register_file4x4;

reg        clk;
reg        reset;
reg        write_enable;
reg  [1:0] write_addr;
reg  [3:0] write_data;
reg  [1:0] read_addr_a;
reg  [1:0] read_addr_b;
wire [3:0] read_data_a;
wire [3:0] read_data_b;

integer errors;
integer test_number;
integer i;
integer j;

reg [3:0] expected_regs [0:3];

register_file4x4 dut (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr_a(read_addr_a),
    .read_addr_b(read_addr_b),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task check_read_a;
    input [8*48-1:0] name;
    input [3:0] expected;
    begin
        test_number = test_number + 1;
        if (read_data_a !== expected) begin
            $display("FAIL test %0d %-40s read_addr_a=%0d expected=%04b actual=%04b time=%0t",
                     test_number, name, read_addr_a, expected, read_data_a, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-40s read_addr_a=%0d value=%04b time=%0t",
                     test_number, name, read_addr_a, read_data_a, $time);
        end
    end
endtask

task check_read_b;
    input [8*48-1:0] name;
    input [3:0] expected;
    begin
        test_number = test_number + 1;
        if (read_data_b !== expected) begin
            $display("FAIL test %0d %-40s read_addr_b=%0d expected=%04b actual=%04b time=%0t",
                     test_number, name, read_addr_b, expected, read_data_b, $time);
            errors = errors + 1;
        end else begin
            $display("PASS test %0d %-40s read_addr_b=%0d value=%04b time=%0t",
                     test_number, name, read_addr_b, read_data_b, $time);
        end
    end
endtask

task check_read_pair;
    input [8*48-1:0] name;
    begin
        #1;
        check_read_a(name, expected_regs[read_addr_a]);
        check_read_b(name, expected_regs[read_addr_b]);
    end
endtask

task apply_reset;
    begin
        reset = 1'b1;
        write_enable = 1'b0;
        write_addr = 2'b00;
        write_data = 4'b0000;
        read_addr_a = 2'b00;
        read_addr_b = 2'b11;
        expected_regs[0] = 4'b0000;
        expected_regs[1] = 4'b0000;
        expected_regs[2] = 4'b0000;
        expected_regs[3] = 4'b0000;
        #1;
        check_read_pair("async reset clears all registers");
        @(negedge clk);
        reset = 1'b0;
    end
endtask

task write_register;
    input [1:0] addr;
    input [3:0] data;
    begin
        @(negedge clk);
        write_enable = 1'b1;
        write_addr = addr;
        write_data = data;
        @(posedge clk);
        #1;
        expected_regs[addr] = data;
        write_enable = 1'b0;
    end
endtask

task disabled_write;
    input [1:0] addr;
    input [3:0] data;
    begin
        @(negedge clk);
        write_enable = 1'b0;
        write_addr = addr;
        write_data = data;
        @(posedge clk);
        #1;
    end
endtask

initial begin
    $dumpfile("sim/register_file4x4.vcd");
    $dumpvars(0, tb_register_file4x4);

    errors = 0;
    test_number = 0;
    reset = 1'b0;
    write_enable = 1'b0;
    write_addr = 2'b00;
    write_data = 4'b0000;
    read_addr_a = 2'b00;
    read_addr_b = 2'b00;

    $display("============================================================");
    $display("PREDICT BEFORE THE CHECKS RUN");
    $display("1. After reset, what are r0, r1, r2, and r3?");
    $display("2. With write_enable=0, should a posedge change storage?");
    $display("3. If write_addr=2 and write_data=1010, which register changes?");
    $display("4. Can read port A and B read two different registers at once?");
    $display("5. If read and write use the same address, when does read data update?");
    $display("============================================================");

    apply_reset;

    read_addr_a = 2'b00;
    read_addr_b = 2'b11;
    disabled_write(2'b00, 4'b1111);
    check_read_pair("disabled write keeps reset values");

    write_register(2'b00, 4'b0001);
    read_addr_a = 2'b00;
    read_addr_b = 2'b01;
    check_read_pair("write r0 then read r0 and r1");

    write_register(2'b01, 4'b0011);
    read_addr_a = 2'b01;
    read_addr_b = 2'b00;
    check_read_pair("write r1 then read r1 and r0");

    write_register(2'b10, 4'b1010);
    read_addr_a = 2'b10;
    read_addr_b = 2'b01;
    check_read_pair("write r2 then read r2 and r1");

    write_register(2'b11, 4'b1100);
    read_addr_a = 2'b01;
    read_addr_b = 2'b11;
    check_read_pair("two simultaneous reads");

    write_register(2'b01, 4'b1110);
    read_addr_a = 2'b01;
    read_addr_b = 2'b01;
    check_read_pair("overwrite r1 and read same register twice");

    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            read_addr_a = i[1:0];
            read_addr_b = j[1:0];
            check_read_pair("exhaustive read address pair");
        end
    end

    $display("============================================================");
    if (errors == 0)
        $display("PASS: all register_file4x4 tests passed");
    else
        $display("FAIL: %0d register_file4x4 test(s) failed", errors);
    $display("Open sim/register_file4x4.vcd in GTKWave and inspect the write/read timing.");
    $display("============================================================");

    $finish;
end

endmodule
