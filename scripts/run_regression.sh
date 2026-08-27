#!/usr/bin/env bash
set -euo pipefail

mkdir -p sim

run_test() {
    local name="$1"
    shift

    echo "=== ${name}: compile ==="
    iverilog -Wall -o "sim/${name}.vvp" "$@"

    echo "=== ${name}: run ==="
    vvp "sim/${name}.vvp"
}

run_test tb_simple_logic \
    rtl/simple_logic.v \
    tb/tb_simple_logic.v

run_test tb_adders \
    rtl/half_adder.v \
    rtl/full_adder.v \
    tb/tb_adders.v

run_test tb_muxes \
    rtl/mux2.v \
    rtl/mux4.v \
    tb/tb_muxes.v

run_test tb_sequential \
    rtl/dff.v \
    rtl/register4.v \
    rtl/counter4.v \
    tb/tb_sequential.v

run_test tb_alu4 \
    rtl/alu4.v \
    tb/tb_alu4.v

run_test tb_decoder2to4 \
    rtl/decoder2to4.v \
    tb/tb_decoder2to4.v

run_test tb_register_file4x4 \
    rtl/decoder2to4.v \
    rtl/register_file4x4.v \
    tb/tb_register_file4x4.v

run_test tb_controller_fsm \
    rtl/controller_fsm.v \
    rtl/result_register4.v \
    tb/tb_controller_fsm.v

run_test tb_tiny_execution_unit \
    rtl/decoder2to4.v \
    rtl/register_file4x4.v \
    rtl/alu4.v \
    rtl/controller_fsm.v \
    rtl/result_register4.v \
    rtl/tiny_execution_unit.v \
    tb/tb_tiny_execution_unit.v

run_test tb_int8_multiplier \
    rtl/int8_multiplier.v \
    tb/tb_int8_multiplier.v

run_test tb_int8_mac \
    rtl/int8_mac.v \
    tb/tb_int8_mac.v

run_test tb_int8_processing_element \
    rtl/int8_processing_element.v \
    tb/tb_int8_processing_element.v

run_test tb_matmul2x2_int8 \
    rtl/int8_processing_element.v \
    rtl/matmul2x2_int8.v \
    tb/tb_matmul2x2_int8.v

echo "=== regression complete ==="
