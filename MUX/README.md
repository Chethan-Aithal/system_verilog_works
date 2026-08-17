# MUX

A parameterized 2-to-1 multiplexer design in SystemVerilog.

## File Header

```text
// File name   : mux.sv
// Title       : MUX
// Project     : SystemVerilog Works
// Created     : 2026-08-17
// Description : A parameterized 2-to-1 multiplexer.
```

## Project Structure

```text
MUX/
├── mux.sv
├── mux_test.sv
└── README.md
```

- `mux.sv`: The RTL design file implementing the parameterized 2-to-1 multiplexer.
- `mux_test.sv`: The testbench file verifying the multiplexer functionality automatically.

## Working

The design is a parameterized 2-to-1 multiplexer. It uses a `unique case` statement inside an `always_comb` block to route either input `in_a` or `in_b` to the `out` port based on the select signal `sel_a`.

## Design

The main module `mux` includes a `WIDTH` parameter that defaults to 1. 

### Inputs
- `in_a`: The first input data bus of size `WIDTH`.
- `in_b`: The second input data bus of size `WIDTH`.
- `sel_a`: The single-bit select signal.

### Outputs
- `out`: The selected output data bus of size `WIDTH`.

### Internal Logic
When `sel_a` is `1'b1`, `out` receives `in_a`. When `sel_a` is `1'b0`, `out` receives `in_b`. Otherwise, the output is set to unknown (`'x`).

## Testbench

The testbench `mux_test.sv` instantiates the `mux` module with a `WIDTH` parameter set to 8.

- **Stimulus**: The testbench systematically applies different 8-bit values (all zeros `'0` and all ones `'1`) to the data inputs `in_a` and `in_b` alongside the combinations of `sel_a` (0 and 1).
- **Monitoring**: It uses `$monitor` and `$timeformat` to display the values and time.
- **Verification**: It defines a `task xpect` to automatically check if the output matches the expected result. If there is a mismatch, it displays "MUX TEST FAILED" and finishes simulation. If all tests pass, it prints "MUX TEST PASSED".

## Expected Result

The testbench is self-checking. When simulated, it should display "MUX TEST PASSED" as the final output message.

## Simulation Waveform

![Output Waveform](OUTPUT%20wavefrom.png)

## Schematics

### Elaborated Schematic

![Elaborated Schematic](Elaborated%20schematic.png)

### Synthesis Schematic

![Synthesis Schematic](Synthesis%20schematic.png)
