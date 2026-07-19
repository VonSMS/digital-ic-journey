module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

wire ab_sum;
wire ab_carry;
wire cin_carry;

assign ab_sum    = a ^ b;
assign sum       = ab_sum ^ cin;
assign ab_carry  = a & b;
assign cin_carry = ab_sum & cin;
assign cout      = ab_carry | cin_carry;

endmodule

module ripple_carry_adder_2bit (
    input  [1:0] a,
    input  [1:0] b,
    input        cin,
    output [1:0] sum,
    output       cout
);

wire carry_bit0;

full_adder fa0 (
    .a(a[0]),
    .b(b[0]),
    .cin(cin),
    .sum(sum[0]),
    .cout(carry_bit0)
);

full_adder fa1 (
    .a(a[1]),
    .b(b[1]),
    .cin(carry_bit0),
    .sum(sum[1]),
    .cout(cout)
);

endmodule

module ripple_carry_adder_3bit (
    input  [2:0] a,
    input  [2:0] b,
    input        cin,
    output [2:0] sum,
    output       cout
);

wire carry_bit0;
wire carry_bit1;

full_adder fa0 (
    .a(a[0]),
    .b(b[0]),
    .cin(cin),
    .sum(sum[0]),
    .cout(carry_bit0)
);

full_adder fa1 (
    .a(a[1]),
    .b(b[1]),
    .cin(carry_bit0),
    .sum(sum[1]),
    .cout(carry_bit1)
);

full_adder fa2 (
    .a(a[2]),
    .b(b[2]),
    .cin(carry_bit1),
    .sum(sum[2]),
    .cout(cout)
);

endmodule
