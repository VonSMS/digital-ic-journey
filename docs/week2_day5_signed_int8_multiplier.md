# Week 2 Day 5: Signed INT8 Multiplier

## Today's Goal

Build a combinational signed INT8 multiplier:

```text
signed 8-bit a * signed 8-bit b -> signed 16-bit product
```

This is the first datapath block for the INT8 matrix path. Later days will
place this multiplier inside a MAC, then inside a processing element, then
inside a 2x2 matrix multiply unit.

## Intuition First

An unsigned byte answers: "how large is this 8-bit pattern from 0 to 255?"

A signed two's-complement byte answers: "is this pattern a value from -128 to
127?"

The bits are identical, but the interpretation is different. For example:

```text
8'b1111_1111 = 255 unsigned
8'b1111_1111 = -1 signed
```

That difference matters before multiplication starts. If hardware sees `-1` as
`255`, then `-1 * 7` becomes `255 * 7`, and the low 16 product bits no longer
represent the signed answer.

The output needs 16 bits because the largest magnitude product is a full 8x8
result. Boundary examples:

```text
127 * 127     =  16129
-128 * 127    = -16256
-128 * -128   =  16384
```

## Prediction Prompts

Before simulation, predict these decimal and hex results:

1. `7 * 3`
2. `-7 * 3`
3. `12 * -5`
4. `-1 * 127`
5. `-128 * 1`
6. `-128 * -1`
7. `-128 * -128`

Then predict the first kind of failure if the RTL accidentally treats `a` and
`b` as unsigned.

## Hands-On Tasks

In `rtl/int8_multiplier.v`, inspect or complete:

- Declare `a` and `b` as `input signed [7:0]`.
- Declare `product` as `output signed [15:0]`.
- Assign `product = a * b`.

In `tb/tb_int8_multiplier.v`, inspect or complete:

- A self-checking `check_product` task.
- Directed tests for zero, positive, sign-mixed, negative times negative,
  `127`, `-128`, and `-1`.
- A sampled sweep to catch more sign combinations.
- An exhaustive sweep over all 65536 signed INT8 input pairs.

## Debug Exercise

Compile once with the intentional signedness bug enabled:

```sh
mkdir -p sim
iverilog -Wall -DINTENTIONAL_INT8_SIGN_BUG -o sim/tb_int8_multiplier_bug.vvp rtl/int8_multiplier.v tb/tb_int8_multiplier.v
vvp sim/tb_int8_multiplier_bug.vvp
```

Read the first `FAIL` line before changing the RTL. Ask:

- Which operand was supposed to be negative?
- Did the product look like an unsigned interpretation?
- Is the product path wrong, or is the operand declaration/extension wrong?

Then open the waveform:

```sh
gtkwave sim/int8_multiplier.vcd
```

Inspect the first failing case and compare `a`, `b`, `product`, and `expected`.

## Normal Test Commands

Focused test:

```sh
mkdir -p sim
iverilog -Wall -o sim/tb_int8_multiplier.vvp rtl/int8_multiplier.v tb/tb_int8_multiplier.v
vvp sim/tb_int8_multiplier.vvp
```

Relevant regression:

```sh
iverilog -Wall -o sim/tb_simple_logic.vvp rtl/simple_logic.v tb/tb_simple_logic.v
vvp sim/tb_simple_logic.vvp
iverilog -Wall -o sim/tb_adders.vvp rtl/half_adder.v rtl/full_adder.v tb/tb_adders.v
vvp sim/tb_adders.vvp
iverilog -Wall -o sim/tb_muxes.vvp rtl/mux2.v rtl/mux4.v tb/tb_muxes.v
vvp sim/tb_muxes.vvp
iverilog -Wall -o sim/tb_sequential.vvp rtl/dff.v rtl/register4.v rtl/counter4.v tb/tb_sequential.v
vvp sim/tb_sequential.vvp
iverilog -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4.vvp
iverilog -Wall -o sim/tb_decoder2to4.vvp rtl/decoder2to4.v tb/tb_decoder2to4.v
vvp sim/tb_decoder2to4.vvp
iverilog -Wall -o sim/tb_register_file4x4.vvp rtl/register_file4x4.v tb/tb_register_file4x4.v
vvp sim/tb_register_file4x4.vvp
iverilog -Wall -o sim/tb_controller_fsm.vvp rtl/controller_fsm.v rtl/result_register4.v tb/tb_controller_fsm.v
vvp sim/tb_controller_fsm.vvp
iverilog -Wall -o sim/tb_tiny_execution_unit.vvp rtl/register_file4x4.v rtl/alu4.v rtl/controller_fsm.v rtl/result_register4.v rtl/tiny_execution_unit.v tb/tb_tiny_execution_unit.v
vvp sim/tb_tiny_execution_unit.vvp
iverilog -Wall -o sim/tb_int8_multiplier.vvp rtl/int8_multiplier.v tb/tb_int8_multiplier.v
vvp sim/tb_int8_multiplier.vvp
```

## Waveform Inspection Checklist

Open `sim/int8_multiplier.vcd` and inspect:

- `a` as signed decimal and binary.
- `b` as signed decimal and binary.
- `product` as signed decimal and hex.
- A positive times positive case.
- A negative times positive case.
- A positive times negative case.
- A negative times negative case.
- `-128 * -128`, confirming `16'sd16384`.
- The first intentional-bug failure, confirming that the same bits were treated
  with the wrong signedness.

## Explain-Back Prompt

In your own words, explain this signal flow:

```text
8-bit signed operand bits -> signed interpretation -> multiplier -> 16-bit signed product
```

Also explain why declaring only the output as signed is not enough if the input
operands are treated as unsigned.

## Completion Criteria

- `rtl/int8_multiplier.v` is implemented with signed inputs and a signed
  16-bit product.
- `tb/tb_int8_multiplier.v` is self-checking.
- Tests cover normal, zero, sign-mixed, `127`, `-128`, and `-1` boundary cases.
- Exhaustive signed INT8 input pairs pass.
- The intentional signedness bug produces a meaningful first failure.
- The fixed focused test passes.
- Full regression passes.
- `docs/PROGRESS.md` records verified progress, known issues, and exactly one
  Exact Next Action.
