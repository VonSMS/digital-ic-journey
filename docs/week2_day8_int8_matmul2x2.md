# Week 2 Day 8: INT8 2x2 Matrix Multiply Integration

## Goal

Build the first signed INT8 2x2 matrix multiply hardware block using four
processing elements in parallel.

Target equation:

```text
C = A x B

C00 = A00*B00 + A01*B10
C01 = A00*B01 + A01*B11
C10 = A10*B00 + A11*B10
C11 = A10*B01 + A11*B11
```

## Intuition First

Each output is one row of `A` dotted with one column of `B`.

The hardware choice for today is simple and visible:

- Use four PEs in parallel.
- Clear all four PEs before a new matrix multiply.
- First MAC cycle computes the `k=0` products.
- Second MAC cycle computes the `k=1` products.
- Raise `done` only after the second product has reached each accumulator.

This is not optimized yet. It is a readable first matrix engine.

## Prediction Prompts

Before running simulation, predict these:

1. Which `A` row and `B` column feed `C00`?
2. What should an identity matrix do when multiplied by another matrix?
3. Why should `done` wait until after the second MAC edge?
4. What should happen to all four outputs when matrix `A` is all zero?

## Hands-On RTL Tasks

Open `rtl/matmul2x2_int8.v`.

Review or complete:

1. The four PE instances: `pe00`, `pe01`, `pe10`, and `pe11`.
2. The operand muxing for `STATE_MAC0` and `STATE_MAC1`.
3. The state flow:

```text
IDLE -> CLEAR -> MAC0 -> MAC1 -> DONE -> IDLE
```

4. The `done` signal, which must represent valid final outputs.

## Hands-On Testbench Tasks

Open `tb/tb_matmul2x2_int8.v`.

The self-checking testbench computes the golden result using the four equations
above, then waits for `done` and compares all outputs.

Required cases:

- zero matrix
- identity matrix
- positive matrix
- mixed signs
- boundary values

Add one extra matrix case of your own after you can explain the existing five.

## Debug Exercise

The most likely integration bug is an off-by-one control bug:

```text
done rises while only the first MAC product has been accumulated
```

Debug path:

1. Read the first failing output.
2. Compare that output to only the first product.
3. Inspect whether `done` is high before the second product reaches `acc`.
4. Move `done` to a state after `MAC1` if needed.

## Commands

Focused PE test:

```sh
mkdir -p sim
iverilog -Wall -o sim/tb_int8_processing_element.vvp rtl/int8_processing_element.v tb/tb_int8_processing_element.v
vvp sim/tb_int8_processing_element.vvp
```

Focused 2x2 matrix multiply test:

```sh
iverilog -Wall -o sim/tb_matmul2x2_int8.vvp rtl/int8_processing_element.v rtl/matmul2x2_int8.v tb/tb_matmul2x2_int8.v
vvp sim/tb_matmul2x2_int8.vvp
```

Full regression:

```sh
iverilog -Wall -o sim/tb_simple_logic.vvp rtl/simple_logic.v tb/tb_simple_logic.v && vvp sim/tb_simple_logic.vvp
iverilog -Wall -o sim/tb_adders.vvp rtl/half_adder.v rtl/full_adder.v tb/tb_adders.v && vvp sim/tb_adders.vvp
iverilog -Wall -o sim/tb_muxes.vvp rtl/mux2.v rtl/mux4.v tb/tb_muxes.v && vvp sim/tb_muxes.vvp
iverilog -Wall -o sim/tb_sequential.vvp rtl/dff.v rtl/register4.v rtl/counter4.v tb/tb_sequential.v && vvp sim/tb_sequential.vvp
iverilog -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v && vvp sim/tb_alu4.vvp
iverilog -Wall -o sim/tb_decoder2to4.vvp rtl/decoder2to4.v tb/tb_decoder2to4.v && vvp sim/tb_decoder2to4.vvp
iverilog -Wall -o sim/tb_register_file4x4.vvp rtl/decoder2to4.v rtl/register_file4x4.v tb/tb_register_file4x4.v && vvp sim/tb_register_file4x4.vvp
iverilog -Wall -o sim/tb_controller_fsm.vvp rtl/controller_fsm.v rtl/result_register4.v tb/tb_controller_fsm.v && vvp sim/tb_controller_fsm.vvp
iverilog -Wall -o sim/tb_tiny_execution_unit.vvp rtl/decoder2to4.v rtl/register_file4x4.v rtl/alu4.v rtl/controller_fsm.v rtl/result_register4.v rtl/tiny_execution_unit.v tb/tb_tiny_execution_unit.v && vvp sim/tb_tiny_execution_unit.vvp
iverilog -Wall -o sim/tb_int8_multiplier.vvp rtl/int8_multiplier.v tb/tb_int8_multiplier.v && vvp sim/tb_int8_multiplier.vvp
iverilog -Wall -o sim/tb_int8_mac.vvp rtl/int8_mac.v tb/tb_int8_mac.v && vvp sim/tb_int8_mac.vvp
iverilog -Wall -o sim/tb_int8_processing_element.vvp rtl/int8_processing_element.v tb/tb_int8_processing_element.v && vvp sim/tb_int8_processing_element.vvp
iverilog -Wall -o sim/tb_matmul2x2_int8.vvp rtl/int8_processing_element.v rtl/matmul2x2_int8.v tb/tb_matmul2x2_int8.v && vvp sim/tb_matmul2x2_int8.vvp
```

## Waveform Inspection Checklist

Open:

```sh
gtkwave sim/matmul2x2_int8.vcd
```

Inspect:

- `clk`
- `reset`
- `start`
- `busy`
- `done`
- `dut.state`
- `c00`
- `c01`
- `c10`
- `c11`
- each PE's `a`, `b`, `product`, and `acc`

Checklist:

- `start` leaves `IDLE`.
- `CLEAR` clears every PE accumulator.
- `MAC0` uses `A[i][0]` and `B[0][j]`.
- `MAC1` uses `A[i][1]` and `B[1][j]`.
- `DONE` rises only when `c00`, `c01`, `c10`, and `c11` are final.

## Explain-Back Prompt

Explain the full signal flow:

```text
matrix inputs -> operand muxes -> four PEs -> four accumulators -> C outputs
```

Then explain the control flow:

```text
start -> clear -> first products -> second products -> done
```

## Completion Criteria

- `rtl/matmul2x2_int8.v` is implemented in Icarus-compatible Verilog.
- `tb/tb_matmul2x2_int8.v` is self-checking.
- Zero, identity, positive, mixed-sign, and boundary matrix tests pass.
- The waveform confirms the two MAC cycles and final `done` timing.
- Full regression passes.
