# Project Progress

Last updated: 2026-08-26

## Current Status

- Week 1: complete and regression-tested
- Current phase: Week 2
- Week 2 plan: one full conversation per day, five focused conversation-days
- Week 2 warm-up: 2-to-4 decoder complete
- Week 2 Day 1: 4x4 register file complete
- Week 2 Day 2: register file verification depth complete
- Week 2 Day 5: signed INT8 multiplier complete
- Week 2 Day 6: signed INT8 MAC complete
- Week 2 Day 7: INT8 processing element complete
- Week 2 Day 8: signed INT8 2x2 matrix multiply integration complete
- Current conversation-day: Day 8 complete
- Next module: independent INT8 matrix path reproduction
- Accelerated target: complete first signed INT8 2x2 matrix multiply hardware by
  Day 8, then independently reproduce it on Day 9 using
  `docs/int8_matrix_6_day_plan.md`
- Week 2 milestone: register file + ALU + result register + controller FSM +
  tiny execution unit
- Week 3 milestone: signed INT8 multiplier + MAC + first 2x2 matrix multiply
  hardware

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

## Verified on 2026-08-07

- `tb_register_file4x4.v`: PASS with 116 checks after adding scoreboard timing,
  same-address read/write timing, and reset recovery tests.
- Intentional checker bug diagnosed: updating `expected_regs[2]` before the
  write clock edge caused the first failure to show `expected=1111 actual=1010`
  before the hardware had written the new value.
- Observed same-address timing: before the write edge, read port A saw old `r2`
  value `1010`; after the write edge plus a small delay, read port A saw new
  `r2` value `1111`.
- Regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS

## Verified on 2026-08-08

- Week 2 Day 3: controller FSM + result register complete.
- Implemented `rtl/controller_fsm.v` with `IDLE -> EXECUTE -> DONE -> IDLE`
  control flow, one-cycle `done`, `busy` in `EXECUTE`, and `capture_result` in
  `EXECUTE`.
- Implemented `rtl/result_register4.v` with reset and capture enable.
- Implemented `tb/tb_controller_fsm.v` with self-checking coverage for reset,
  one-cycle start, held start, start while busy, done duration, disabled
  capture, and result capture enable.
- Intentional checker bug diagnosed: compiling with
  `-DINTENTIONAL_CHECKER_BUG` expected the FSM to remain in `EXECUTE` too long;
  the first failure showed actual `state=10`, `done=1`, and `result_out=0010`,
  confirming the RTL had correctly reached `DONE`.
- Focused test:
  - `tb_controller_fsm.v`: PASS with 21 checks
- Regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS
  - `tb_controller_fsm.v`: PASS

## Verified on 2026-08-20

- Week 2 Day 4: tiny execution unit complete.
- Created unified teaching/lab file
  `docs/week2_day4_tiny_execution_unit.md` with intuition notes, prediction
  prompts, hands-on wiring tasks, debug exercise, commands, waveform checklist,
  explain-back prompt, and completion criteria.
- Implemented `rtl/tiny_execution_unit.v`, connecting the 4x4 register file,
  ALU, controller FSM, and result register.
- Implemented `tb/tb_tiny_execution_unit.v` with self-checking directed tests
  for reset, disabled writes, held start behavior, `7+1`, `A+1`, `F+1`,
  subtraction, XOR, result hold, and ALU-changing-without-capture behavior.
- Intentional RTL bug confirmed with `-DINTENTIONAL_TINY_CAPTURE_BUG`: the first
  failure showed the datapath result was already correct (`alu_result=8`) while
  `result_out` had not captured yet, pointing to the capture/control path.
- Fixed strict Verilog compatibility in `rtl/alu4.v` by making `negative` a wire
  output driven by its existing continuous assignment.
- Focused test:
  - `tb_tiny_execution_unit.v`: PASS with 23 checks
- Full regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS
  - `tb_controller_fsm.v`: PASS
  - `tb_tiny_execution_unit.v`: PASS

## Verified on 2026-08-21

- Week 2 Day 5: signed INT8 multiplier complete.
- Created unified teaching/lab file
  `docs/week2_day5_signed_int8_multiplier.md` with intuition notes, prediction
  prompts, hands-on signed RTL tasks, debug exercise, commands, waveform
  checklist, explain-back prompt, and completion criteria.
- Implemented `rtl/int8_multiplier.v` with signed INT8 inputs and a signed
  16-bit combinational product.
- Implemented `tb/tb_int8_multiplier.v` with self-checking directed tests,
  sampled signed cases, and exhaustive coverage for all 65536 signed INT8 input
  pairs.
- Intentional RTL bug confirmed with `-DINTENTIONAL_INT8_SIGN_BUG`: the first
  failure showed `a=-7`, `b=3`, `product=747`, and `expected=-21`, pointing to
  negative operands being interpreted as unsigned.
- Focused test:
  - `tb_int8_multiplier.v`: PASS with 65580 checks
