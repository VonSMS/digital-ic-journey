# Digital IC Learning Journey

A hands-on Verilog learning project that grows from basic digital logic into a
small signed INT8 matrix-multiply accelerator.

The final verified design path is:

```text
simple gates
-> adders and muxes
-> registers and counters
-> 4-bit ALU with flags
-> 4x4 register file
-> controller FSM and result register
-> tiny execution unit
-> signed INT8 multiplier
-> signed INT8 MAC
-> INT8 processing element
-> four-PE signed INT8 2x2 matrix multiply block
```

## Highlights

- Verilog RTL compatible with Icarus Verilog.
- Self-checking testbenches with directed, boundary, and exhaustive cases where
  practical.
- VCD waveform generation for GTKWave inspection.
- Intentional bug paths for debugging practice, including signed arithmetic,
  accumulator extension, clear/enable priority, and handshake timing.
- A small AI-accelerator-style datapath using four parallel processing elements
  to compute signed INT8 2x2 matrix multiplication.

## Final Accelerator

The final module is `rtl/matmul2x2_int8.v`.

It computes:

```text
C = A x B

C00 = A00*B00 + A01*B10
C01 = A00*B01 + A01*B11
C10 = A10*B00 + A11*B10
C11 = A10*B01 + A11*B11
```

Architecture:

- Four `int8_processing_element` instances run in parallel.
- Each PE contains a signed INT8 multiplier and signed 18-bit accumulator.
- The controller FSM runs:

```text
IDLE -> CLEAR -> MAC0 -> MAC1 -> DONE -> IDLE
```

- `CLEAR` resets all PE accumulators before a new matrix multiply.
- `MAC0` accumulates the `k=0` products.
- `MAC1` accumulates the `k=1` products.
- `DONE` indicates that all four matrix outputs are valid.

## Verified Tests

The project has been regression-tested through:

| Testbench | Coverage focus |
| --- | --- |
| `tb_simple_logic.v` | basic gates and truth table behavior |
| `tb_adders.v` | half adder, full adder, ripple-carry adders |
| `tb_muxes.v` | direct and hierarchical muxes |
| `tb_sequential.v` | DFF, register, counter, reset, enable |
| `tb_alu4.v` | 4-bit ALU operations and flags, including ADD/SUB coverage |
| `tb_decoder2to4.v` | one-hot decode behavior |
| `tb_register_file4x4.v` | reset, writes, reads, same-address timing |
| `tb_controller_fsm.v` | start/busy/done/capture sequencing |
| `tb_tiny_execution_unit.v` | register file + ALU + controller datapath |
| `tb_int8_multiplier.v` | signed INT8 multiplication, including exhaustive input pairs |
| `tb_int8_mac.v` | clear, enable, signed extension, accumulation |
| `tb_int8_processing_element.v` | two-cycle dot products and PE control |
| `tb_matmul2x2_int8.v` | zero, identity, positive, mixed-sign, and boundary matrices |

Detailed progress and verification notes are in
[`docs/PROGRESS.md`](docs/PROGRESS.md).

## Quick Start

Open MSYS2 UCRT64 and run:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
mkdir -p sim
iverilog -Wall -o sim/tb_matmul2x2_int8.vvp rtl/int8_processing_element.v rtl/matmul2x2_int8.v tb/tb_matmul2x2_int8.v
vvp sim/tb_matmul2x2_int8.vvp
```

Expected final line:

```text
PASS: all matmul2x2_int8 tests passed with 5 checks
```

To inspect the final waveform:

```bash
gtkwave sim/matmul2x2_int8.vcd
```

Recommended signals:

```text
clk, reset, start, busy, done, dut.state, c00, c01, c10, c11,
PE inputs, PE products, and PE accumulators
```

To run the full verified regression:

```bash
bash scripts/run_regression.sh
```

## Repository Structure

```text
.
+-- AGENTS.md      # Durable guidance for Codex learning sessions
+-- docs/          # Teaching notes, progress logs, plans, and summaries
+-- rtl/           # Verilog RTL design files
+-- tb/            # Self-checking Verilog testbenches
+-- scripts/       # Tool checks and practice utilities
+-- sim/           # Generated simulation outputs, ignored by Git
+-- README.md
```

## Learning Notes

Each learning day has a unified Markdown file under `docs/` with intuition,
prediction prompts, hands-on tasks, debug exercises, waveform checklists,
explain-back prompts, and completion criteria.

Useful entry points:

- [`docs/PROJECT_SUMMARY.md`](docs/PROJECT_SUMMARY.md)
- [`docs/PROGRESS.md`](docs/PROGRESS.md)
- [`docs/int8_matrix_6_day_plan.md`](docs/int8_matrix_6_day_plan.md)
- [`docs/week2_day8_int8_matmul2x2.md`](docs/week2_day8_int8_matmul2x2.md)

## Status

The verified main learning path is complete through the signed INT8 2x2 matrix
multiply accelerator. The repository is ready for review as an introductory
digital IC and AI hardware learning portfolio.
