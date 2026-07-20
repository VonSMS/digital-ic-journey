# Day 5 Multiplexers

Date: 2026-07-20

## Goal

Learn multiplexers and use them as basic combinational building blocks.

By the end of Day 5, I should be able to:

1. Explain what a multiplexer does.
2. Read a 2-to-1 mux truth table.
3. Use 2 select bits to control a 4-to-1 mux.
4. Write direct mux logic in Verilog.
5. Build a 4-to-1 mux from three smaller 2-to-1 mux modules.
6. Write a self-checking testbench that tries every input and select combination.
7. Inspect mux behavior in GTKWave.
8. Debug wrong select width, missing cases, and wrong port connections.

## 1. Intuition

A multiplexer, usually called a mux, is a digital selector.

Imagine several wires are carrying possible values, but only one value is allowed to pass through to the output. The select signal chooses which input wire wins.

Short thinking question:

```text
If a mux is a selector, what should happen to the output when the data inputs stay the same but sel changes?
```

## 2. 2-to-1 Mux

A 2-to-1 mux has two data inputs, one select input, and one output.

```text
sel = 0 chooses a
sel = 1 chooses b
```

Truth table:

| sel | y |
| --- | --- |
| 0 | a |
| 1 | b |

Full input table:

| a | b | sel | y |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

Verilog:

```verilog
assign y = sel ? b : a;
```

Read it as:

```text
if sel is 1, y gets b; otherwise, y gets a
```

## 3. 4-to-1 Mux

A 4-to-1 mux has four data inputs and one output. It needs 2 select bits because 2 bits can name 4 choices.

| sel | selected input |
| --- | --- |
| 00 | d0 |
| 01 | d1 |
| 10 | d2 |
| 11 | d3 |

Short thinking question:

```text
Why is one select bit not enough for four inputs?
```

## 4. Files

Files created today:

```text
rtl/mux2.v
rtl/mux4.v
tb/tb_muxes.v
docs/day5_muxes.md
```

`rtl/mux2.v` contains:

1. `mux2`, a 1-bit 2-to-1 mux.
2. `mux2_4bit`, a 4-bit bus mux.
3. `muxed_adder_logic_block`, a small combinational block that chooses between an adder result and a logic result.

`rtl/mux4.v` contains:

1. `mux4`, a direct 4-to-1 mux using `case`.
2. `mux4_from_mux2`, a 4-to-1 mux built from three `mux2` modules.

## 5. Building Mux4 From Mux2

The built version uses two layers.

First layer:

```text
sel[0] chooses inside each pair

d0/d1 -> low_pair_y
d2/d3 -> high_pair_y
```

Second layer:

```text
sel[1] chooses between low_pair_y and high_pair_y
```

Signal path example:

```text
d3=1, d2=0, d1=1, d0=0, sel=10

sel[0] = 0, so:
low_pair_y  = d0 = 0
high_pair_y = d2 = 0

sel[1] = 1, so:
y = high_pair_y = 0
```

Thinking question:

```text
For sel=11, which two mux2 modules does the selected value pass through?
```

## 6. Self-Checking Testbench

The testbench checks:

| Circuit | Cases checked |
| --- | --- |
| `mux2` | 8 combinations |
| `mux4` | 64 combinations |
| `mux4_from_mux2` | 64 combinations |
| `mux2_4bit` | 512 checks |
| `muxed_adder_logic_block` | 512 checks |

Important idea:

```verilog
expected_bit = mux2_sel ? mux2_b : mux2_a;

if (mux2_y !== expected_bit) begin
    $display("ERROR mux2: ...");
    errors = errors + 1;
end
```

For the 4-to-1 mux, the testbench uses a `case` statement to calculate the expected selected input.

## 7. Commands

