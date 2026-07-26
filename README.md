# Digital IC Learning Journey

This repository tracks a hands-on path through digital IC design, AI hardware,
and computer architecture. The long-term direction is AI accelerators, RISC-V,
hardware-software co-design, verification automation, and AI for EDA.

## Current Status

Week 1 is complete. The repository contains combinational logic, adders,
multiplexers, sequential logic, and an extended 4-bit ALU with self-checking
verification. Week 2 builds a register file, controller FSM, and tiny execution
unit. Signed INT8 multiplier and MAC work begins in Week 3.

- Current verified status: [`docs/PROGRESS.md`](docs/PROGRESS.md)
- Week 2 hands-on plan: [`docs/week2_plan.md`](docs/week2_plan.md)
- Codex guidance and conversation handoff: [`AGENTS.md`](AGENTS.md)

## Goal

Before university begins, complete a readable RTL project that can be shown to
mentors or research supervisors. The project will gradually cover:

- Digital logic fundamentals
- Verilog/SystemVerilog
- Self-checking testbenches
- Waveform debugging
- Python golden models
- Basic synthesis and resource analysis
- INT8 multiply-accumulate hardware and small PE arrays

## Week 1 Completed

| Day | Work | Verified outcome |
| --- | --- | --- |
| Day 1 | Toolchain and repository setup | Git, Python, GCC, Icarus Verilog, GTKWave, and Yosys verified |
| Day 2 | Binary, hexadecimal, two's complement, and Boolean logic | Notes, truth tables, and Python practice helper |
| Day 3 | Minimal Verilog syntax and combinational logic | Simple logic RTL and testbench run successfully |
| Day 4 | Half, full, and ripple-carry adders | Self-checking adder regression passes |
| Day 5 | Direct and hierarchical multiplexers | Self-checking mux regression passes |
| Day 6 | Flip-flop, register, counter, reset, and enable | Sequential regression passes |
| Day 7 | Extended 4-bit ALU and flags | Directed tests and 512 ADD/SUB combinations pass |

## Repository Structure

```text
.
+-- AGENTS.md      # Durable guidance for Codex conversations
+-- docs/          # Study notes, progress, plans, and summaries
+-- rtl/           # Verilog/SystemVerilog design files
+-- tb/            # Testbenches
+-- scripts/       # Tool checks and utility scripts
+-- sim/           # Generated simulation outputs; usually not committed
+-- README.md
```

## Quick Start

Open MSYS2 UCRT64 and run:

```bash
cd /c/Users/14138/Documents/IC_design_project_2026/digital-ic-journey
mkdir -p sim
iverilog -g2012 -Wall -o sim/tb_alu4.vvp rtl/alu4.v tb/tb_alu4.v
vvp sim/tb_alu4.vvp
```

Expected final result:

```text
PASS: all ALU tests passed
```

For a new conversation, ask Codex to read `AGENTS.md`, `docs/PROGRESS.md`, Git
status, and the relevant RTL/testbench before continuing.
