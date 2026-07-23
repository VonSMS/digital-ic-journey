# Day 7: 4-bit ALU Design and Verification

Date: 2026-07-23

## Learning goals

Today you will build a small 4-bit ALU, verify it with a golden model, debug one intentional RTL bug, debug one intentionally wrong testbench expectation, and inspect flags in GTKWave.

By the end, you should be able to explain:

1. What an ALU does in a CPU or AI accelerator.
2. How datapath values differ from control signals.
3. How an opcode selects an operation.
4. How ADD, SUB, AND, OR, XOR, and pass A are selected inside one module.
5. How subtraction uses two's complement.
6. Why 4-bit arithmetic wraps.
7. How zero, carry, and overflow flags are produced.
8. Why unsigned carry and signed overflow are different ideas.
9. How a mux selects the ALU result.
10. How a self-checking testbench uses a golden model.

## 1. Intuition: what an ALU is

An ALU is an Arithmetic Logic Unit. It is a combinational hardware block that takes operands and an operation choice, then produces a result.

```text
          opcode
            |
            v
A ----> [ 4-bit ALU ] ----> result
B ----> [          ] ----> zero, carry, overflow
```

CPUs need ALUs for instruction execution: add addresses, subtract loop counters, compare values, and run bitwise instructions like AND/OR/XOR.

AI accelerators also need ALU-like datapaths. Matrix multiply units are famous, but accelerators still need adders, counters, address generation, activation support, quantized integer operations, accumulation, masking, and control/status calculations. A tensor core is larger than this lab, but it is still built from datapath operations selected by control.

Think first: if a RISC-V instruction says `add x3, x1, x2`, which parts are data, and which part is control?

## 2. Datapath versus control

The datapath carries the values being processed:

```text
A operand, B operand, adder output, logic output, final result
```

Control signals tell the datapath what to do:

```text
opcode, mux select, register enable, write enable
```

In this lab:

| Signal | Role |
| --- | --- |
| `a[3:0]`, `b[3:0]` | datapath operands |
| `opcode[2:0]` | control signal |
| `result[3:0]` | datapath output |
| `zero`, `carry`, `overflow` | status flags derived from datapath result |

## 3. Opcode selects the operation

An opcode is just a compact code for a choice.

| Opcode | Operation |
| --- | --- |
| `3'b000` | ADD |
| `3'b001` | SUB |
| `3'b010` | AND |
| `3'b011` | OR |
| `3'b100` | XOR |
| `3'b101` | pass A |
| `3'b110`, `3'b111` | invalid, return zero in this lab |

Internally, you can imagine the ALU computing several candidate results, then using a mux controlled by `opcode`:

```text
add_result ----\
sub_result -----\
and_result ------\
or_result -------- mux selected by opcode ---> result
xor_result ------/
pass_a_result --/
zero ----------/
```

The Verilog `case (opcode)` acts like that mux.

## 4. Two's complement subtraction

Subtraction is implemented as addition of a negated number:

```text
A - B = A + (~B + 1)
```

For 4-bit values:

```text
4'h8 - 4'h1
= 1000 - 0001
= 1000 + 1110 + 1
= 1000 + 1111
= 1_0111
```

The 4-bit result is `0111` (`4'h7`). The extra high bit is the unsigned carry-out. For subtraction, this carry-out is commonly interpreted as no borrow when it is 1.

Now interpret the same bits two ways:

| Bits | Hex | Unsigned | Signed 4-bit two's complement |
| --- | --- | ---: | ---: |
| `0111` | `4'h7` | 7 | +7 |
| `1000` | `4'h8` | 8 | -8 |
| `1111` | `4'hF` | 15 | -1 |
| `0000` | `4'h0` | 0 | 0 |

So `4'h8 - 4'h1` means unsigned `8 - 1 = 7`, but signed `-8 - 1` is below the minimum signed 4-bit value. That signed operation overflows, even though the 4-bit result bits are `0111`.

## 5. Bus width matters

A 4-bit result can only keep the low 4 bits. Addition and subtraction use a 5-bit temporary in the RTL so the ALU can see the carry-out:

```verilog
wire [4:0] add_full = {1'b0, a} + {1'b0, b};
```

Examples:

| Expression | Full math | 4-bit result | Unsigned carry | Signed overflow |
| --- | --- | --- | --- | --- |
| `4'hF + 4'h1` | `1_0000` | `0000` | 1 | 0 |
| `4'h7 + 4'h1` | `0_1000` | `1000` | 0 | 1 |
| `4'h8 - 4'h1` | `1_0111` | `0111` | 1 | 1 |
| `4'h0 - 4'h1` | `0_1111` | `1111` | 0 | 0 |

The important habit: always ask whether you are interpreting bits as unsigned or signed.

## 6. Flags

`zero` is simple:

```verilog
assign zero = (result == 4'b0000);
```

`carry` for ADD is the 5th bit of the 5-bit sum. For SUB in this lab, `carry=1` means no unsigned borrow, and `carry=0` means borrow.

Signed overflow is different. It asks: did the signed answer fall outside -8 to +7?

ADD overflow rule:

```text
same input signs, different result sign
```

SUB overflow rule:

```text
different input signs, result sign differs from A
```

Carry is for unsigned arithmetic. Overflow is for signed arithmetic. They can disagree, and that is not a bug.

