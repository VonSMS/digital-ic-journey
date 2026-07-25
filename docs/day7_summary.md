# Day 7 Summary

Date: 2026.7.25

## What I learned
1. ALU
core ALU functions include
```text
ADD, SUB, AND, OR, XOR, PASS A, invalid opcode handling
```
`multiply` and `divide` is done by shifting and adding.
2. Flags
I implemented and studied
```text
zero, carry, sub carry, overflow, negative
```
`sub carry`: 1 means no borrow, 0 means borrow
`overflow`: signed result cannot fit in the range -8 to +7
3. Verification
I conducted direcrt normal and boundary tests.
The self-checking bench uses:
A model to calculate expected outputs
apply_and_check to compare DUT and expected results
VCD generation for GTKWave
I traced how test values are shared:
```text
test_a → DUT input a
       → model input model_a
```
The model returns model_result through its task output argument into expected_result.
4. Debugging practice & Optional practice edits
I extended the opcode space with
```verilog
OP_NOT   = 110 → result = ~a
OP_APLUS = 111 → result = a + 1
```
and added the `negative` flag
```verilog
assign negative = result[3];
```
For exhastive verification, I created nested loops to test every ADD and SUB pair
```text
16 A values * 16 B values * 2 Operations = 512 tests
```
