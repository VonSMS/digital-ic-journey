# Digital IC Learning Journey

This repository tracks my self-study journey in digital IC design, AI hardware, and computer architecture.

## Goal

Before university begins, the goal is to complete a small but readable RTL project that can be shown to mentors or research supervisors. The project will gradually cover:

- Digital logic fundamentals
- Verilog/SystemVerilog
- Self-checking testbenches
- Waveform debugging
- Python golden models
- Basic synthesis and resource analysis

## Week 1 Plan

| Day | Task | Acceptance Criteria |
| --- | --- | --- |
| Day 1 | Set up Git, Python, GCC, Icarus Verilog, GTKWave, and Yosys; create the repository | Tool checks pass and the repository structure is clear |
| Day 2 | Study binary numbers, hexadecimal numbers, two's complement, and Boolean algebra | Complete notes and logic-gate exercises |
| Day 3 | Study minimal Verilog syntax: module, input, output, wire, assign, and basic logic operators | Simple Verilog modules and a tiny testbench simulate successfully |
| Day 4 | Implement half adder and full adder | RTL, testbench, and waveform output are available |
| Day 5 | Implement multiplexers and basic combinational blocks | Automated tests cover the basic operations |
| Day 6 | Build a tiny ALU and write a self-checking testbench | Normal and edge cases produce clear pass/fail results |
| Day 7 | Organize the README, architecture diagram, test results, and weekly summary | Another person can read, run, and understand the project |

## Repository Structure

```text
.
+-- docs/          # Study notes, setup records, and weekly summaries
+-- rtl/           # Verilog/SystemVerilog design files
+-- tb/            # Testbenches
+-- scripts/       # Tool checks and utility scripts
+-- sim/           # Simulation outputs; usually not committed
+-- README.md
```
