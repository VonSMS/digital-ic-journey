# Seven-Day Plan: First INT8 2x2 Matrix Multiply Hardware + Reproduction

Date: 2026-08-07

## Goal

Complete a first working, simulated INT8 2x2 matrix multiplication hardware path
in six focused learning days, starting from the current Week 2 Day 3 position,
then use Day 9 to independently reproduce the design for retention.

The priority is hands-on design:

- Write meaningful RTL every day.
- Write or extend self-checking testbenches every day.
- Keep theory short and directly tied to the structure being built.
- Use one intentional bug when it teaches a real hardware or verification habit.
- End each day with a passing focused test, regression, and one exact next
  action.

## Target Hardware Path

```text
Day 3-4: 4-bit execution unit practice
Day 5-8: signed INT8 multiplier -> MAC -> processing element -> 2x2 matmul
Day 9: independent reproduction from memory, with tests and waveform review
```

Final target:

```text
A[0][0] A[0][1]   B[0][0] B[0][1]     C[0][0] C[0][1]
A[1][0] A[1][1] x B[1][0] B[1][1]  =  C[1][0] C[1][1]
```

Each output is:

```text
C[i][j] = A[i][0] * B[0][j] + A[i][1] * B[1][j]
```

For signed INT8 inputs:

```text
input range:   -128 to 127
product range: -16384 to 16384
sum range:     needs more than 16 bits for safety
```

Use an explicitly sized accumulator, normally at least signed 18 bits for a
two-product dot product.

## Day 3: Controller FSM + Result Register

Design structures:

- `rtl/controller_fsm.v`
- `rtl/result_register4.v`
- `tb/tb_controller_fsm.v`

Learning focus:

- FSM as stored control flow.
- Separate state register from combinational next-state/output logic.
- Result register as controlled storage.

Hands-on requirements:

- Learner writes the state encoding and one combinational transition block.
- Learner writes or completes the result register always block.
- Test reset, one-cycle start, held start, start while busy, done duration, and
  result capture enable.

Exit criteria:

- Focused controller/result-register tests pass.
- Waveform shows `IDLE -> EXECUTE -> DONE -> IDLE`.

## Day 4: Tiny Execution Unit

Design structures:

- `rtl/tiny_execution_unit.v`
- `tb/tb_tiny_execution_unit.v`

Learning focus:

- Datapath versus control path.
- Register file read ports feeding ALU operands.
- FSM capture enable storing ALU result and flags.

Hands-on requirements:

- Learner wires key datapath signals: register file reads, ALU inputs, result
  register input, and capture enable.
- Run directed operations: `7+1`, `F+1`, subtraction, XOR, and one reset case.
- Debug one intentional capture/control bug.

Exit criteria:

- Tiny execution unit completes at least four directed transactions.
- Waveform shows one complete `start -> execute -> done` transaction.

## Day 5: Signed INT8 Multiplier

Design structures:

- `rtl/int8_multiplier.v`
- `tb/tb_int8_multiplier.v`
- optional `scripts/int8_vectors.py`

Learning focus:

- Signed declarations in Verilog.
- Why `8x8 -> 16-bit product`.
- Boundary cases: `127`, `-128`, `-1`, `0`, sign combinations.

Hands-on requirements:

- Learner writes the signed module interface and product assignment.
- Learner writes several directed signed test cases before automated vectors.
- Add Python-generated or testbench-generated expected products.

Exit criteria:

- Directed and sampled signed multiplier tests pass.
- Waveform confirms negative operands and signed products.

## Day 6: INT8 MAC

Design structures:

- `rtl/int8_mac.v`
- `tb/tb_int8_mac.v`

Learning focus:

- Multiply-accumulate datapath.
- Accumulator width and signed extension.
- Clear, enable, and accumulation timing.

Hands-on requirements:

- Learner chooses accumulator width after calculating worst-case two-product and
  multi-cycle ranges.
- Learner writes the accumulator update logic.
- Test clear, disabled enable, positive accumulation, negative accumulation,
  mixed signs, and boundary products.

Exit criteria:

- MAC tests pass with explicit signed expected values.
- Waveform shows product and accumulator timing clearly.

## Day 7: Processing Element + 2x2 Dot Product

Design structures:

- `rtl/int8_processing_element.v`
- `tb/tb_int8_processing_element.v`
- begin `rtl/matmul2x2_int8.v`

Learning focus:

- A processing element as multiplier plus accumulator plus control.
- Two-product dot product for one matrix output.
- Clear before a new dot product, then accumulate two products.

Hands-on requirements:

- Learner wires multiplier output into accumulator path.
- Test one output element such as `C00 = A00*B00 + A01*B10`.
- Start the top-level 2x2 matmul interface.

Exit criteria:

- Processing element passes dot-product tests.
- One matrix output can be computed correctly.

## Day 8: 2x2 Matrix Multiply Integration

Design structures:

- finish `rtl/matmul2x2_int8.v`
- `tb/tb_matmul2x2_int8.v`

Learning focus:

- Mapping matrix indices into hardware signals.
- Parallel versus scheduled computation.
- Valid/done behavior for a small multi-output block.

Hands-on requirements:

- Learner writes the four output equations or the schedule that computes them.
- Test identity matrix, zero matrix, positive matrix, mixed signs, and boundary
  values.
- Run full regression and inspect one waveform end to end.

Exit criteria:

- First INT8 2x2 matrix multiplication hardware module passes self-checking
  tests.
- Documentation records the chosen architecture and known limitations.

## Day 9: Independent Reproduction

Design structures:

- learner-created reproduction files, either in a clearly named scratch area or
  as a clean second implementation chosen at the start of Day 9
- self-checking reproduction testbenches for the rebuilt blocks

Learning focus:

- Rebuild the key design path from understanding, not by copy/paste.
- Explain each module boundary, control signal, datapath signal, and timing
  point before using the previous solution as a reference.
- Practice finding compile errors, first simulation failures, and waveform
  mismatches independently.

Hands-on requirements:

- Learner writes the controller, result register, INT8 multiplier, MAC, PE, and
  2x2 matmul integration again from memory or from a blank scaffold.
- Learner writes or completes self-checking tests before comparing against the
  previous known-good files.
- Use GTKWave to inspect one full matrix multiply transaction end to end.
- Only after the first independent attempt, compare against the original
  implementation and record differences.

Exit criteria:

- Reproduced design compiles and passes focused tests.
- At least one self-found bug is documented with the first failure and fix.
- Learner can explain the full signal flow:
  `inputs -> multiplier -> accumulator -> result outputs`, and the control flow
  that makes it happen.

## Acceleration Rules

- Keep each day's theory to the minimum needed to write the next code block.
- Prefer directed tests first, then add sampled or exhaustive tests where the
  input space is small enough.
- Do not overbuild control before the datapath is correct.
- Use clear, explicit signed widths instead of clever compact expressions.
- Favor a working, understandable first matrix unit over a highly optimized one.
