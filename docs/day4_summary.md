# Day 4 Summary

Date: 2026.7.19

## What I learned
1. Half adder theory: `sum = a ^ b`, `carry = a & b`
2. Full adder theory: adding `a + b + cin`
3. How `[1 ：0]` `[2 : 0]`, and bit indexing work
4. How `assign` represents continuously active combinational logic
5. How module ports connect signals, like `.sum(sum[0])`

## What I did
1. implemented half-adder rtl
2. implemented full-adder rtl
3. 2-bit ripple-carry adder using `fa0` and `fa1`
4. 3-bit ripple-carry adder using `fa0`, `fa1` and `fa2`
5. self-checking testbench loops for all input combinations of `a` `b` `cin`
```text
by changing loop condition to `i < 2^n` and expected sum width to `[n-1 : 0]` for a n-bit signal.
```