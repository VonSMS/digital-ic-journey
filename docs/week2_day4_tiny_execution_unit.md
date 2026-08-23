# Week 2 Day 4: Tiny Execution Unit

## Today's Goal

Build a tiny 4-bit execution unit that connects:

- a 4x4 register file
- the 4-bit ALU
- the controller FSM
- the result register

The purpose is to see the split between datapath and control path.

## Intuition First

The datapath is the road that values travel on:

```text
register file read ports -> ALU operands -> ALU result -> result register
```

The control path is the traffic light:

```text
start -> FSM -> capture_result / busy / done
```

The ALU result is combinational, so it changes whenever the selected register
values or opcode change. The result register should not save every temporary
change. It should save only on the clock edge when the controller says
`capture_result=1`.

## Prediction Prompts

Before simulation, predict these:

1. If `r0=7`, `r1=1`, and `opcode=ADD`, what should `alu_result` be during
   EXECUTE?
2. For `F+1`, what are `result`, `zero`, `carry`, `overflow`, and `negative`?
3. If the selected read addresses change while the FSM is IDLE, should
   `result_out` change immediately?
4. Which cycle should update `result_out`: IDLE, EXECUTE, or DONE?
5. If reset is asserted after a completed operation, what values should the
   register file and result register output?

## Hands-On Tasks

Complete or inspect these signal connections in `rtl/tiny_execution_unit.v`:

- Connect `read_addr_a` and `read_addr_b` into the register file.
- Connect `read_data_a` and `read_data_b` into ALU operands `a` and `b`.
- Connect the ALU `result` into the result register input.
- Connect FSM `capture_result` into the result register capture enable.
- Expose `busy`, `done`, `state_debug`, `alu_result`, flags, and `result_out`
  for the testbench and waveform.

## Debug Exercise

Compile once with the intentional bug enabled:

```sh
iverilog -Wall -DINTENTIONAL_TINY_CAPTURE_BUG -o sim/tb_tiny_execution_unit_bug.vvp rtl/register_file4x4.v rtl/alu4.v rtl/controller_fsm.v rtl/result_register4.v rtl/tiny_execution_unit.v tb/tb_tiny_execution_unit.v
vvp sim/tb_tiny_execution_unit_bug.vvp
```

Read the first `FAIL` line before changing anything. Then open the waveform:

```sh
gtkwave sim/tiny_execution_unit.vcd
```

Question: does `alu_result` compute the right value before `result_out`
captures it? If yes, the bug is probably in the capture/control path, not the
ALU datapath.

## Normal Test Commands

Focused test:

```sh
iverilog -Wall -o sim/tb_tiny_execution_unit.vvp rtl/register_file4x4.v rtl/alu4.v rtl/controller_fsm.v rtl/result_register4.v rtl/tiny_execution_unit.v tb/tb_tiny_execution_unit.v
vvp sim/tb_tiny_execution_unit.vvp
```

Relevant regression:

```sh
iverilog -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4.vvp
iverilog -Wall -o sim/tb_register_file4x4.vvp rtl/register_file4x4.v tb/tb_register_file4x4.v
vvp sim/tb_register_file4x4.vvp
iverilog -Wall -o sim/tb_controller_fsm.vvp rtl/controller_fsm.v rtl/result_register4.v tb/tb_controller_fsm.v
vvp sim/tb_controller_fsm.vvp
iverilog -Wall -o sim/tb_tiny_execution_unit.vvp rtl/register_file4x4.v rtl/alu4.v rtl/controller_fsm.v rtl/result_register4.v rtl/tiny_execution_unit.v tb/tb_tiny_execution_unit.v
vvp sim/tb_tiny_execution_unit.vvp
```

## Waveform Inspection Checklist

Open `sim/tiny_execution_unit.vcd` and inspect one transaction:

- `start` rises for one transaction request.
- `state_debug` moves `IDLE -> EXECUTE -> DONE -> IDLE`.
- `busy` is high during EXECUTE.
- `done` is high for one cycle in DONE.
- `read_data_a` and `read_data_b` match the selected register addresses.
- `alu_result` is valid before the capture edge.
- `capture_result` is high only in EXECUTE.
- `result_out` updates shortly after the capture clock edge and then holds.
- `zero`, `carry`, `overflow`, and `negative` match the operation.

## Explain-Back Prompt

In your own words, explain this signal flow:

```text
write registers -> select source registers -> ALU computes -> FSM captures -> result_out holds
```

Also explain why changing the read addresses in IDLE can change `alu_result`
without changing `result_out`.

## Completion Criteria

- `rtl/tiny_execution_unit.v` is implemented.
- `tb/tb_tiny_execution_unit.v` is self-checking.
- Directed tests cover `7+1`, `F+1`, subtraction, XOR, disabled writes, held
  start behavior, and reset.
- The intentional capture/control bug produces a meaningful first failure.
- The fixed focused test passes.
- Relevant regression passes.
- `docs/PROGRESS.md` records verified progress, known issues, and exactly one
  Exact Next Action.
