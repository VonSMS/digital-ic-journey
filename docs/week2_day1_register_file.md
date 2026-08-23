# Week 2 Day 1: Register File Foundations

Date: 2026-08-03

## Goal

Build a 4x4 register file and understand why it is different from a single
register.

By the end of the day, the learner should be able to explain:

- Why a register file is an addressed storage bank.
- Why writes are synchronous.
- Why reads can be combinational.
- How two read ports can read two registers at the same time.
- How a self-checking testbench keeps an independent expected state.
- How to use the first failure and GTKWave to debug a wrong address decode.

## Review: Single Register from Week 1

In Week 1, a 4-bit register stored one value:

```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 4'b0000;
    else if (enable)
        q <= d;
end
```

The important idea was timing:

- `d` is the next value.
- `q` is the stored current value.
- The value updates at a clock edge.
- `<=` models clocked state updating after the edge.

That was one storage box.

## New Idea: Register File

A register file is several registers plus address logic.

For a 4x4 register file:

```text
4 registers: r0, r1, r2, r3
4 bits each: 0000 to 1111
```

The write side chooses which register to update:

```text
write_enable + write_addr + write_data + clk
```

The read side chooses which register value to show:

```text
read_addr_a -> read_data_a
read_addr_b -> read_data_b
```

This is not just repeating a register four times. The new learning is address
selection, read/write timing, and multi-port behavior.

## Architecture Intuition

A CPU or accelerator often needs two operands before an ALU operation:

```text
register file read port A -> ALU input A
register file read port B -> ALU input B
ALU result -> register file write data
```

That is why two read ports are useful. For example, an instruction like:

```text
r3 = r1 + r2
```

needs to read `r1` and `r2` in the same cycle, then later write the result into
`r3`.

## Timing Model

This design uses:

- Asynchronous reset: reset clears the registers immediately.
- Synchronous write: storage changes only at `posedge clk`.
- Combinational read: read data follows the selected register value immediately. No need to wait for posedge.

Prediction examples:

```text
reset=1                         -> r0=r1=r2=r3=0000
write_enable=0 at posedge       -> no register changes
write_enable=1, write_addr=2    -> r2 stores write_data at posedge
read_addr_a=1                   -> read_data_a shows r1
read_addr_b=3                   -> read_data_b shows r3
```

## Today's RTL

Create:

```text
rtl/register_file4x4.v
```

Interface:

```verilog
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
```

Internal storage:

```verilog
reg [3:0] r0;
reg [3:0] r1;
reg [3:0] r2;
reg [3:0] r3;
```

## Today's Testbench

Create:

```text
tb/tb_register_file4x4.v
```

The testbench should maintain an independent expected state:

```verilog
reg [3:0] expected_regs [0:3];
```

The expected state is a simple golden model. It lets the testbench compare:

```text
DUT actual read data vs expected register value
```

This is the key habit: do not only look at waveforms. Let the testbench tell
you where behavior first diverges.

## Required Tests

Day 1 should cover:

- Reset clears all registers.
- Disabled write does not change storage.
- Write to `r0`.
- Write to `r1`.
- Write to `r2`.
- Write to `r3`.
- Overwrite an existing register.
- Read two different registers at the same time.
- Read the same register from both read ports.
- Exhaustive read-address pairs after directed writes.

## Intentional Bug

The first version includes one intentional write-address decode bug.

Expected mapping:

```text
write_addr=00 -> r0
write_addr=01 -> r1
write_addr=10 -> r2
write_addr=11 -> r3
```

The bug swaps two of these write destinations. The read muxes are written
correctly, so the first failure should reveal that data was stored in the wrong
register.

## First Failure Practice

Compile and run:

```powershell
iverilog -g2012 -Wall -o sim\tb_register_file4x4.vvp rtl\register_file4x4.v tb\tb_register_file4x4.v
vvp sim\tb_register_file4x4.vvp
```

Expected first failure before the fix:

```text
FAIL test 7 write r1 then read r1 and r0
read_addr_a=1 expected=0011 actual=0000
```

Debug questions:

1. Which register did the testbench expect to change?
2. Which register actually changed in the RTL?
3. Is the bug in the write decode or the read mux?
4. Which two write-address cases are swapped?

## GTKWave Signals

Open:

```powershell
gtkwave sim\register_file4x4.vcd
```

Inspect:

```text
clk
reset
write_enable
write_addr
write_data
read_addr_a
read_data_a
read_addr_b
read_data_b
dut.r0
dut.r1
dut.r2
dut.r3
```

Zoom around the first failing write. Check what happened at the rising clock
edge after `write_addr=01` and `write_data=0011`.

## Explain-Back Prompt

After debugging, explain in your own words:

```text
The write port changes storage only at the clock edge.
The read ports select stored values combinationally.
The bug happened because write_addr=__ wrote into r__ instead of r__.
```

## Day 1 Completion Criteria

- `rtl/register_file4x4.v` is implemented.
- `tb/tb_register_file4x4.v` is self-checking.
- The intentional bug is diagnosed from the first failure.
- The fixed testbench prints `PASS: all register_file4x4 tests passed`.
- `sim/register_file4x4.vcd` is generated.
- `docs/PROGRESS.md` is updated with exactly one next action.

## Result

- Diagnosed bug: `write_addr=01` wrote to `r2`, and `write_addr=10` wrote to
  `r1`.
- Fix: swapped those two write decode destinations back to `r1` and `r2`.
- Verified result: `tb_register_file4x4.v` PASS.
- Regression result: Week 1 tests, decoder, and register file all reran
  successfully.
