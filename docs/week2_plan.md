# Week 2 Hands-on Plan

This week starts after Week 1 is complete and regression-tested. Each day is
designed to fit one full Codex conversation: intuition, prediction, small RTL
edits, self-checking testbench work, one useful failure, waveform inspection,
fix, regression, and a progress update.

## Goal

Build the missing bridge between isolated RTL blocks and a small processor-like
datapath: a decoder, 4x4 register file, controller FSM, and tiny execution unit.

Target data flow:

```text
write data -> 4x4 register file -> A/B -> 4-bit ALU -> result register
                         control -> IDLE/EXECUTE/DONE FSM
```

Aim for 10 to 14 focused hours across the week. Spend approximately 45% writing
RTL/testbenches, 25% debugging and reading waveforms, 20% theory, and 10%
documentation. Each day should include enough theory to explain why the circuit
exists, not only how to write the Verilog.

## Daily Conversation Workflow

Each conversation should:

1. Read `AGENTS.md`, `docs/PROGRESS.md`, `git status`, and relevant RTL/tests.
2. Read or create the unified Markdown file for that day under `docs/`.
3. State the current progress, today's topic, and the first prediction task.
4. Teach intuition and signal flow before code.
5. Ask for predictions before simulation.
6. Let the learner write or inspect small code sections.
7. Use a self-checking testbench and generate a VCD file.
8. Include one intentional bug when it teaches a useful debugging habit.
9. Let the learner read the first FAIL and inspect GTKWave before revealing the
   fix.
10. Run the relevant test and regression.
11. Update `docs/PROGRESS.md` with verified progress, known issues, and exactly
    one Exact Next Action.

Each day's unified Markdown file should contain the teaching notes, prediction
prompts, hands-on tasks, debug exercise, commands, waveform inspection checklist,
explain-back prompt, and completion criteria for that day.

## Day 1: Register File Foundations

- Theory block: review a single register, then extend it into an addressed
  storage bank. Emphasize the new ideas beyond Week 1: address decoding,
  synchronous write timing, combinational read timing, and two independent read
  ports.
- Build intuition: a register file is a tiny indexed storage bank, not just one
  register repeated four times.
- Connect to architecture: a CPU or accelerator reads operands from a register
  file before sending them to an ALU.
- Implement `rtl/register_file4x4.v` with four 4-bit registers.
- Use one synchronous write port and two combinational read ports.
- Predict reset, write enable off, overwrite, and two simultaneous reads.
- Create `tb/tb_register_file4x4.v`.
- Maintain `expected_regs[0:3]` in the testbench.
- Include one intentional write-address decode bug and debug the first FAIL.
- Inspect clock, reset, write enable, write address, write data, read addresses,
  read data, and stored register values in GTKWave.

## Day 2: Register File Verification Depth

- Theory block: golden models, scoreboards, directed tests versus exhaustive
  tests, and why verification often stores an independent expected state.
- Strengthen the register file testbench.
- Write distinct values to all four registers.
- Exhaustively read all 16 read-address pairs.
- Test disabled writes, overwrite, reset recovery, and read/write access to the
  same address.
- Document the observed read/write timing.
- Rerun the register file test and Week 1 regression.

## Day 3: Controller FSM

- Build intuition: an FSM is stored control flow.
- Theory block: state, next state, output logic, Moore-style outputs, reset
  state, and why missing default assignments can create unintended behavior.
- Draw `IDLE -> EXECUTE -> DONE -> IDLE` before coding.
- Implement the controller with separate state register and combinational
  next-state/output logic.
- Test reset, one-cycle start, held start, start while busy, and done duration.
- Include one sticky-output or missing-default bug and debug the first FAIL.
- Inspect state, next state, start, busy, and done in GTKWave.

## Day 4: Tiny Execution Unit

- Build intuition: datapath moves values, control decides when values move.
- Theory block: datapath versus control path, valid/done handshakes, result
  registers, flags, latency, and throughput.
- Connect the register file read ports to the existing ALU.
- Capture the ALU output and flags in a result register.
- Use the FSM to produce capture and done control.
- Run directed transactions including `7+1`, `F+1`, subtraction, and XOR.
- Include one intentional capture/control bug and debug from the first FAIL.
- Inspect one complete `start -> execute -> done` waveform.

## Day 5: Integration, Regression, and Handoff

- Theory block: module interfaces, system-level signal flow, boundary testing,
  and how the Week 2 datapath prepares for INT8 MAC hardware.
- Run every Week 1 and Week 2 testbench.
- Add or update `docs/week2_summary.md`.
- Add a simple datapath/control diagram.
- Explain which signals are datapath, control, state, and flags.
- Explain the execution unit without reading the RTL.
- Prepare Week 3 signed INT8 multiplication predictions and Python test vectors.

## Week 2 Acceptance Criteria

- Every new module has a self-checking testbench and VCD output.
- Directed tests cover normal, boundary, reset, disabled-control, overwrite, and
  timing behavior as applicable.
- At least two intentional bugs are diagnosed from the first failure.
- The integrated unit completes at least four ALU transactions correctly.
- The learner can explain which signals are datapath, control, state, and flags.

## Week 3 Start

Week 3 starts the INT8 project:

1. Signed 8x8 multiplier with a 16-bit product.
2. Multiply-accumulate unit with an explicitly sized accumulator.
3. Python golden vectors and automated comparison.

Week 4 extends the MAC into a processing element and then a 2x2 matrix
multiplication structure.
