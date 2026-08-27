# Project Summary: Digital IC Learning Journey

## Overview

This project is a hands-on digital IC learning portfolio implemented in
Verilog. It starts with basic gates and gradually builds toward a small signed
INT8 matrix-multiply accelerator. The work emphasizes understanding signal
flow, writing self-checking testbenches, debugging first failures, and inspecting
waveforms with GTKWave.

## Final Result

The final verified hardware path is a signed INT8 2x2 matrix multiply block:

```text
rtl/matmul2x2_int8.v
```

It uses four parallel processing elements. Each processing element performs:

```text
product = a * b
acc <= acc + sign_extend(product)
```

The top-level matrix unit computes:

```text
C00 = A00*B00 + A01*B10
C01 = A00*B01 + A01*B11
C10 = A10*B00 + A11*B10
C11 = A10*B01 + A11*B11
```

## Architecture Learned

- Combinational logic: gates, adders, muxes, decoder, ALU
- Sequential logic: DFF, register, counter, result register
- Datapath/control separation: register file, ALU, controller FSM, execution
  unit
- Signed arithmetic: signed INT8 multiplier and explicit sign extension
- Accumulation: signed 18-bit MAC and processing element
- Accelerator structure: four-PE parallel 2x2 matrix multiplication

## Verification Learned

- Self-checking testbenches using golden expected values
- Directed tests for normal and boundary cases
- Exhaustive signed INT8 multiplier coverage
- Clocked checks after the edge using small testbench delays
- VCD waveform generation with `$dumpfile` and `$dumpvars`
- Debugging by reading the first failure before changing RTL

## Key Debug Lessons

- Signedness matters: interpreting negative INT8 operands as unsigned produces
  wrong products.
- Width matters: negative products must be sign-extended before accumulating
  into a wider accumulator.
- Control priority matters: `clear` must beat `enable` before a new dot product.
- Handshake timing matters: `done` must rise only when final outputs are valid,
  not when the last operands are merely selected.
- Testbench timing matters: checking one cycle too early or too late can make
  correct data look wrong, or hide an invalid `done` signal.

## Representative Tests

Final focused command:

```sh
mkdir -p sim
iverilog -Wall -o sim/tb_matmul2x2_int8.vvp rtl/int8_processing_element.v rtl/matmul2x2_int8.v tb/tb_matmul2x2_int8.v
vvp sim/tb_matmul2x2_int8.vvp
```

Expected result:

```text
PASS: all matmul2x2_int8 tests passed with 5 checks
```

The full verified regression includes all earlier blocks:

- `tb_simple_logic.v`
- `tb_adders.v`
- `tb_muxes.v`
- `tb_sequential.v`
- `tb_alu4.v`
- `tb_decoder2to4.v`
- `tb_register_file4x4.v`
- `tb_controller_fsm.v`
- `tb_tiny_execution_unit.v`
- `tb_int8_multiplier.v`
- `tb_int8_mac.v`
- `tb_int8_processing_element.v`
- `tb_matmul2x2_int8.v`

## Portfolio Value

This repository demonstrates a practical beginner-to-accelerator path:

- Understanding fundamentals instead of only copying RTL
- Translating arithmetic equations into datapath and control
- Building layered modules with clear interfaces
- Verifying hardware behavior with independent expected models
- Explaining timing, state machines, accumulators, and valid/done behavior

## Suggested Next Extensions

- Add a clean independent reproduction implementation after the verified main
  path.
- Add synthesis reports with Yosys for the ALU, MAC, PE, and matmul blocks.
- Add a small scripted regression runner.
- Extend 2x2 matrix multiply to a parameterized or scheduled larger design.
- Compare the PE array to GPU/Tensor Core style matrix multiply concepts.
