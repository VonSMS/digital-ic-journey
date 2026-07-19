# Day 4 Adders

Date: 2026-07-19

## Goal

Learn how one-bit adders are built from gates, then connect full adders into a small 2-bit ripple-carry adder.

By the end of Day 4, I should be able to:

1. Explain half adder sum and carry.
2. Explain full adder sum, carry-in, and carry-out.
3. Connect XOR, AND, and OR gates to build adders.
4. Write `half_adder.v` and `full_adder.v`.
5. Write a testbench that tries every input combination.
6. Make the testbench self-checking with `if` statements and error messages.
7. Generate a VCD waveform and inspect it with GTKWave.

## 1. Half Adder Theory

A half adder adds two one-bit numbers:

```text
a + b
```

It produces two outputs:

| Output | Meaning |
| --- | --- |
| `sum` | The low bit of the answer |
| `carry` | The high bit of the answer |

Truth table:

| a | b | sum | carry |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

The sum is `1` when exactly one input is `1`, so:

```verilog
assign sum = a ^ b;
```

The carry is `1` only when both inputs are `1`, so:

```verilog
assign carry = a & b;
```

## 2. Full Adder Theory

A full adder adds three one-bit values:

```text
a + b + cin
```

`cin` means carry-in. It is the carry from the previous lower bit.

It produces:

| Output | Meaning |
| --- | --- |
| `sum` | The low bit of `a + b + cin` |
| `cout` | The carry-out to the next higher bit |

Truth table:

| a | b | cin | sum | cout |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

## 3. Gates Used In Adders

The full adder can be understood in two stages.

First add `a` and `b`:

```verilog
assign ab_sum   = a ^ b;
assign ab_carry = a & b;
```

Then add `cin` to that partial sum:

```verilog
assign sum       = ab_sum ^ cin;
assign cin_carry = ab_sum & cin;
```

The final carry-out is true if either stage produced a carry:

```verilog
assign cout = ab_carry | cin_carry;
```

So XOR finds the sum bit, AND finds carry conditions, and OR combines carry sources.

## 4. Verilog Files

Files created today:

```text
rtl/half_adder.v
rtl/full_adder.v
tb/tb_adders.v
docs/day4_adders.md
```

`rtl/full_adder.v` also contains `ripple_carry_adder_2bit`, which uses two `full_adder` modules.

## 5. Self-Checking Testbench

The testbench tries every input combination:

| Circuit | Cases checked |
| --- | --- |
| Half adder | 4 combinations |
| Full adder | 8 combinations |
| 2-bit ripple-carry adder | 32 combinations |

The important idea is that the testbench calculates the expected answer, then compares it with the design output.

Example:

```verilog
expected_total = fa_a + fa_b + fa_cin;

if ({fa_cout, fa_sum} !== expected_total[1:0]) begin
    $display("ERROR full_adder: ...");
    errors = errors + 1;
end
```

For the 2-bit adder, this expression is useful:

```verilog
{rca_cout, rca_sum}
```

It joins the carry-out and the 2-bit sum into a 3-bit result.

Example:

```text
cout = 1
sum  = 01
combined result = 101
```

That means decimal 5.

## 6. Commands

From the repository root:

```powershell
cd C:\Users\14138\Documents\IC_design_project_2026\digital-ic-journey
iverilog -o .\sim\adders.vvp .\rtl\half_adder.v .\rtl\full_adder.v .\tb\tb_adders.v
vvp .\sim\adders.vvp
```

Expected final line:

```text
PASS: all adder tests passed
```

The testbench writes this waveform:

```text
sim/adders.vcd
```

Open it in GTKWave:

```powershell
gtkwave .\sim\adders.vcd
```

## 7. GTKWave Practice

In GTKWave:

1. Open `tb_adders`.
2. Add the half adder signals: `ha_a`, `ha_b`, `ha_sum`, `ha_carry`.
3. Add the full adder signals: `fa_a`, `fa_b`, `fa_cin`, `fa_sum`, `fa_cout`.
4. Add the ripple-carry signals: `rca_a`, `rca_b`, `rca_cin`, `rca_sum`, `rca_cout`.
5. Zoom to fit the full simulation.

Things to notice:

1. Half adder carry only becomes `1` for `1 + 1`.
2. Full adder `cout` becomes `1` when at least two of `a`, `b`, and `cin` are `1`.
3. In the 2-bit adder, bit 0 produces an internal carry named `carry_bit0`.
4. `carry_bit0` becomes the `cin` of bit 1.

## 8. Extra Practice

Try these edits after the simulation passes:

1. Temporarily break the half adder with `assign sum = a | b;`.
2. Re-run the testbench and read the error message.
3. Fix it back to `assign sum = a ^ b;`.
4. Add a 3-bit ripple-carry adder using three full adders.
5. Write a new self-checking loop for all `a`, `b`, and `cin` combinations.

## Day 4 Summary

A half adder adds two bits using XOR for `sum` and AND for `carry`. A full adder adds `a`, `b`, and `cin`; it uses two XOR operations for the final sum, two AND operations for possible carries, and one OR operation for `cout`. A ripple-carry adder connects full adders in a chain, where each carry-out becomes the next bit's carry-in.
