# Day2 Summary Notes

Date:2026.7.12

## What I did today

1. Convert Small numbers between decimal, binary and hexdecimal
2. Explain why hexdecimal is useful: long binary values becomes shorter and easier to read.
3. Interpret signed values using two's complement
4. build truth tables for AND, OR, XOR, NAND, NOR
5. Proof and simplify Boolean expressions using Venn diagrams
6. Creted `setup.sh` to eliminate absolute path tracking by using

```bash
export PROJ_ROOT=$(pwd)
export SIM_DIR=$PROJ_ROOT/sim
```
location:
```text
C:\Users\14138\Documents\IC_design_project_2026\digital-ic-journey
```

## My Problems and Solutions
1. Concept of two's complement
2. Fixed the path tracking logic of proj_root by decoupling the absolute path evaluation via localized shell parameters (`pwd`and`readlink`)