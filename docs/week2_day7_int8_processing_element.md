# Week 2 Day 7: INT8 Processing Element

## Goal

Build one signed INT8 processing element (PE): a multiplier feeding a signed
18-bit accumulator, controlled by `clear` and `enable`.

The PE computes one dot-product result over multiple cycles:

```text
acc = 0
acc = acc + a0 * b0
acc = acc + a1 * b1
```

For one 2x2 matrix output:

```text
C00 = A00 * B00 + A01 * B10
```

## Intuition First

A processing element is a tiny arithmetic worker.

- `a` and `b` are the current operands.
- `product` is the combinational multiplier result.
- `acc` is storage, so it changes only on a clock edge.
- `clear` starts a fresh dot product.
- `enable` says this cycle's product should be added into `acc`.

The important habit: control decides when arithmetic is remembered. The product
can change any time the inputs change, but the accumulator should only change on
the clock edge when the control signals allow it.

## Prediction Prompts

Before running simulation, predict these:

1. `C00 = 2*4 + (-3)*5` should equal what signed value?
2. If `clear=1` and `enable=1` on the same clock edge, should the PE clear or
   accumulate?
3. If `enable=0` while `a` and `b` change, what should happen to `acc`?
4. If a clear/enable priority bug exists, which signal first looks suspicious:
   `product`, `acc`, `clear`, or `enable`?

## Hands-On RTL Tasks

Open `rtl/int8_processing_element.v`.

Complete or review these parts:

1. Declare signed INT8 inputs and a signed 16-bit product.
2. Sign-extend the 16-bit product to the 18-bit accumulator width.
3. In the clocked always block, make reset highest priority.
4. Make `clear` happen before `enable`, so a new dot product starts from zero.

The key signal-flow sentence to keep in mind:

```text
a,b bits -> signed multiply -> signed product -> sign extension -> accumulator
```

## Hands-On Testbench Tasks

Open `tb/tb_int8_processing_element.v`.

Review or extend the self-checking tasks:

- `apply_cycle` predicts the next accumulator value before the clock edge.
- `two_product_dot` clears once, then enables two multiply-accumulate cycles.
- Directed tests cover normal products, disabled hold, mixed signs, and
  boundary values.

Add one extra dot-product case of your own before the final regression. Good
practice values are small enough to calculate mentally, such as:

```text
3*(-2) + 4*5
```

## Intentional Debug Exercise

Compile with the teaching bug enabled:

```sh
mkdir -p sim
iverilog -Wall -DINTENTIONAL_PE_CLEAR_ENABLE_BUG -o sim/tb_int8_processing_element_bug.vvp rtl/int8_processing_element.v tb/tb_int8_processing_element.v
vvp sim/tb_int8_processing_element_bug.vvp
```

Read only the first `FAIL`.

Expected debugging path:

1. Check whether `product` is mathematically correct.
2. Check whether `clear` and `enable` are both high.
3. Check whether `acc` cleared to zero or incorrectly accumulated.
4. Conclude whether the bug is in arithmetic or control priority.

Fix by compiling without the bug macro:

```sh
iverilog -Wall -o sim/tb_int8_processing_element.vvp rtl/int8_processing_element.v tb/tb_int8_processing_element.v
vvp sim/tb_int8_processing_element.vvp
```

## Waveform Inspection Checklist

Open:

```sh
gtkwave sim/int8_processing_element.vcd
```

Inspect:

- `clk`
- `reset`
- `clear`
- `enable`
- `a`
- `b`
- `product`
- `acc`
- `expected_acc` from the testbench

Checklist:

- During reset, `acc` becomes zero.
- When `enable=0`, `product` may change but `acc` holds.
- When `clear=1`, `acc` becomes zero on the next clock edge.
- During a two-product dot product, `acc` changes once per enabled clock edge.
- Negative products are sign-extended before accumulation.

## Explain-Back Prompt

In your own words, explain:

```text
Why is product combinational, but acc clocked?
Why does clear need priority over enable before a new dot product?
```

## Completion Criteria

- `rtl/int8_processing_element.v` is implemented in Icarus-compatible Verilog.
- `tb/tb_int8_processing_element.v` is self-checking.
- The intentional bug produces a useful first failure.
- The fixed PE passes the focused test.
- The waveform shows reset, clear, enable, product, and accumulator timing.
