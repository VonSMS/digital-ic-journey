# Week 2 Day 3: Controller FSM and Result Register

Date: 2026-08-08

## Goal

Build a tiny control path that can start one operation, mark one execute cycle,
capture a result, and raise `done` for exactly one cycle.

Today's files:

```text
rtl/controller_fsm.v
rtl/result_register4.v
tb/tb_controller_fsm.v
```

## Intuition First

The datapath answers:

```text
What value is being computed?
```

The controller answers:

```text
When should each action happen?
```

For today, the controller is a three-state FSM:

```text
IDLE -> EXECUTE -> DONE -> IDLE
```

- `IDLE`: wait for a new `start` pulse.
- `EXECUTE`: one active work cycle; `busy=1` and `capture_result=1`.
- `DONE`: one completion cycle; `done=1`.

The result register is controlled storage:

```text
if capture_enable is 1 at a rising clock edge, store result_in
otherwise hold the old result
```

## Prediction 1: One-Cycle Start

Before simulation, predict this timing:

```text
At negedge: start becomes 1 and result_in = A.
Next posedge + #1: state = ____, busy = ____, done = ____, capture_result = ____.
Next posedge + #1: state = ____, busy = ____, done = ____, result_out = ____.
Next posedge + #1: state = ____, busy = ____, done = ____.
```

Key idea: the result register sees `capture_result=1` during `EXECUTE`, then
captures `result_in` on the clock edge that moves the FSM into `DONE`.

## Prediction 2: Held Start

If `start` stays high for several cycles, should the FSM launch a new operation
every time it returns to `IDLE`?

Today's controller uses a `start` edge detector:

```text
start_pulse = start & ~start_d
```

That means a held `start` creates only one launch. To launch again, `start` must
go low and then high again.

## Prediction 3: Start While Busy

If `start` is high while the FSM is already in `EXECUTE` or `DONE`, predict:

```text
Does it interrupt the current operation?
Does it extend done?
Does it create an immediate second transaction?
```

The intended answer is no to all three.

## Hands-On RTL Tasks

Write or review these meaningful sections before reading the full solution:

1. In `rtl/controller_fsm.v`, write the state encodings:

```verilog
localparam STATE_IDLE    = 2'b00;
localparam STATE_EXECUTE = 2'b01;
localparam STATE_DONE    = 2'b10;
```

2. Write the next-state logic:

```text
IDLE:    if start_pulse, go to EXECUTE
EXECUTE: always go to DONE
DONE:    always go to IDLE
default: recover to IDLE
```

3. Write the output defaults first:

```verilog
busy = 1'b0;
done = 1'b0;
capture_result = 1'b0;
```

Then override them in the active states.

4. In `rtl/result_register4.v`, write the clocked block:

```text
reset clears result_out
capture_enable stores result_in
otherwise hold the old value
```

## Required Self-Checking Tests

The testbench must check:

- Reset clears the FSM and result register.
- A one-cycle `start` produces `IDLE -> EXECUTE -> DONE -> IDLE`.
- `done` is high for exactly one cycle.
- `capture_result` is high only in `EXECUTE`.
- `result_out` changes only when capture is enabled.
- Held `start` does not retrigger until `start` is released.
- `start` while busy does not interrupt or create an extra transaction.

## Intentional Debug Exercise

Run the intentionally broken checker:

```powershell
if (!(Test-Path sim)) { New-Item -ItemType Directory sim }
iverilog -g2012 -Wall -DINTENTIONAL_CHECKER_BUG -o sim\tb_controller_fsm_bug.vvp rtl\controller_fsm.v rtl\result_register4.v tb\tb_controller_fsm.v
vvp sim\tb_controller_fsm_bug.vvp
```

Expected first failure:

```text
intentional checker bug expects done too early
```

This is a checker bug, not an RTL bug. The wrong checker expects the FSM to
remain in `EXECUTE` one cycle too long. Inspect the waveform and confirm that
the actual state flow is:

```text
IDLE -> EXECUTE -> DONE -> IDLE
```

Fix by compiling without `-DINTENTIONAL_CHECKER_BUG`.

## Focused Test Command

```powershell
if (!(Test-Path sim)) { New-Item -ItemType Directory sim }
iverilog -g2012 -Wall -o sim\tb_controller_fsm.vvp rtl\controller_fsm.v rtl\result_register4.v tb\tb_controller_fsm.v
vvp sim\tb_controller_fsm.vvp
```

## GTKWave Checklist

Open:

```powershell
gtkwave sim\controller_fsm.vcd
```

Inspect:

```text
clk
reset
start
controller.start_d
controller.start_pulse
state_debug
busy
done
capture_result
result_in
result_out
```

Look for:

```text
IDLE -> EXECUTE -> DONE -> IDLE
capture_result high only in EXECUTE
result_out capturing on the edge into DONE
done high for one cycle
held start not creating repeated work
```

## Regression Command

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

iverilog -g2012 -Wall -o sim\tb_controller_fsm.vvp rtl\controller_fsm.v rtl\result_register4.v tb\tb_controller_fsm.v
vvp sim\tb_controller_fsm.vvp
```

## Explain-Back Prompt

Explain in your own words:

```text
The controller state changes when ____.
The next-state logic decides ____.
The output logic asserts busy when ____.
The output logic asserts done when ____.
The result register captures when ____.
Held start does not retrigger because ____.
The intentional checker bug failed because ____.
```

## Completion Criteria

- The learner predicts one-cycle start behavior before simulation.
- The learner predicts held-start behavior before simulation.
- The focused self-checking test passes.
- The intentional checker bug produces a clear first failure.
- The waveform shows `IDLE -> EXECUTE -> DONE -> IDLE`.
- The regression reruns successfully.
- `docs/PROGRESS.md` records verified progress and one exact next action.

## Result

- Implemented `rtl/controller_fsm.v` with a three-state
  `IDLE -> EXECUTE -> DONE -> IDLE` FSM.
- Added `start` edge detection so a held `start` launches only one transaction
  until `start` is released and asserted again.
- Implemented `rtl/result_register4.v` with reset and `capture_enable`.
- Implemented `tb/tb_controller_fsm.v` as a self-checking testbench with reset,
  one-cycle start, held start, start while busy, one-cycle `done`, disabled
  capture, and result capture checks.
- Intentional checker bug: compiling with `-DINTENTIONAL_CHECKER_BUG` made the
  checker expect the FSM to stay in `EXECUTE` too long. The first failure showed
  actual `state=10`, `done=1`, and `result_out=0010`, proving the RTL had
  correctly reached `DONE` and the checker expectation was wrong.
- Fix: compile without `-DINTENTIONAL_CHECKER_BUG`.
- Focused result: `tb_controller_fsm.v` PASS with 21 checks.
- Regression result: `tb_simple_logic.v`, `tb_adders.v`, `tb_muxes.v`,
  `tb_sequential.v`, `tb_alu4.v`, `tb_decoder2to4.v`,
  `tb_register_file4x4.v`, and `tb_controller_fsm.v` all reran successfully.
- Known warning: some older modules still warn about missing explicit time
  units.
