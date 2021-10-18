#!/bin/bash
echo "alu test bench run start!"
echo ""

# Navigate to reg-file module directory
cd ../memory_controller

# if any error happens exit
set -e

# clean
rm -rf address_map.vvp
rm -rf address_map_wavedata.vcd

# compiling
iverilog -o address_map.vvp address_map_tb.v

# run
vvp address_map.vvp

echo ""
echo "address-map test bench run stopped!"
