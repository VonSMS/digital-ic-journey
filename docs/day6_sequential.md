# Day 6: Sequential Logic — Flip-Flops, Registers, and Counters


## Learning goals

By the end of this lab, you should be able to predict state changes before simulation, explain why a register waits for a clock edge, distinguish synchronous and asynchronous reset, and debug timing mistakes with a self-checking testbench and GTKWave.

## 1. Intuition: a circuit that remembers

Combinational logic is like a calculator: change the inputs and, after propagation delay, the output follows. It has no memory of yesterday's inputs.

Sequential logic combines two things:

1. combinational logic that computes a possible **next state**, and
2. storage elements that keep the **current state** until a clock event.

```text
inputs ----> next-state logic ----> D  [register]  Q ----> outputs
                 ^                        |         |
                 |                        clock     |
                 +--------- current state Q <------+
```

Hardware needs state to count events, step through instructions, pipeline an AI accelerator, remember protocol progress, store RISC-V architectural registers, and coordinate multi-cycle work. Without state, a CPU or accelerator would only be one large instant input-to-output function.

**Think:** Which part of the diagram is combinational, and which part remembers?

## 2. The D flip-flop

A D flip-flop stores one bit. For a positive-edge-triggered DFF:

```text
at rising edge: q_next = d
between edges:  q holds its previous value
```

The edge is an instant, not the whole time the clock is high. `posedge` means a 0-to-1 transition; `negedge` means a 1-to-0 transition.

Before simulation, predict this trace:

| Time | Event | `d` | What should `q` do? |
| ---: | --- | :-: | --- |
| 10 ns | `d` changes between edges | 1 | ? |
| 15 ns | rising edge | 1 | ? |
| 18 ns | `d` changes | 0 | ? |
| 20 ns | falling edge | 0 | ? for posedge DFF? What about negedge DFF? |
| 25 ns | rising edge | 0 | ? |

Write your answers before running the lab.

## 3. Reset: return state to a known value

Simulation state begins as unknown (`x`) unless something initializes it. Real hardware also needs a deliberate startup/recovery strategy. Reset puts state into a known condition.

### Asynchronous reset

```verilog
always @(posedge clk or posedge reset)
```

When active-high `reset` rises, the register clears immediately; it does not wait for a clock. This lab uses asynchronous reset.

### Synchronous reset

```verilog
always @(posedge clk)
```

The `if (reset)` is still inside the block, but reset is observed only on the rising edge.

**Predict:** If asynchronous reset becomes 1 halfway between two rising edges, when does `q` clear? If the reset were synchronous, when would it clear?

Reset assertion and deassertion deserve careful treatment in real designs. A common policy is asynchronous assertion and synchronized deassertion so different registers do not leave reset inconsistently.

## 4. RTL patterns and data flow

### One-bit DFF

See `rtl/dff.v`. Its key pattern is:

```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
```

Use non-blocking assignment (`<=`) for clocked state. It models all registers sampling old values at the edge and updating together after the event. Blocking assignment (`=`) is normally used for combinational procedural logic.

### Four-bit register

A register is several flip-flops sharing clock and reset. `register4` captures all four input bits at the same rising edge. `register4_enable` adds a choice:

```text
enable=1: load d at the edge
enable=0: assign nothing, so q holds
```

In a clocked block, this omitted `else` means intentional storage. That is different from accidentally omitting an assignment in a combinational `always @(*)` block, which can infer an unwanted latch.

### Four-bit counter

The counter feeds its state through an incrementer and back to D:

```text
                  +1
count(Q) -------->[adder]--------> D [4-bit register] Q=count
```

At each enabled rising edge, `count <= count + 1`. Four bits wrap naturally from `1111` to `0000`.

**Predict:** Starting after reset at `0000`, list the next five values. What follows `1110`? When is `terminal_count` high? What follows `1111`?

`terminal_count` is combinational decode: it is high whenever stored count is `1111`. It is not an extra registered state in this design.

### Mux feeding a register

`mux_register4` makes the combinational/sequential boundary visible:

```text
a ----0\
        mux ---- mux_y ---- D [register] Q ---- mux_reg_q
b ----1/            ^          ^
                  select      rising edge
```

Changing `a`, `b`, or `select_b` changes `mux_y` immediately. `mux_reg_q` changes only when the register samples `mux_y` at a rising edge.

**Explain in your own words:** Why can `mux_y` change between edges while `mux_reg_q` cannot?

## 5. Run the passing self-checking lab (UCRT64)

Open the **MSYS2 UCRT64** terminal:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
mkdir -p sim
iverilog -g2012 -Wall -o sim/tb_sequential.vvp \
  rtl/dff.v rtl/register4.v rtl/counter4.v tb/tb_sequential.v
vvp sim/tb_sequential.vvp
```

The testbench drives inputs on falling edges, giving them time to settle before the next rising edge. It checks state at `#1` after each rising edge so non-blocking assignments have completed. It maintains independent expected-state variables—a small golden model—and prints a clear PASS or FAIL for every comparison.

Expected final line:

```text
PASS: all sequential logic tests passed
```

