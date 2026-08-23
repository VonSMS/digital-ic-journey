# Week 2 Hands-on Plan

This week starts after Week 1 is complete and regression-tested. Each day is
designed to fit one full Codex conversation: intuition, prediction, meaningful
RTL design work, self-checking testbench work, one useful failure, waveform
inspection, fix, regression, and a progress update.

## Goal

Build the missing bridge between isolated RTL blocks and a small processor-like
datapath: a decoder, 4x4 register file, controller FSM, and tiny execution unit.

Target data flow:

```text
write data -> 4x4 register file -> A/B -> 4-bit ALU -> result register
                         control -> IDLE/EXECUTE/DONE FSM
```

Aim for 10 to 14 focused hours across the week. Spend approximately 60% writing
RTL/testbenches, 20% debugging and reading waveforms, 15% theory, and 5%
documentation. Each day should introduce a concrete design structure whenever
possible, so learning comes from building and explaining signal flow rather than
only reading completed code.

## Daily Conversation Workflow

Each conversation should:

1. Read `AGENTS.md`, `docs/PROGRESS.md`, `git status`, and relevant RTL/tests.
2. Read or create the unified Markdown file for that day under `docs/`.
3. State the current progress, today's topic, and the first prediction task.
4. Teach intuition and signal flow before code.
5. Ask for predictions before simulation.
6. Let the learner write meaningful RTL or testbench sections before showing a
   complete solution.
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

- Short theory block: scoreboard timing and why the checker can be wrong.
- Strengthen the register file testbench without repeating Day 1.
- Add reset recovery and explicit same-address read/write timing checks.
- Debug one checker timing bug from the first failure.
- Rerun the register file test and regression.

## Day 3: Controller FSM and Result Register

- Build intuition: an FSM is stored control flow.
- Theory block: state, next state, output logic, Moore-style outputs, reset
  state, and why missing default assignments can create unintended behavior.
- Draw `IDLE -> EXECUTE -> DONE -> IDLE` before coding.
- Implement the controller with separate state register and combinational
  next-state/output logic.
- Implement a small 4-bit result register with enable/reset so the learner sees
  where execution results will be captured.
- Test reset, one-cycle start, held start, start while busy, and done duration.
- Include one sticky-output or missing-default bug and debug the first FAIL.
- Inspect state, next state, start, busy, done, result enable, result input, and
  result output in GTKWave.

## Day 4: Tiny Execution Unit

- Build intuition: datapath moves values, control decides when values move.
- Theory block: datapath versus control path, valid/done handshakes, result
  registers, flags, latency, and throughput.
- Connect the register file read ports to the existing ALU.
- Capture the ALU output and flags in a result register.
- Use the FSM to produce capture and done control.
- Let the learner wire key datapath/control signals rather than only inspect
  completed integration code.
- Run directed transactions including `7+1`, `F+1`, subtraction, and XOR.
- Include one intentional capture/control bug and debug from the first FAIL.
- Inspect one complete `start -> execute -> done` waveform.

## Day 5: Integration, Regression, and INT8 Handoff

- Theory block: module interfaces, system-level signal flow, boundary testing,
  and how the Week 2 datapath prepares for INT8 MAC hardware.
- Run every Week 1 and Week 2 testbench.
- Add or update `docs/week2_summary.md`.
- Add a simple datapath/control diagram.
- Explain which signals are datapath, control, state, and flags.
- Explain the execution unit without reading the RTL.
- Start the Week 3 bridge immediately: sketch the signed INT8 multiplier, MAC,
  and 2x2 matrix multiply dataflow; prepare Python golden vectors for multiplier
  and MAC tests.

## Week 2 Acceptance Criteria

- Every new module has a self-checking testbench and VCD output.
- Directed tests cover normal, boundary, reset, disabled-control, overwrite, and
  timing behavior as applicable.
- At least two intentional bugs are diagnosed from the first failure.
- The integrated unit completes at least four ALU transactions correctly.
- The learner can explain which signals are datapath, control, state, and flags.

## Six-Day INT8 Matrix Acceleration

Use `docs/int8_matrix_6_day_plan.md` as the source of truth for the accelerated
path from the current Week 2 Day 3 position to the first signed INT8 2x2 matrix
multiplication hardware module.

Summary:

1. Day 3: Controller FSM + result register.
2. Day 4: Tiny execution unit.
3. Day 5: Signed INT8 multiplier.
4. Day 6: INT8 MAC.
5. Day 7: Processing element + one 2x2 dot product.
6. Day 8: Integrated INT8 2x2 matrix multiply and regression.

After Day 8, deepen the matrix unit with control, reuse, signed edge cases,
larger tests, and AI-accelerator-style data movement.