## 7. Read the RTL

Open `rtl/alu4.v` and find:

1. The opcode localparams.
2. The 5-bit `add_full` and `sub_full` wires.
3. The candidate datapath results: add, sub, and, or, xor, pass A.
4. The `case (opcode)` mux.
5. The flag logic for ADD and SUB.
6. The default invalid-opcode behavior.

Explain the data flow in your own words before simulating:

```text
A and B feed several operation blocks in parallel. The opcode controls a mux. The selected result feeds zero flag logic. ADD/SUB also select carry and overflow meanings.
```

Now answer: why is this ALU combinational even if a CPU places it between two registers?

## 8. Predict before running

Write down your predictions before you run the simulation.

| Case | Binary view | Unsigned view | Signed view | Predict result/carry/overflow/zero |
| --- | --- | --- | --- | --- |
| `4'hF + 4'h1` | `1111 + 0001` | `15 + 1` | `-1 + 1` | ? |
| `4'h7 + 4'h1` | `0111 + 0001` | `7 + 1` | `7 + 1` | ? |
| `4'h8 - 4'h1` | `1000 - 0001` | `8 - 1` | `-8 - 1` | ? |
| equal operands `A - A` | example `1010 - 1010` | equal minus equal | equal minus equal | ? |
| all-zero operands | `0000, 0000` | 0 and 0 | 0 and 0 | ? |
| all-one operands | `1111, 1111` | 15 and 15 | -1 and -1 | ? |

Do not skip this. The simulation is much more useful when it surprises a prediction.

## 9. Run the passing simulation using MSYS2 UCRT64

Open the MSYS2 UCRT64 terminal:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
mkdir -p sim
iverilog -g2012 -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4.vvp
```

Expected final line:

```text
PASS: all ALU tests passed
```

Read every PASS line once. Compare the printed result, carry, and overflow against your predictions.

## 10. Debug the intentional RTL bug

Now compile the built-in teaching bug:

```bash
iverilog -g2012 -Wall -DINTENTIONAL_ALU_BUG -o sim/tb_alu4_bug.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4_bug.vvp
```

The macro changes XOR into OR inside the RTL.

Your job:

1. Read the first FAIL only.
2. Identify the opcode.
3. Compare expected result and actual result.
4. Explain why OR and XOR are identical for `4'hA` and `4'h5`, but not for overlapping 1 bits such as `4'hF` and `4'hA`.
5. Re-run without `-DINTENTIONAL_ALU_BUG` to prove the design returns to passing.

## 11. Debug the intentionally wrong testbench expectation

Now keep the RTL correct, but enable the wrong checker expectation:

```bash
iverilog -g2012 -Wall -DWRONG_TB_EXPECTATION -o sim/tb_alu4_bad_tb.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4_bad_tb.vvp
```

The testbench deliberately expects `carry=0` for `4'hF + 4'h1`. That is wrong for unsigned addition. The correct 5-bit sum is `1_0000`, so carry must be 1.

Your job:

1. Read the first FAIL.
2. Decide whether RTL or testbench is wrong.
3. Explain the difference between 4-bit result wrap and the 5th carry bit.
4. Re-run the normal command and confirm all tests pass.

## 12. Inspect the waveform in GTKWave

Run the normal passing simulation again, then:

```bash
gtkwave sim/alu4.vcd
```

Add these signals:

1. `a[3:0]`
2. `b[3:0]`
3. `opcode[2:0]`
4. `result[3:0]`
5. `zero`
6. `carry`
7. `overflow`
8. Optional internal DUT signals: `add_full`, `sub_full`, `add_result`, `sub_result`, `xor_result`

Set buses to Hex first, then switch to Binary for the three boundary cases.

Waveform questions:

1. At `4'hF + 4'h1`, why are `result=0`, `zero=1`, `carry=1`, and `overflow=0`?
2. At `4'h7 + 4'h1`, why is `carry=0` but `overflow=1`?
3. At `4'h8 - 4'h1`, why can the unsigned result look normal while signed overflow is high?
4. Which opcode selects XOR? Which test catches XOR accidentally becoming OR?
5. What do invalid opcodes produce in this lab?

## 13. Explain-back checklist

Without reading the solution text, explain:

1. An ALU is ...
2. The datapath is ..., while control signals are ...
3. The opcode selects the result by ...
4. Subtraction is implemented as ...
5. A 4-bit bus wraps because ...
6. Unsigned carry means ..., signed overflow means ...
7. The ALU is combinational because ...
8. The golden model helps because ...

For the most important final question, use your own words:

```text
Why is the ALU combinational even when placed between registers?
```

A strong answer mentions that the registers store values on clock edges, while the ALU itself continuously computes from its current inputs and opcode between those edges.

## 14. Optional practice edits

Try one at a time:

1. Add opcode `3'b110` for `~A`.
2. Add opcode `3'b111` for `A + 1`.
3. Change invalid opcodes to produce `4'hF` and update the golden model.
4. Add a negative flag: `negative = result[3]`.
5. Add loops to test all 16 x 16 input pairs for ADD and SUB.

The useful workflow is the same as day 6:

```text
predict -> simulate -> read the first failure -> inspect the waveform -> explain the data flow -> fix one cause
```
