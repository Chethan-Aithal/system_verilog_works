# Register

An 8-bit synchronous register with clock enable and asynchronous active-low reset implemented in SystemVerilog.

## File Header

```text
// File name   : Register.sv
// Title       : Register
// Project     : SystemVerilog Works
// Created     : 2026-08-15
// Description : An 8-bit register with synchronous enable and asynchronous active-low reset.
```

---

## Overview

Registers are the foundational sequential storage units in digital circuits and CPU datapaths. This project implements an 8-bit storage register that captures input data on the rising edge of the clock when enabled. If the enable signal is deasserted, the register securely holds its current value. An active-low asynchronous reset immediately clears the output to zero independently of the clock.

---

## Features

- **8-Bit Data Storage:** Byte-wide storage register.
- **Synchronous Clock Enable:** Controls data latching on rising clock edges.
- **Asynchronous Active-Low Reset:** Clears register contents immediately regardless of clock state.
- **Dual Testbench Suite:**
  - `register_tb.sv`: Directed functional verification with `$monitor`.
  - `register_tb2.sv`: Self-checking automated testbench with golden-vector comparisons and timeout guard.

---

## Project Structure

```text
Register/
├── Register.sv                      # RTL design file
├── register_tb.sv                   # Baseline functional testbench
├── register_tb2.sv                  # Automated self-checking testbench
├── Output waveform.png              # Baseline simulation waveform
├── Output waveform of tb2.png       # Testbench 2 timing waveform
├── console output tb2.png           # Testbench 2 pass confirmation console log
├── Register elaborated schematic.png# Elaborated RTL schematic
├── Register synthsis schematic.png  # Synthesized gate-level schematic
└── README.md                        # Project documentation
```

---

## Design & Interface

### Port List

| Port | Direction | Width | Type | Description |
| :--- | :---: | :---: | :--- | :--- |
| `clk` | Input | 1 | `logic` | Master clock signal (positive edge-triggered) |
| `rst_` | Input | 1 | `logic` | Asynchronous active-low reset signal |
| `enable` | Input | 1 | `logic` | Synchronous register load enable |
| `data` | Input | 8 | `logic` | 8-bit input data bus |
| `out` | Output | 8 | `logic` | 8-bit registered data output bus |

### RTL Implementation

The register uses an `always_ff` block with an asynchronous reset sensitivity list (`@(posedge clk or negedge rst_)`). When `!rst_` is active, `out` is cleared to `8'h00`. On each rising clock edge, if `enable` is high, `data` is latched to `out`; otherwise, the register retains its current value.

```systemverilog
module register(
    input  logic [7:0] data,
    input  logic clk, rst_, enable,
    output logic [7:0] out
);
    always_ff @(posedge clk or negedge rst_) begin
        if (~rst_)
            out <= 8'h00;
        else begin
            if (enable)
                out <= data;
            else
                out <= out;
        end
    end
endmodule
```

---

## Verification

### 1. Directed Testbench (`register_tb.sv`)

Exercises the register with basic directed stimulus:
- Applies `8'hFF`, `8'hXX`, and asynchronous reset assertion (`rst_ = 0`) on negative clock edges.
- Uses continuous `$monitor` to log signals as they transition.

### 2. Self-Checking Automated Testbench (`register_tb2.sv`)

A comprehensive verification environment providing automated error detection and bounded simulation timing:

- **Clock Definition:** Configurable 10 ns clock period (`#5 clk = ~clk`).
- **Timeout Watchdog:** Prevents infinite simulation hangs via `#('PERIOD * 99)` timeout guard.
- **Self-Checking Task (`expect_test`):** Compares `out` directly against expected golden values. On mismatch, prints expected vs. actual values and aborts simulation with `$finish`.
- **Systematic Test Scenarios:**
  1. *Reset Check:* Asserts `rst_ = 0` with unknown inputs to prove reset overrides input data and clears `out` to `8'h00`.
  2. *Hold Check:* Deasserts `enable` (`enable = 0`) to confirm the register holds `8'h00`.
  3. *Load Check (Pattern `8'hAA`):* Asserts `enable = 1` and inputs `8'hAA`, verifying output updates to `8'hAA`.
  4. *Hold After Load:* Changes input data while `enable = 0`, verifying `out` maintains `8'hAA`.
  5. *Mid-Operation Async Reset:* Re-asserts `rst_ = 0` during active operation to confirm immediate clearing.
  6. *Load Check (Pattern `8'h55`):* Asserts `enable = 1` and inputs `8'h55`, verifying output updates to `8'h55`.
  7. *Hold After Load:* Confirms retention of `8'h55` when `enable = 0`.
  8. *Completion:* Displays `"REGISTER TEST PASSED"` upon all assertions succeeding.

---

## Simulation Results

### Self-Checking Testbench 2 Waveform

![Output Waveform of tb2](Output%20waveform%20of%20tb2.png)

### Testbench 2 Console Output

All test vectors passed without discrepancies, concluding with verification confirmation:

![Console Output tb2](console%20output%20tb2.png)

### Baseline Simulation Waveform

![Output Waveform](Output%20waveform.png)

---

## Schematics

### Elaborated RTL Schematic

![Elaborated Schematic](Register%20elaborated%20schematic.png)

### Synthesized Gate-Level Schematic

![Synthesis Schematic](Register%20synthsis%20schematic.png)

---

## How to Run Simulation

### Running Testbench 2 (Self-Checking)

```bash
# Compile and run with Icarus Verilog
iverilog -g2012 -o reg_tb2.out Register.sv register_tb2.sv
vvp reg_tb2.out
```

### Running Testbench 1 (Directed)

```bash
# Compile and run with Icarus Verilog
iverilog -g2012 -o reg_tb1.out Register.sv register_tb.sv
vvp reg_tb1.out
```

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**
