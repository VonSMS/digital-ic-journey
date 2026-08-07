`timescale 1ns/1ps

module register_file4x4 (
    input        clk,
    input        reset,
    input        write_enable,
    input  [1:0] write_addr,
    input  [3:0] write_data,
    input  [1:0] read_addr_a,
    input  [1:0] read_addr_b,
    output reg [3:0] read_data_a,
    output reg [3:0] read_data_b
);

reg [3:0] r0;
reg [3:0] r1;
reg [3:0] r2;
reg [3:0] r3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        r0 <= 4'b0000;
        r1 <= 4'b0000;
        r2 <= 4'b0000;
        r3 <= 4'b0000;
    end else if (write_enable) begin
        case (write_addr)
            2'b00: r0 <= write_data;
            2'b01: r1 <= write_data;
            2'b10: r2 <= write_data;
            2'b11: r3 <= write_data;
            default: begin
                r0 <= r0;
                r1 <= r1;
                r2 <= r2;
                r3 <= r3;
            end
        endcase
    end
end

always @(*) begin
    case (read_addr_a)
        2'b00: read_data_a = r0;
        2'b01: read_data_a = r1;
        2'b10: read_data_a = r2;
        2'b11: read_data_a = r3;
        default: read_data_a = 4'b0000;
    endcase
end

always @(*) begin
    case (read_addr_b)
        2'b00: read_data_b = r0;
        2'b01: read_data_b = r1;
        2'b10: read_data_b = r2;
        2'b11: read_data_b = r3;
        default: read_data_b = 4'b0000;
    endcase
end

endmodule
