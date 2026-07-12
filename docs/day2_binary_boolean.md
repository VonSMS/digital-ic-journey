# Day 2 Binary Numbers and Boolean Logic

Date: 2026-07-12

## Goal

Understand how hardware represents numbers and logic using only 0 and 1.

By the end of Day 2, I should be able to:

1. Convert small numbers between decimal, binary, and hexadecimal.
2. Explain why hexadecimal is convenient for hardware work.
3. Interpret signed values using two's complement.
4. Build truth tables for basic logic gates.
5. Simplify small Boolean expressions.

## 1. Bits and Binary Numbers

A bit is one binary digit. It can only be:

```text
0 or 1
```

Digital hardware uses bits because transistors naturally create two stable states, often treated as low voltage and high voltage.

A binary number uses powers of 2:

```text
Binary:  1 0 1 1
Place:   8 4 2 1
Value:   8 + 0 + 2 + 1 = 11
```

So:

```text
1011_2 = 11_10
```

The subscript `_2` means binary. The subscript `_10` means decimal.

### Common 4-bit Values

| Binary | Decimal |
| --- | ---: |
| 0000 | 0 |
| 0001 | 1 |
| 0010 | 2 |
| 0011 | 3 |
| 0100 | 4 |
| 0101 | 5 |
| 0110 | 6 |
| 0111 | 7 |
| 1000 | 8 |
| 1001 | 9 |
| 1010 | 10 |
| 1011 | 11 |
| 1100 | 12 |
| 1101 | 13 |
| 1110 | 14 |
| 1111 | 15 |

## 2. Hexadecimal Numbers

Hexadecimal, or hex, is base 16. One hex digit represents exactly 4 bits.

| Hex | Binary | Decimal |
| --- | --- | ---: |
| 0 | 0000 | 0 |
| 1 | 0001 | 1 |
| 2 | 0010 | 2 |
| 3 | 0011 | 3 |
| 4 | 0100 | 4 |
| 5 | 0101 | 5 |
| 6 | 0110 | 6 |
| 7 | 0111 | 7 |
| 8 | 1000 | 8 |
| 9 | 1001 | 9 |
| A | 1010 | 10 |
| B | 1011 | 11 |
| C | 1100 | 12 |
| D | 1101 | 13 |
| E | 1110 | 14 |
| F | 1111 | 15 |

Example:

```text
0x2F = 0010 1111_2
     = 2 * 16 + 15
     = 47_10
```

Hex is useful because long binary values become shorter and easier to read:

```text
1111 0000 1010 0101_2 = 0xF0A5
```

## 3. Unsigned Integers

An unsigned integer cannot represent negative numbers.

For `N` bits:

```text
minimum = 0
maximum = 2^N - 1
```

Examples:

| Width | Minimum | Maximum |
| ---: | ---: | ---: |
| 4 bits | 0 | 15 |
| 8 bits | 0 | 255 |
| 16 bits | 0 | 65535 |
| 32 bits | 0 | 4294967295 |

## 4. Two's Complement Signed Integers

Two's complement is the standard way hardware represents signed integers.

For `N` bits:

```text
minimum = -2^(N-1)
maximum =  2^(N-1) - 1
```

Examples:

| Width | Minimum | Maximum |
| ---: | ---: | ---: |
| 4 bits | -8 | 7 |
| 8 bits | -128 | 127 |
| 16 bits | -32768 | 32767 |

In two's complement, the most significant bit is the sign bit:

```text
0 means non-negative
1 means negative
```

### How to Find the Negative Value

To compute `-x` in two's complement:

1. Write `x` in binary.
2. Invert every bit.
3. Add 1.

Example: represent `-5` in 4 bits.

```text
+5       = 0101
invert   = 1010
add 1    = 1011

-5       = 1011
```

Check using place values:

```text
1011_2 as 4-bit signed = -8 + 0 + 2 + 1 = -5
```

### Important Pattern

For 4-bit signed numbers:

| Binary | Signed Decimal |
| --- | ---: |
| 0000 | 0 |
| 0001 | 1 |
| 0010 | 2 |
| 0011 | 3 |
| 0100 | 4 |
| 0101 | 5 |
| 0110 | 6 |
| 0111 | 7 |
| 1000 | -8 |
| 1001 | -7 |
| 1010 | -6 |
| 1011 | -5 |
| 1100 | -4 |
| 1101 | -3 |
| 1110 | -2 |
| 1111 | -1 |

## 5. Boolean Algebra

Boolean algebra works with values that are only true or false.

In digital hardware:

```text
false = 0
true  = 1
```

Common Boolean operators:

| Operator | Hardware Name | Meaning |
| --- | --- | --- |
| `~A` | NOT | Invert A |
| `A & B` | AND | 1 only if both inputs are 1 |
| `A \| B` | OR | 1 if at least one input is 1 |
| `A ^ B` | XOR | 1 if inputs are different |

