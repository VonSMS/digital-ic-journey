# Day 3 Minimal Verilog Syntax

Date: 2026-07-13

## Goal

Learn just enough Verilog to read, modify, and simulate simple combinational logic.

By the end of Day 3, I should be able to:

1. Explain what a `module` is.
2. Declare `input` and `output` ports.
3. Use `wire` for internal signals.
4. Use `assign` for simple combinational logic.
5. Use the basic logic operators `~`, `&`, `|`, and `^`.
6. Run a small testbench with Icarus Verilog.

## 1. What Is Verilog?

Verilog is a hardware description language.

That means Verilog does not describe steps for a CPU to execute like Python does. Verilog describes hardware structure and behavior.

For example, this line:

```verilog
assign y = a & b;
```

means:

```text
Create combinational logic where y is the AND result of a and b.
```

It does not mean:

```text
Run this line once and then move to the next line.
```

This difference is very important.

## 2. Minimal Module Structure

A Verilog module is like a circuit block.

Example:

```verilog
module and_gate (
    input  a,
    input  b,
    output y
);

assign y = a & b;

endmodule
```

Meaning:

| Verilog | Meaning |
| --- | --- |
| `module and_gate` | Start a circuit block named `and_gate` |
| `input a` | `a` is an input signal |
| `input b` | `b` is an input signal |
| `output y` | `y` is an output signal |
| `assign y = a & b;` | Continuously drive `y` with `a AND b` |
| `endmodule` | End the module |

## 3. Ports: input and output

Ports are the signals that enter or leave a module.

```verilog
module example (
    input  a,
    input  b,
    output y
);
```

This module has:

```text
2 inputs:  a, b
1 output:  y
```

For Day 3, we mostly use one-bit signals.

## 4. Internal Signals: wire

Sometimes a circuit needs an internal connection.

Example:

```verilog
module example (
    input  a,
    input  b,
    output y
);

wire n;

assign n = ~a;
assign y = n & b;

endmodule
```

Here:

```text
n is an internal wire.
y = (~a) & b.
```

Use `wire` when you want to name an intermediate signal.

## 5. Continuous Assignment: assign

`assign` describes combinational logic.

Example:

```verilog
assign y = a | b;
```

This means:

```text
Whenever a or b changes, y updates automatically.
```

This is why it is called continuous assignment.

For now:

```text
Use assign for simple logic gates.
Do not use always blocks yet.
```

## 6. Basic Logic Operators

These are the operators from Day 2 Boolean logic:

| Operator | Name | Example |
| --- | --- | --- |
| `~` | NOT | `assign y = ~a;` |
| `&` | AND | `assign y = a & b;` |
| `\|` | OR | `assign y = a | b;` |
| `^` | XOR | `assign y = a ^ b;` |

Example module:

```verilog
module logic_gates (
    input  a,
    input  b,
    output y_not_a,
    output y_and,
    output y_or,
    output y_xor
);

assign y_not_a = ~a;
assign y_and   = a & b;
assign y_or    = a | b;
assign y_xor   = a ^ b;

endmodule
```

## 7. Tiny Testbench Idea

A testbench is Verilog code used to test another Verilog module.

The design module describes hardware you want to build.

The testbench:

```text
Creates input values
Waits for the outputs
Prints or checks the results
Optionally creates a waveform file
```

For Day 3, the testbench tries all four combinations of `a` and `b`:

| a | b |
| --- | --- |
| 0 | 0 |
| 0 | 1 |
| 1 | 0 |
| 1 | 1 |

This matches the Day 2 truth table style.

## 8. Files Created Today

```text
rtl/simple_logic.v
tb/tb_simple_logic.v
docs/day3_minimal_verilog.md
```

## 9. Commands

From the repository root:

```powershell
iverilog -o .\sim\simple_logic.vvp .\rtl\simple_logic.v .\tb\tb_simple_logic.v
vvp .\sim\simple_logic.vvp
```

The testbench also writes a waveform:

```text
sim/simple_logic.vcd
```

To view it:

```powershell
gtkwave .\sim\simple_logic.vcd
```

## 10. Practice

Try these small edits:

1. Add an output named `y_nand`.
2. Implement it as `assign y_nand = ~(a & b);`.
3. Add it to the testbench print statement.
4. Re-run the simulation.

Then try:

1. Add an output named `y_nor`.
2. Implement it as `assign y_nor = ~(a | b);`.
3. Re-run the simulation.

## Day 3 Summary

Today connects Day 2 Boolean logic to real Verilog syntax. A Verilog `module` is a circuit block. `input` and `output` define the block boundary. `wire` names internal connections. `assign` creates continuous combinational logic. The operators `~`, `&`, `|`, and `^` directly map to NOT, AND, OR, and XOR gates.
