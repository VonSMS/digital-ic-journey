# Project Progress

Last updated: 2026-07-26

## Current Status

- Week 1: complete and regression-tested
- Current phase: Week 2
- Next module: 2-to-4 decoder, then a 4x4 register file
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

## Known Issues

- `docs/day7_alu.md` still describes opcodes `110/111` as invalid; RTL now uses
  them for NOT A and A+1.
- Some older modules warn about missing explicit time units.
- Daily summary files have uncommitted user edits; preserve them.

## Exact Next Action

Implement `rtl/decoder2to4.v` and an exhaustive self-checking testbench for all
`enable x select` combinations. Predict outputs first, then debug one swapped
one-hot output.

