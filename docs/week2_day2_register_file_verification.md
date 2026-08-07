# Week 2 Day 2: Register File Verification Depth

Date: 2026-08-07

## Goal

Deepen the verification for the 4x4 register file.

By the end of the day, the learner should be able to explain:

- Why a golden model is independent from the RTL.
- Why a scoreboard records expected state across time.
- The difference between directed tests and exhaustive tests.
- Why clocked tests should check shortly after the clock edge.
- How a same-address read/write behaves in this register file.
- How to use the first failing self-check and GTKWave together.

## Intuition First

A register file is a small addressed storage bank:

```text
write port: write_enable + write_addr + write_data + clk
read port A: read_addr_a -> read_data_a
read port B: read_addr_b -> read_data_b
```

The RTL stores real state in `r0`, `r1`, `r2`, and `r3`.

The testbench should not trust that state. It keeps a separate expected copy:

```verilog
reg [3:0] expected_regs [0:3];
```

That expected array is the golden model. When the testbench applies a legal
write, it updates `expected_regs`. When it reads, it compares DUT output
against the expected array.

This is the central verification habit:

```text
DUT behavior is one story.
Expected model is another story.
The checker compares the two stories.
```

## Prediction Before Simulation

Assume the register file already contains:

```text
r0 = 0001
r1 = 0011
r2 = 1010
r3 = 1100
```

Before a rising clock edge:

```text
write_enable = 1
write_addr   = 2
write_data   = 1111
read_addr_a  = 2
read_addr_b  = 3
```

Predict:

```text
Before the posedge: read_data_a = ____, read_data_b = ____
Shortly after the posedge: read_data_a = ____, read_data_b = ____
```

Reason from timing:

- Writes are synchronous, so storage changes at the clock edge.
- Reads are combinational, so read data follows the selected stored register.
- If a read address points at the register being written, the visible read data
  changes after the stored register updates.

## Relevant Files

Read these before editing:

```text
rtl/register_file4x4.v
tb/tb_register_file4x4.v
docs/week2_day1_register_file.md
```

## Hands-On Plan

Strengthen:

```text
tb/tb_register_file4x4.v
```

Keep:

```text
rtl/register_file4x4.v
```

The point of Day 2 is stronger verification, not a new RTL design.

## Required Testbench Features

The testbench must:

- Compile with Icarus Verilog using `-Wall`.
- Generate `sim/register_file4x4.vcd`.
- Maintain an independent `expected_regs[0:3]` golden model.
- Use self-checking tasks that print the first failing mismatch clearly.
- Check shortly after clock edges, not exactly at `posedge clk`.

## Required Test Cases

Add or confirm coverage for:

- Reset clears all four registers.
- Distinct writes to all four registers.
- Exhaustive read of all 16 `read_addr_a` and `read_addr_b` address pairs.
- Disabled write does not change storage.
- Overwrite changes only the selected register.
- Reset recovery clears old values and allows new writes afterward.
- Same-address read/write timing.

## Intentional Bug Exercise

Introduce exactly one temporary RTL bug for debugging practice.

Suggested bug:

```verilog
2'b10: r3 <= write_data;
2'b11: r2 <= write_data;
```

This swaps the write destinations for `write_addr=2` and `write_addr=3`.

Expected learning:

- The first FAIL should show a register holding the old value.
- GTKWave should show that the write data went into the wrong internal register.
- The read mux may still be correct; the bug is in the write decode.

After the learner inspects the first failure and waveform, restore the correct
RTL:

```verilog
2'b10: r2 <= write_data;
2'b11: r3 <= write_data;
```

## Same-Address Read/Write Timing

Use a directed timing check like this:

```text
Start with r2 = 1010
Set read_addr_a = 2
Set write_enable = 1, write_addr = 2, write_data = 1111
Before posedge: read_data_a should be 1010
After posedge + small delay: read_data_a should be 1111
```

Document the observed behavior:

```text
The read port is combinational, so when the selected register changes at the
clock edge, the read data follows shortly after the edge.
```

## Commands

Run the focused test:

```powershell
if (!(Test-Path sim)) { New-Item -ItemType Directory sim }
iverilog -g2012 -Wall -o sim\tb_register_file4x4.vvp rtl\register_file4x4.v tb\tb_register_file4x4.v
vvp sim\tb_register_file4x4.vvp
```

Open the waveform:

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

Run the regression after the focused test passes:

```powershell
iverilog -g2012 -Wall -o sim\tb_simple_logic.vvp rtl\simple_logic.v tb\tb_simple_logic.v
vvp sim\tb_simple_logic.vvp

iverilog -g2012 -Wall -o sim\tb_adders.vvp rtl\half_adder.v rtl\full_adder.v tb\tb_adders.v
vvp sim\tb_adders.vvp

iverilog -g2012 -Wall -o sim\tb_muxes.vvp rtl\mux2.v rtl\mux4.v tb\tb_muxes.v
vvp sim\tb_muxes.vvp

iverilog -g2012 -Wall -o sim\tb_sequential.vvp rtl\dff.v rtl\register4.v rtl\counter4.v tb\tb_sequential.v
vvp sim\tb_sequential.vvp

iverilog -g2012 -Wall -o sim\tb_alu4.vvp rtl\alu4.v tb\tb_alu4.v
vvp sim\tb_alu4.vvp

iverilog -g2012 -Wall -o sim\tb_decoder2to4.vvp rtl\decoder2to4.v tb\tb_decoder2to4.v
vvp sim\tb_decoder2to4.vvp

iverilog -g2012 -Wall -o sim\tb_register_file4x4.vvp rtl\register_file4x4.v tb\tb_register_file4x4.v
vvp sim\tb_register_file4x4.vvp
```

## Explain-Back Prompt

After simulation and waveform inspection, explain in your own words:

```text
The scoreboard changes when ____.
The RTL registers change when ____.
The read ports update when ____.
For same-address read/write, before the edge I saw ____ and after the edge I saw ____.
```

## Completion Criteria

- The learner predicts same-address read/write behavior before simulation.
- The testbench includes the required verification cases.
- One intentional RTL bug is observed through the first FAIL.
- The bug is fixed after waveform inspection.
- The focused register file test prints PASS.
- The Week 1 and Week 2 regression is rerun.
- `docs/PROGRESS.md` records verified progress, known issues, and exactly one
  Exact Next Action.
