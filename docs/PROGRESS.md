# Project Progress

Last updated: 2026-08-07

## Current Status

- Week 1: complete and regression-tested
- Current phase: Week 2
- Week 2 plan: one full conversation per day, five focused conversation-days
- Week 2 warm-up: 2-to-4 decoder complete
- Week 2 Day 1: 4x4 register file complete
- Current conversation-day: Day 2, register file verification depth
- Next module: stronger register file verification
- Week 2 milestone: register file + ALU + result register + controller FSM
- Week 3 milestone: signed INT8 multiplier and MAC

## Week 1 Completed

- Toolchain: MSYS2 UCRT64, Git, Python, GCC, Icarus Verilog, GTKWave, Yosys
- Number systems: binary, hexadecimal, unsigned, two's complement, Boolean logic
- RTL: simple gates, half/full/ripple adders, muxes, DFF, register, counter
- ALU: ADD, SUB, AND, OR, XOR, PASS A, NOT A, A+1
- Flags: zero, carry/no-borrow, overflow, negative
- Verification: self-checking tests, golden model, VCD/GTKWave, intentional bugs
- Coverage: all 512 ADD/SUB input-operation combinations

## Verified on 2026-07-26

- `tb_simple_logic.v`: ran successfully
- `tb_adders.v`: PASS
- `tb_muxes.v`: PASS
- `tb_sequential.v`: PASS
- `tb_alu4.v`: PASS

## Verified on 2026-08-03

- `tb_decoder2to4.v`: PASS after fixing the swapped `select=01` and
  `select=10` one-hot outputs
- `tb_register_file4x4.v`: PASS after fixing the swapped `write_addr=01` and
  `write_addr=10` write decode bug
- Regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS

## Known Issues

- Some older modules warn about missing explicit time units.

## Exact Next Action

Start Week 2 Day 2 by following the unified teaching and lab file
`docs/week2_day2_register_file_verification.md`. Deepen
`tb/tb_register_file4x4.v` verification with a golden model and scoreboard,
including distinct writes to all registers, all 16 read-address pairs, disabled
writes, overwrite, reset recovery, and same-address read/write timing. Use one
intentional RTL bug for first-failure and GTKWave debugging practice, then fix
it, rerun the focused test and regression, and document the observed timing
behavior.
