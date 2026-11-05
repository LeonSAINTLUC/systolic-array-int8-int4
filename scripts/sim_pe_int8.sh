#!/usr/bin/env bash
# Simulate the INT8 PE testbench with Verilator.
# Usage: scripts/sim_pe_int8.sh [extra Verilator options]
#   e.g. scripts/sim_pe_int8.sh --x-initial unique
#        scripts/sim_pe_int8.sh -GACC_W=23

mkdir -p build/pe_int8              # create build directory if it doesn't exist

set -e                              # stop at the first error
cd "$(dirname "$0")/.."             # run from the repository root

verilator --binary --timing --trace -Wall -Wno-fatal -j 0 \
          --top-module pe_int8_tb --Mdir build/pe_int8 \
          "$@" \
          rtl/pe_int8.sv tb/pe_int8_tb.sv

./build/pe_int8/Vpe_int8_tb