## 6. Catch an intentional RTL bug

Do not edit the correct code yet. Compile the built-in teaching bug:

```bash
iverilog -g2012 -Wall -DINTENTIONAL_BUG -o sim/tb_sequential_bug.vvp \
  rtl/dff.v rtl/register4.v rtl/counter4.v tb/tb_sequential.v
vvp sim/tb_sequential_bug.vvp
```

The macro changes `dff` from `posedge` to `negedge`. Predict which DFF check fails first. Read the first FAIL's time, expected value, and actual value. Then inspect that time in GTKWave and explain why the checker expected a rising-edge sample but the buggy RTL did not take one.

Debug questions:

1. Is reset working?
2. Does `q` change at rising or falling edges?
3. Was `d` stable before the intended edge?
4. Which sensitivity-list word fixes the behavior?

## 7. See a wrong testbench fail against correct RTL

Return to correct RTL and enable only the checker mistake:

```bash
iverilog -g2012 -Wall -DWRONG_TB_EXPECTATION -o sim/tb_sequential_bad_tb.vvp \
  rtl/dff.v rtl/register4.v rtl/counter4.v tb/tb_sequential.v
vvp sim/tb_sequential_bad_tb.vvp
```

The deliberate check executes in the same simulation time slot as the rising edge and expects the new `q` immediately. With non-blocking assignment, `q` updates later in that time slot. The design is right; the observer is early.

Fix concept: sample after a tiny delay (`#1` in this beginner lab), at the following falling edge, or use SystemVerilog clocking blocks/assertion sampling in a more advanced environment. Do not “fix” correct RTL by changing `<=` to `=`.

## 8. Inspect the waveform in GTKWave

Run the default passing simulation again so `sim/sequential.vcd` comes from correct RTL, then:

```bash
gtkwave sim/sequential.vcd
```

Add these signals in this order:

1. `clk`, `reset`
2. `d`, `dff_q`, `dff_q_negedge`
3. `reg_d`, `reg_enable`, `reg_q`, `reg_enable_q`
4. `counter_enable`, `count`, `count_enable`, `count_terminal`, `terminal_count`
5. `mux_a`, `mux_b`, `select_b`, `mux_y`, `mux_reg_q`

Set 4-bit buses to Binary or Hex. Zoom until individual 10 ns clock periods are clear. Place a marker on a rising edge and answer:

- What was `d` just before the edge, and what is `dff_q` just after it?
- Does `reg_enable_q` hold when enable is 0?
- At which edge does the counter become `1111`? When does it wrap?
- Find a between-edge change of `mux_y`. Why does `mux_reg_q` wait?
- Assert reset mid-cycle: does state clear before the next rising edge?

Remember that delta-cycle updates can look vertically aligned with the clock edge at this zoom level. Zooming and using markers clarifies event order even though no physical propagation delay was modeled.

## 9. Common bugs and symptoms

| Bug | Likely symptom | What to inspect |
| --- | --- | --- |
| Missing reset | State starts `x`; counter may remain `x` | reset port, reset branch, waveform at time 0 |
| Wrong edge | Output changes on falling rather than rising edges | sensitivity list and clock waveform |
| Blocking `=` in clocked logic | Race/order-dependent simulation behavior | clocked assignments; replace with `<=` |
| Non-blocking `<=` in simple combinational logic | Unexpected delta delays or confusing modeling | use `=` inside `always @(*)` |
| Checker samples at the edge | RTL looks one cycle late even though it is correct | sample after NBA update, not in same active region |
| Inputs change exactly at edge | Race; result depends on simulator scheduling | drive away from sampling edge |
| Wrong enable polarity | register/counter holds when expected to load | enable condition and waveform |
| Wrong terminal comparison | flag one count early/late | compare stored `count` with `4'b1111` |

## 10. Explain-back checklist

Without reading the earlier sections, say or write:

1. “Combinational logic does ..., while sequential logic does ...”
2. “A positive-edge DFF looks at D when ..., and holds Q when ...”
3. “Asynchronous reset differs from synchronous reset because ...”
4. “The register output changes only after a clock edge because ...”
5. “The enable signal affects the next state by ...”
6. “The mux output and registered mux output differ because ...”
7. “The self-checking testbench avoids a timing race by ...”
8. “A 4-bit counter wraps because ...”

If any sentence feels vague, return to the waveform and point to one concrete edge that proves it.

## 11. Optional edits for more practice

Try one change at a time, predict the failure, simulate, inspect, and restore:

1. Remove `or posedge reset` from `register4` but leave the reset branch. Is reset now synchronous or broken?
2. Change one `posedge` to `negedge`. Which checker catches it?
3. Change `counter4_enable` to count when `enable` is 0. Predict the first mismatch.
4. Compare terminal count with `4'b1110`. Find the one-cycle error.
5. Change a clocked `<=` to `=` and consider why this tiny isolated design may still appear to pass—then explain why that does not make the style safe for interacting registers.
6. Add a down-counter with enable and predict the wrap from `0000` to `1111`.

The useful habit is: **predict → run → read the first failure → inspect the edge → explain the data flow → fix one cause**.

