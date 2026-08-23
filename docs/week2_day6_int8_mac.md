# Week 2 Day 6: Signed INT8 MAC

## Today's Goal

Build a clocked signed INT8 multiply-accumulate block:

```text
signed 8-bit a * signed 8-bit b -> signed 16-bit product
accumulator_next = accumulator + sign_extend(product)
```

The MAC is the bridge between a multiplier and a matrix dot product. A matrix
output such as `C00` is not just one multiply; it is a sum of products.

## Intuition First

A multiplier answers one question:

```text
What is a * b right now?
```

A MAC answers a longer question:

```text
What is the running sum of products I have accepted so far?
```

That means the MAC has two paths:

- A combinational product path: `a`, `b`, and `product` can change immediately.
- A clocked storage path: `acc` changes only on a clock edge when `enable` is 1.

Use `clear` before starting a new dot product. Use `enable` only on cycles where
the current product should be added into the accumulator.

## Accumulator Width

Signed INT8 product boundaries:

```text
127 * 127     = 16129
-128 * 127    = -16256
-128 * -128   = 16384
```

A two-product dot product can reach:

```text
16384 + 16384 = 32768
```

That does not fit in signed 16-bit range, because signed 16-bit max is `32767`.
For the first 2x2 matrix path, use an explicitly signed 18-bit accumulator.

## Prediction Prompts

Before simulation, predict:

1. After reset, what should `acc` be?
2. If `a=7`, `b=3`, and `enable=1`, what should `acc` become after the next
   clock edge?
3. If `enable=0`, should `product` still change when `a` and `b` change?
4. If `enable=0`, should `acc` change?
5. What is `-7 * 3 + 12 * -5`?
6. Why does `16384 + 16384` prove 16-bit signed accumulation is not enough?
7. If the RTL zero-extends `product` before adding, what first failure do you
   expect for a negative product?

## Hands-On Tasks

In `rtl/int8_mac.v`, inspect or complete:

- Signed INT8 input declarations for `a` and `b`.
- A signed 16-bit `product`.
- A signed 18-bit `acc`.
- A clocked always block with reset, clear, enable, and hold behavior.
- Signed extension from 16-bit product to 18-bit accumulator width.

In `tb/tb_int8_mac.v`, inspect or complete:

- A self-checking task that applies one cycle and checks shortly after the edge.
- Reset and clear checks.
- Disabled-enable hold checks.
- Positive accumulation.
- Negative accumulation.
- Mixed-sign accumulation.
- Boundary products around `127`, `-128`, and `-1`.

## Debug Exercise

Compile once with the intentional signed-extension bug enabled:

```sh
mkdir -p sim
iverilog -Wall -DINTENTIONAL_MAC_EXTEND_BUG -o sim/tb_int8_mac_bug.vvp rtl/int8_mac.v tb/tb_int8_mac.v
vvp sim/tb_int8_mac_bug.vvp
```

Read the first `FAIL` line before editing RTL. Ask:

- Was the product supposed to be negative?
- Did the accumulator jump upward instead of downward?
- Is the multiplier wrong, or did the product enter the accumulator with the
  wrong sign extension?

Then open the waveform:

```sh
gtkwave sim/int8_mac.vcd
```

Inspect the first failing case and compare `a`, `b`, `product`, `enable`,
`clear`, `acc`, and the testbench `expected_acc`.

## Normal Test Commands

Focused test:

```sh
mkdir -p sim
iverilog -Wall -o sim/tb_int8_mac.vvp rtl/int8_mac.v tb/tb_int8_mac.v
vvp sim/tb_int8_mac.vvp
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
iverilog -Wall -o sim/tb_int8_mac.vvp rtl/int8_mac.v tb/tb_int8_mac.v
vvp sim/tb_int8_mac.vvp
```

## Waveform Inspection Checklist

Open `sim/int8_mac.vcd` and inspect:

- `clk`, `reset`, `clear`, and `enable`.
- `a` and `b` as signed decimal.
- `product` as signed decimal and hex.
- `acc` as signed decimal and hex.
- `expected_acc` in the testbench.
- A cycle where `product` changes but `enable=0` and `acc` holds.
- A clear cycle where `acc` becomes zero.
- A negative product being sign-extended into the accumulator.
- The boundary sequence `-128 * -128` twice, confirming `acc=32768`.

## Explain-Back Prompt

In your own words, explain this signal flow:

```text
signed a/b bits -> signed product -> sign extension -> enable-gated accumulator
```

Also explain why `product` can change between clocks while `acc` should only
change after a clock edge.

## Completion Criteria

- `rtl/int8_mac.v` implements reset, clear, enable, hold, and signed
  accumulation.
- `tb/tb_int8_mac.v` is self-checking and checks shortly after clock edges.
- Tests cover clear, disabled enable, positive accumulation, negative
  accumulation, mixed signs, and boundary products.
- The intentional signed-extension bug produces a meaningful first failure.
- The fixed focused MAC test passes.
- Full regression passes.
- `docs/PROGRESS.md` records verified progress, known issues, and exactly one
  Exact Next Action.
