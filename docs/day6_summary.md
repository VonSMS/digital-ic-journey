# Day 6 Summary

Date: 2026.7.22

## What I learned
1. Difference between combinational logic and sequential logic
```text
Combinational logic changes its input and output follows.
Sequential logic combines combinational logic and storage elements that keep the current state.
```
2. How D flip flop samples `d` (the next data) at `negedge` and update `q` at `posedge`
3. The difference between `posedge` and `negedge`
4. Synchronus reset and Asychronus reset
Synchronus
```verilog
always @(posedge clk)
```
Asychronus
```verilog
always @(posedge clk or posedge reset)
```
5. RTL patterns and data flow
The pattern is 
```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 1'b0 -> 1 digit binary 0.
    else
        q <= d
end
```
6. `<=` is the non-blocking assignment for clocked state. It models all registers sampling old values at the edge and updating together after the event.
   `=` is the blocking assignment, normally used for combinational logic procedual logic.
7. How 4-bit register works and how a 4-bit counter increments & wraps from 0000 to 1111.
8. How mux selects data before register stores it. 
9. The difference between `wire` and `reg` in a traditional Verilog
```text
Wire represents a connection driven by something else.
reg represents a variable assigned inside an always or initial block. (allows a procedual assignment)
```
10. How to ispect clock, reset, input, enable, state, and output in GTKWave.