From the MSYS2 UCRT64 terminal:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
iverilog -o ./sim/muxes.vvp ./rtl/mux2.v ./rtl/mux4.v ./tb/tb_muxes.v
vvp ./sim/muxes.vvp
```

Expected final line:

```text
PASS: all mux tests passed
```

The testbench writes:

```text
sim/muxes.vcd
```

Open the waveform:

```bash
gtkwave ./sim/muxes.vcd
```

## 8. Predict Before Simulating

Before running the testbench, fill these in:

| Circuit | Inputs | Predict y |
| --- | --- | --- |
| `mux2` | `a=0 b=1 sel=0` | ? |
| `mux2` | `a=0 b=1 sel=1` | ? |
| `mux4` | `d3d2d1d0=1010 sel=00` | ? |
| `mux4` | `d3d2d1d0=1010 sel=01` | ? |
| `mux4` | `d3d2d1d0=1010 sel=10` | ? |
| `mux4` | `d3d2d1d0=1010 sel=11` | ? |
| `mux2_4bit` | `a=1100 b=0011 sel=0` | ? |
| `mux2_4bit` | `a=1100 b=0011 sel=1` | ? |

Then run the simulation and compare.

## 9. Intentional Bug Practice

After the clean version passes, temporarily break `mux4_from_mux2`.

Change this final mux connection:

```verilog
.sel(sel[1]),
```

to this intentional bug:

```verilog
.sel(sel[0]),
```

Re-run:

```bash
iverilog -o ./sim/muxes.vvp ./rtl/mux2.v ./rtl/mux4.v ./tb/tb_muxes.v
vvp ./sim/muxes.vvp
```

The testbench should print `ERROR mux4_from_mux2` messages.

Debugging questions:

1. Which select values still pass?
2. Which select values fail?
3. Why does using `sel[0]` twice lose information?

Fix the line back to `.sel(sel[1])` when finished.

## 10. GTKWave Practice

Open:

```bash
gtkwave ./sim/muxes.vcd
```

Add these signals:

1. `mux2_a`, `mux2_b`, `mux2_sel`, `mux2_y`
2. `mux4_d0`, `mux4_d1`, `mux4_d2`, `mux4_d3`, `mux4_sel`
3. `mux4_y_direct`, `mux4_y_from_mux2`
4. `dut_mux4_from_mux2.low_pair_y`
5. `dut_mux4_from_mux2.high_pair_y`
6. `bus_a`, `bus_b`, `bus_sel`, `bus_y`
7. `block_a`, `block_b`, `choose_logic`, `block_y`

Things to observe:

1. `mux2_y` follows `mux2_a` when `mux2_sel=0`.
2. `mux2_y` follows `mux2_b` when `mux2_sel=1`.
3. `mux4_y_direct` and `mux4_y_from_mux2` should always match.
4. In the built mux4, `sel[0]` chooses inside pairs and `sel[1]` chooses between pairs.
5. In the combinational block, `choose_logic=0` selects `a + b`; `choose_logic=1` selects `a ^ b`.

## 11. Common Bugs

### Wrong Select Width

Bug:

```verilog
input sel
```

in a 4-to-1 mux.

Problem: one bit can only represent `0` and `1`, so it cannot choose all four inputs.

Fix:

```verilog
input [1:0] sel
```

### Missing Case

Bug:

```verilog
case (sel)
    2'b00: y = d0;
    2'b01: y = d1;
    2'b10: y = d2;
endcase
```

Problem: `sel=11` does not assign `y`.

Fix: include every select value, and usually include a `default`.

### Wrong Port Connection

Bug:

```verilog
.d2(d3),
.d3(d2),
```

Problem: `sel=10` and `sel=11` choose swapped data inputs.

Fix: connect ports by name carefully and test every select value.

## Day 5 Summary

A mux is a selector. A 2-to-1 mux chooses between two inputs using one select bit. A 4-to-1 mux chooses between four inputs using two select bits. A large mux can be built from smaller muxes by selecting in stages. The self-checking testbench is valuable because mux bugs often look small in code but show up clearly when every input and select combination is tested.
