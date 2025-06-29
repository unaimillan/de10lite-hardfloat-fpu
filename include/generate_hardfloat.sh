#!/bin/bash

> hardfloat.sv
cat hardfloat/HardFloat-1/source/RISCV/*.vi >> hardfloat.sv
cat hardfloat/HardFloat-1/source/RISCV/*.v  >> hardfloat.sv
cat hardfloat/HardFloat-1/source/*.vi       >> hardfloat.sv
cat hardfloat/HardFloat-1/source/*.v        >> hardfloat.sv
sed 's/^`include.*vi\"//' hardfloat.sv -i
sed 's/wire sqrtOpOut;//' hardfloat.sv -i