In Verilog, these same symbols are often used for bitwise logic:

```verilog
assign y_not = ~a;
assign y_and = a & b;
assign y_or  = a | b;
assign y_xor = a ^ b;
```

## 6. Logic Gates and Truth Tables

A truth table lists every possible input combination and the output.

### NOT

| A | Y = ~A |
| --- | --- |
| 0 | 1 |
| 1 | 0 |

### AND

| A | B | Y = A & B |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

### OR

| A | B | Y = A \| B |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

### XOR

| A | B | Y = A ^ B |
| --- | --- | --- |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

XOR is very important for adders because it produces the sum bit for one-bit addition without carry:

```text
0 + 0 -> 0
0 + 1 -> 1
1 + 0 -> 1
1 + 1 -> 0 with carry 1
```

### NAND

NAND means NOT AND.

| A | B | Y = ~(A & B) |
| --- | --- | --- |
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### NOR

NOR means NOT OR.

| A | B | Y = ~(A \| B) |
| --- | --- | --- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

## 7. Useful Boolean Laws

| Law | Expression |
| --- | --- |
| Identity | `A & 1 = A`, `A \| 0 = A` |
| Null | `A & 0 = 0`, `A \| 1 = 1` |
| Idempotent | `A & A = A`, `A \| A = A` |
| Complement | `A & ~A = 0`, `A \| ~A = 1` |
| Double negation | `~~A = A` |
| Commutative | `A & B = B & A`, `A \| B = B \| A` |
| Associative | `(A & B) & C = A & (B & C)` |
| Distributive | `A & (B \| C) = (A & B) \| (A & C)` |
| De Morgan | `~(A & B) = ~A \| ~B` |
| De Morgan | `~(A \| B) = ~A & ~B` |

## 8. Boolean Simplification Examples

Example 1:

```text
Y = A & 1
Y = A
```

Example 2:

```text
Y = A | (A & B)
Y = A
```

Reason:

If `A = 1`, output is already 1.
If `A = 0`, both terms are 0.

Example 3:

```text
Y = ~(A & B)
Y = ~A | ~B
```

This is De Morgan's law.

## 9. Exercises

### Binary and Hex

Convert to decimal:

1. `1010_2`
2. `1111_2`
3. `10000_2`
4. `0x1C`
5. `0xA5`

Convert to binary:

1. `13_10`
2. `31_10`
3. `0x3F`
4. `0x80`
5. `0xDE`

### Two's Complement

Assume 4-bit signed two's complement. Convert to decimal:

1. `0110`
2. `1000`
3. `1011`
4. `1111`

Assume 8-bit signed two's complement. Convert to binary:

1. `+12`
2. `-1`
3. `-5`
4. `-128`

### Truth Tables

Fill in the output columns:

| A | B | AND | OR | XOR | NAND | NOR |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 |   |   |   |   |   |
| 0 | 1 |   |   |   |   |   |
| 1 | 0 |   |   |   |   |   |
| 1 | 1 |   |   |   |   |   |

### Boolean Simplification

Simplify:

1. `A & 0`
2. `A | 1`
3. `A & A`
4. `A | A`
5. `A & ~A`
6. `A | ~A`
7. `~~A`
8. `A | (A & B)`
9. `A & (A | B)`
10. `~(A | B)`

## 10. Answers

### Binary and Hex Answers

Convert to decimal:

1. `1010_2 = 10`
2. `1111_2 = 15`
3. `10000_2 = 16`
4. `0x1C = 28`
5. `0xA5 = 165`

Convert to binary:

1. `13_10 = 1101_2`
2. `31_10 = 11111_2`
3. `0x3F = 0011 1111_2`
4. `0x80 = 1000 0000_2`
5. `0xDE = 1101 1110_2`

### Two's Complement Answers

4-bit signed:

1. `0110 = 6`
2. `1000 = -8`
3. `1011 = -5`
4. `1111 = -1`

8-bit signed:

1. `+12 = 0000 1100`
2. `-1 = 1111 1111`
3. `-5 = 1111 1011`
4. `-128 = 1000 0000`

### Truth Table Answers

| A | B | AND | OR | XOR | NAND | NOR |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 | 1 | 1 | 0 |
| 1 | 1 | 1 | 1 | 0 | 0 | 0 |

### Boolean Simplification Answers

1. `A & 0 = 0`
2. `A | 1 = 1`
3. `A & A = A`
4. `A | A = A`
5. `A & ~A = 0`
6. `A | ~A = 1`
7. `~~A = A`
8. `A | (A & B) = A`
9. `A & (A | B) = A`
10. `~(A | B) = ~A & ~B`

## Day 2 Summary

Digital hardware represents information with bits. Binary is the natural number system for hardware, while hexadecimal is a compact way to write groups of 4 bits. Two's complement lets the same adders work for both positive and negative signed integers. Boolean algebra describes how logic gates transform bits, and truth tables give a complete behavioral definition for small circuits.
