# Register

An 8-bit register with synchronous enable and asynchronous active-low reset.

## File Header

```text
// File name   : Register.sv
// Title       : Register
// Project     : SystemVerilog Works
// Created     : 2026-08-15
// Description : An 8-bit register with synchronous enable and asynchronous active-low reset.
```

## Project Structure

```text
Register/
├── Register.sv
├── register_tb.sv
└── README.md
```

- `Register.sv`: The RTL design file implementing the 8-bit register.
- `register_tb.sv`: The testbench file used to verify the register functionality.

## Working

The design implements an 8-bit storage register. It uses a clock edge to update its stored value when the enable signal is high. If the enable signal is low, it retains its previous state. An asynchronous active-low reset can clear the register output to zero immediately, independently of the clock.

## Design

The main module `register` has the following signals:

### Inputs
- `clk`: Clock signal controlling the sequential logic.
- `rst_`: Active-low asynchronous reset signal.
- `enable`: Synchronous enable signal. When high, the register can be updated.
- `data`: 8-bit input data.

### Outputs
- `out`: 8-bit output representing the stored value.

### Internal Logic
The design uses an `always_ff` block triggered on the positive edge of the clock or the negative edge of the reset. If `rst_` is low, the output is cleared to `8'h00`. Otherwise, on a clock edge, if `enable` is high, `out` is assigned the value of `data`.

## Testbench

The testbench `register_tb` instantiates the `register` module.

- **Clock generation**: A clock with a period of 10 ns is generated using an `always` block.
- **Stimulus**: The testbench applies different 8-bit values to the `data` input on the negative edge of the clock while `enable` is high. It also tests the asynchronous reset behavior by pulling `rst_` low in the middle of operation.
- **Monitoring**: It uses `$monitor` to display the values of time, reset, enable, data, and out whenever they change.
- **Simulation completion**: A `$finish` command stops the simulation after the final test steps.

## Expected Result

The `$monitor` output should show the register correctly capturing the input data on clock edges when enabled, and immediately clearing the output to `00` when `rst_` goes low.

## Simulation Waveform

![Output Waveform](Output%20waveform.png)

## Schematics

### Elaborated Schematic

![Elaborated Schematic](Register%20elaborated%20schematic.png)

### Synthesis Schematic

![Synthesis Schematic](Register%20synthsis%20schematic.png)
