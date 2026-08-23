# Week 2 Day 2: Scoreboard Timing and Register File Verification

Date: 2026-08-07

## Goal

Upgrade the existing register file testbench from basic directed checking into a
more disciplined scoreboard-style verification exercise.

By the end of the day, the learner should be able to explain:

- Why a golden model is independent from the RTL.
- Why the scoreboard must update at the same logical time as the hardware state.
- Why checking at `posedge clk` can race the RTL.
- How reset recovery differs from the first reset test.
- How same-address read/write timing appears in the waveform.
- How to debug a failing checker, not only a failing RTL implementation.

## Starting Point

Day 1 already built the 4x4 register file and a basic self-checking testbench.
Do not repeat that work.

The current testbench already has:

```text
expected_regs[0:3]
check_read_a
check_read_b
check_read_pair
apply_reset
write_register
disabled_write
directed writes to r0/r1/r2/r3
overwrite
exhaustive 16 read-address pairs
```

Day 2 should keep that foundation and make the timing checks sharper.

## Intuition First: The Scoreboard Is Also Timed Logic

The RTL register file changes storage here:

```text
posedge clk
```

The scoreboard should update its expected state only after the testbench has
observed that same logical write event.

Bad mental model:

```text
I drove write_addr and write_data, so expected_regs should change immediately.
```

Correct mental model:

```text
I drove write_addr and write_data before the clock edge.
The write becomes real at the clock edge.
The checker compares shortly after the edge.
```

This matters because a verification bug can look like a hardware bug. A strong
testbench must model both values and timing.

## Prediction 1: Scoreboard Timing

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

## Prediction 2: Checker Bug

Suppose the testbench accidentally updates the scoreboard too early:

```verilog
expected_regs[addr] = data;
@(posedge clk);
#1;
check_read_pair("write completed");
```

Predict:

```text
Could this hide a bug, create a false failure, or both?
Which value does the checker expect before the hardware has actually written?
```

## Relevant Files

Read these before editing:

```text
rtl/register_file4x4.v
tb/tb_register_file4x4.v
docs/week2_day1_register_file.md
```

## Hands-On Plan

Edit:

```text
tb/tb_register_file4x4.v
```

Usually keep:

```text
rtl/register_file4x4.v
```

Day 2 is mainly a verification day. Only touch RTL if the intentional exercise
temporarily requires it, and restore the correct RTL before completion.

## Required Testbench Features

The testbench must:

- Compile with Icarus Verilog using `-Wall`.
- Generate `sim/register_file4x4.vcd`.
- Maintain an independent `expected_regs[0:3]` golden model.
- Use self-checking tasks that print the first failing mismatch clearly.
- Check shortly after clock edges, not exactly at `posedge clk`.
- Separate "drive inputs", "wait for hardware event", "update scoreboard", and
  "check outputs" in the task structure.

## Required Test Cases

Confirm existing coverage for:

- Reset clears all four registers.
- Distinct writes to all four registers.
- Exhaustive read of all 16 `read_addr_a` and `read_addr_b` address pairs.
- Disabled write does not change storage.
- Overwrite changes only the selected register.

Add or strengthen coverage for:

- Reset recovery clears old values and allows new writes afterward.
- Same-address read/write timing.
- A before-edge same-address read check that still expects the old value.
- An after-edge same-address read check that expects the new value.

## Intentional Bug Exercise: Checker Timing

Introduce exactly one temporary testbench bug for debugging practice.

Suggested bug: update the scoreboard before the clock edge in `write_register`
or in a new same-address write task:

```verilog
expected_regs[addr] = data;
@(posedge clk);
#1;
```

Then add a before-edge read check for the same address.

Expected learning:

- The DUT can be correct while the testbench is wrong.
- The first FAIL should point to an expected value that changed too early.
- GTKWave should show the internal register still holding the old value before
  the rising edge.
- The fix is to update the scoreboard after the clocked write event, then check
  after a small delay.

Correct task ordering:

```verilog
@(negedge clk);
write_enable = 1'b1;
write_addr = addr;
write_data = data;
@(posedge clk);
#1;
expected_regs[addr] = data;
check_read_pair("write completed");
```

## Same-Address Read/Write Timing

Add a dedicated directed timing check:

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

Useful testbench shape:

```verilog
task check_same_address_write_timing;
    begin
        // 1. Put a known old value in r2.
        // 2. Select r2 on read port A.
        // 3. Drive a new write to r2 before the edge.
        // 4. Check old value before the edge.
        // 5. Wait for posedge and #1.
        // 6. Update scoreboard and check new value.
    end
endtask
```

## Reset Recovery

Reset recovery is not the same as the first reset test.

The first reset test asks:

```text
Does reset clear the power-up or initial state?
```

Reset recovery asks:

```text
After meaningful values have been written, can reset clear them and can the
design work normally again afterward?
```

Required sequence:

```text
1. Write nonzero values into all registers.
2. Assert reset and check all reads return 0000.
3. Deassert reset.
4. Write new values.
5. Check all read-address pairs again.
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
The scoreboard should update when ____.
The RTL registers update when ____.
The read ports update when ____.
The intentional bug failed because ____.
For same-address read/write, before the edge I saw ____ and after the edge I saw ____.
```

## Completion Criteria

- The learner predicts same-address read/write behavior before simulation.
- The learner predicts what the early-scoreboard bug will do.
- The testbench includes reset recovery and explicit same-address timing checks.
- One intentional checker timing bug is observed through the first FAIL.
- The bug is fixed after waveform inspection.
- The focused register file test prints PASS.
- The Week 1 and Week 2 regression is rerun.
- `docs/PROGRESS.md` records verified progress, known issues, and exactly one
  Exact Next Action.

## Result

- Added `check_all_read_pairs` to reuse the exhaustive 16 read-address pair
  coverage.
- Added `check_same_address_write_timing` to check old data before the write
  edge and new data after the write edge plus a small delay.
- Added `check_reset_recovery` to write nonzero values, reset the register file,
  confirm all reads return zero, then write and read new values afterward.
- Intentional checker bug: `expected_regs[2]` was temporarily updated before
  the write clock edge, causing the first failure to report
  `expected=1111 actual=1010` before the hardware had written the new value.
- Fix: moved the scoreboard update to after `@(posedge clk); #1;`, matching the
  hardware write timing and stable read-check point.
- Observed timing: for same-address read/write, the read port showed the old
  value `1010` before the rising edge and the new value `1111` shortly after the
  rising edge.
- Verified result: focused `tb_register_file4x4.v` test PASS with 116 checks.
- Regression result: Week 1 tests, decoder, and register file all reran
  successfully.