- Full regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS
  - `tb_controller_fsm.v`: PASS
  - `tb_tiny_execution_unit.v`: PASS
  - `tb_int8_multiplier.v`: PASS

## Verified on 2026-08-23

- Week 2 Day 6: signed INT8 MAC complete.
- Created unified teaching/lab file `docs/week2_day6_int8_mac.md` with
  intuition notes, accumulator-width prediction prompts, hands-on RTL and
  testbench tasks, debug exercise, commands, waveform checklist, explain-back
  prompt, and completion criteria.
- Implemented `rtl/int8_mac.v` with signed INT8 inputs, signed 16-bit product,
  signed 18-bit accumulator, reset, clear, enable, hold behavior, and explicit
  sign extension from product to accumulator width.
- Implemented `tb/tb_int8_mac.v` with self-checking directed tests for reset,
  clear, disabled enable, positive accumulation, negative accumulation, mixed
  signs, and boundary products including repeated `-128 * -128` accumulation.
- Intentional RTL bug confirmed with `-DINTENTIONAL_MAC_EXTEND_BUG`: the first
  failure showed `product=-21` while `acc=65515` and `expected_acc=-21`,
  pointing to zero-extension of a negative product before accumulation.
- Focused test:
  - `tb_int8_mac.v`: PASS with 15 checks
- Full regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS
  - `tb_controller_fsm.v`: PASS
  - `tb_tiny_execution_unit.v`: PASS
  - `tb_int8_multiplier.v`: PASS
  - `tb_int8_mac.v`: PASS

## Verified on 2026-08-26

- Week 2 Day 7: INT8 processing element complete.
- Created unified teaching/lab file
  `docs/week2_day7_int8_processing_element.md` with intuition notes,
  prediction prompts, hands-on RTL and testbench tasks, an intentional
  clear/enable priority debug exercise, commands, waveform checklist,
  explain-back prompt, and completion criteria.
- Implemented `rtl/int8_processing_element.v` with signed INT8 inputs, signed
  16-bit product, signed 18-bit accumulator, reset, clear, enable, hold
  behavior, and explicit sign extension.
- Implemented `tb/tb_int8_processing_element.v` with self-checking tests for
  reset, disabled hold, normal accumulation, clear-before-dot-product,
  two-cycle dot products, mixed signs, and boundary products.
- Intentional RTL bug confirmed with `-DINTENTIONAL_PE_CLEAR_ENABLE_BUG`: the
  first failure showed `product=20` was correct while `acc=41` and
  `expected_acc=0`, pointing to clear/enable priority rather than multiplier
  arithmetic.
- Week 2 Day 8: signed INT8 2x2 matrix multiply integration complete.
- Created unified teaching/lab file `docs/week2_day8_int8_matmul2x2.md` with
  matrix-index intuition, prediction prompts, hands-on integration tasks,
  control-timing debug exercise, commands, waveform checklist, explain-back
  prompt, and completion criteria.
- Implemented `rtl/matmul2x2_int8.v` as a simple four-PE parallel matrix block
  with `IDLE -> CLEAR -> MAC0 -> MAC1 -> DONE -> IDLE` control flow.
- Implemented `tb/tb_matmul2x2_int8.v` with self-checking zero matrix, identity
  matrix, positive matrix, mixed-sign matrix, and boundary-value tests.
- Debugged a checker timing issue: the first matmul run produced correct
  `c00-c11` values but checked one cycle after `DONE`, so `done=0`; moving the
  check to the `DONE` cycle fixed the testbench.
- Focused tests:
  - `tb_int8_processing_element.v`: PASS with 18 checks
  - `tb_matmul2x2_int8.v`: PASS with 5 checks
- Full regression rerun:
  - `tb_simple_logic.v`: ran successfully
  - `tb_adders.v`: PASS
  - `tb_muxes.v`: PASS
  - `tb_sequential.v`: PASS
  - `tb_alu4.v`: PASS
  - `tb_decoder2to4.v`: PASS
  - `tb_register_file4x4.v`: PASS
  - `tb_controller_fsm.v`: PASS
  - `tb_tiny_execution_unit.v`: PASS
  - `tb_int8_multiplier.v`: PASS
  - `tb_int8_mac.v`: PASS
  - `tb_int8_processing_element.v`: PASS
  - `tb_matmul2x2_int8.v`: PASS

## Known Issues

- Some older modules warn about missing explicit time units.

## Exact Next Action

Start Day 9 by reading `docs/int8_matrix_6_day_plan.md`,
`docs/week2_day7_int8_processing_element.md`, and
`docs/week2_day8_int8_matmul2x2.md`, then create and follow one unified teaching
and lab file `docs/week2_day9_independent_int8_matmul_reproduction.md` for
independently reproducing the INT8 multiplier, MAC, processing element, and 2x2
matrix multiply path from understanding, with self-checking tests, one
self-found or intentional debug exercise, GTKWave inspection, focused tests, and
full regression.
