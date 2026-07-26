# Week 2 Hands-on Plan

Dates: 2026-07-26 to 2026-08-01

## Goal

Build the missing bridge between isolated RTL blocks and a small processor-like
datapath: a decoder, 4x4 register file, controller FSM, and tiny execution unit.

Target data flow:

```text
write data -> 4x4 register file -> A/B -> 4-bit ALU -> result register
                         control -> IDLE/EXECUTE/DONE FSM
```

Aim for 12 to 15 hours. Spend approximately 60% writing RTL/testbenches, 25%
debugging and reading waveforms, and 15% on theory and documentation.

## Day 1: 2-to-4 Decoder

- Write the truth table before RTL.
- Implement enabled one-hot decoding.
- Exhaustively test all eight `enable x select` combinations.
- Introduce one swapped-output bug and explain the first FAIL.

## Day 2: 4x4 Register File RTL

- Implement four 4-bit registers.
- Use one synchronous write port and two combinational read ports.
- Predict values before and after each active clock edge.
- Test write disable, overwrite, reset, and two simultaneous reads.

## Day 3: Register File Verification

- Maintain `expected_regs[0:3]` in the testbench.
- Read every pair of addresses after writing distinct values.
- Test read/write access to the same address and document the observed timing.
- Inspect clock, reset, addresses, write enable, write data, and stored values in
  GTKWave.

## Day 4: Controller FSM

- Draw `IDLE -> EXECUTE -> DONE -> IDLE` before coding.
- Separate the state register from next-state/output combinational logic.
- Test reset, one-cycle start, held start, start while busy, and done duration.
- Introduce one missing-default or sticky-done bug and diagnose it.

## Day 5: FSM Verification and Cleanup

- Make the FSM testbench self-checking.
- Check outputs after clock edges rather than in the same event slot.
- Explain Moore-style outputs and why state is sequential.

## Day 6: Tiny Execution Unit

- Connect register file read ports to the existing ALU.
- Capture the ALU output and flags in a result register.
- Use the FSM to produce capture and done control.
- Run directed transactions including `7+1`, `F+1`, subtraction, and XOR.
- Inspect one complete `start -> execute -> done` waveform.

## Day 7: Regression and Handoff

- Run every Week 1 and Week 2 testbench.
- Update `docs/PROGRESS.md` and write `docs/week2_summary.md`.
- Add a datapath/control diagram.
- Explain the execution unit without reading the RTL.
- Prepare signed INT8 multiplication predictions and Python test vectors.

## Week 2 Acceptance Criteria

- Every new module has a self-checking testbench and VCD output.
- Directed tests cover normal, boundary, reset, and disabled-control cases.
- At least two intentional bugs are diagnosed from the first failure.
- The integrated unit completes at least four ALU transactions correctly.
- The learner can explain which signals are datapath, control, state, and flags.

## INT8 Start

Week 3, beginning 2026-08-02, starts the INT8 project:

1. Signed 8x8 multiplier with a 16-bit product.
2. Multiply-accumulate unit with an explicitly sized accumulator.
3. Python golden vectors and automated comparison.

Week 4 extends the MAC into a processing element and then a 2x2 matrix
multiplication structure.

