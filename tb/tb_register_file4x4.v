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

task check_all_read_pairs;
    input [8*48-1:0] name;
    begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                read_addr_a = i[1:0];
                read_addr_b = j[1:0];
                check_read_pair(name);
            end
        end
    end
endtask

task check_same_address_write_timing;
    begin
        write_register(2'b10, 4'b1010);
        write_register(2'b11, 4'b1100);

        @(negedge clk);
        read_addr_a = 2'b10;
        read_addr_b = 2'b11;
        write_enable = 1'b1;
        write_addr = 2'b10;
        write_data = 4'b1111;

        check_read_pair("same-address before edge sees old value");

        @(posedge clk);
        #1;
        expected_regs[2] = 4'b1111;
        check_read_pair("same-address after edge sees new value");
        write_enable = 1'b0;
    end
endtask

task check_reset_recovery;
    begin
        write_register(2'b00, 4'b0101);
        write_register(2'b01, 4'b0110);
        write_register(2'b10, 4'b1001);
        write_register(2'b11, 4'b1111);

        apply_reset;
        check_all_read_pairs("reset recovery cleared read pair");

        write_register(2'b00, 4'b0010);
        write_register(2'b01, 4'b0100);
        write_register(2'b10, 4'b1000);
        write_register(2'b11, 4'b0001);
        check_all_read_pairs("reset recovery rewrote read pair");
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
    $display("PREDICT BEFORE THE DAY 2 CHECKS RUN");
    $display("1. Why should expected_regs update after the clocked write event?");
    $display("2. For same-address read/write, what does the read port show before the edge?");
    $display("3. What does that same read port show shortly after the edge?");
    $display("4. After reset recovery, should old nonzero values survive?");
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

    check_all_read_pairs("exhaustive read address pair");

    check_same_address_write_timing;

    check_reset_recovery;

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
