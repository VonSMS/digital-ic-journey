# Day 5 Summary

Date: 2026.7.20

## What I learned
1. Multicomplexers and basic combinational blocks
2. How a 2-to-1 mux works using `assign y = sel ? b : a` and `sel = 0` selects `a`, `sel = 1` selects `b `
3. How to implement a 4-to-1 mux using `case`

## What I did
1. Compared a direct `mux4` and a hierarchical `mux4_from_mux2` (select inside a pair and then select the pair).
2. Used a self-checking testbench to compare actual outputs with expected outputs
3. Inspected mux behavior using gtkwave
4. Understood that when `5 + B = 0x10`, a [3:0] output only stores `0000`, so the waveform shows `0`(lower 4 bits).

## Improvements
More hands-on practices and more flexible applications.