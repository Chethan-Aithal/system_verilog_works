# MUX

A configurable, purely combinational 2-to-1 multiplexer implemented in SystemVerilog. This design routes one of two $N$-bit input data buses to a single output bus based on a 1-bit select signal, utilizing synthesis-friendly SystemVerilog constructs.

## File Header

```text
// File name   : mux.sv
// Title       : MUX
// Project     : SystemVerilog Works
// Created     : 2026-08-17
// Description : A parameterized 2-to-1 multiplexer.
```

---

## Overview

Multiplexers are fundamental data-routing components in digital design. This project implements a scalable 2-to-1 multiplexer that can be instantiated with any data width, making it reusable across various datapaths, from simple single-bit logic to wide memory or register file buses. The design strictly adheres to combinational logic best practices, ensuring it synthesizes cleanly without latch inference.

---

## Features

- **Parameterized Data Width:** Easily configurable bus width via the `WIDTH` parameter.
- **Strictly Combinational:** Uses `always_comb` for robust combinational logic inference.
- **Synthesis Optimized:** Employs the `unique case` statement to inform synthesis tools that conditions are mutually exclusive, potentially improving logic optimization.
- **Self-Checking Verification:** Includes an automated testbench that applies stimulus and verifies expected results without manual waveform inspection.

---

## RTL Architecture

The architecture is a straightforward data selector. The single-bit select signal (`sel_a`) controls the data flow from either `in_a` or `in_b` to the `out` port.

```text
               ┌──────────────┐
               │              │
 in_a [WIDTH] ─┤1             │
               │     MUX      ├─ out [WIDTH]
 in_b [WIDTH] ─┤0             │
               │              │
               └──────┬───────┘
                      │
                    sel_a
```

---

## Interface

| Signal  | Direction | Width   | Description |
| ------- | --------- | :------ | ----------- |
| `in_a`  | Input     | `WIDTH` | First data input bus. Selected when `sel_a` is 1. |
| `in_b`  | Input     | `WIDTH` | Second data input bus. Selected when `sel_a` is 0. |
| `sel_a` | Input     | `1`     | Data select control signal. |
| `out`   | Output    | `WIDTH` | Selected data output bus. |

---

## RTL Implementation

The module `mux` is implemented using SystemVerilog's `always_comb` block, which accurately models combinational logic and automatically infers sensitivity lists. 

Inside the block, a `unique case` statement evaluates the `sel_a` control signal. The `unique` keyword explicitly directs the synthesis tool to treat the case items as mutually exclusive and complete, optimizing the resulting hardware by eliminating priority logic structures and preventing accidental latch generation. If an invalid or unknown state is encountered (e.g., in simulation), the `default` case assigns `'x` to the output, immediately highlighting X-propagation issues.

---

## Verification

The design includes a self-checking testbench (`mux_test.sv`) to ensure correct functional behavior.

### Testbench Architecture

```text
        Testbench (mux_test)
                 │
      ┌──────────┴──────────┐
      │                     │
  Stimulus               Checker
 (initial block)       (task xpect)
      │                     │
      └──────────┬──────────┘
                 ▼
          DUT (mux #8)
```

### Verification Strategy

The testbench sets the `WIDTH` parameter to 8 bits and applies a sequence of deterministic stimulus patterns. It tests:
- Passing all zeros (`'0`) through both data paths.
- Passing all ones (`'1`) through both data paths.
- Switching `sel_a` between 0 and 1 for each data combination.

A dedicated verification task (`xpect`) continuously monitors the output. If a mismatch between the expected and actual output is detected, the simulation halts immediately and reports a failure. If all vectors pass, a success message is printed.

### Simulation Results

The simulation accurately reflects the multiplexer selecting the correct input based on `sel_a`.

![Simulation Waveform](OUTPUT%20wavefrom.png)
*Waveform demonstrating `in_a` and `in_b` being routed to `out` according to the `sel_a` signal.*

---

## Synthesis Considerations

The design is fully synthesizable and maps efficiently to standard logic primitives (e.g., LUTs in FPGAs or standard cells in ASICs).

### Elaborated Schematic

The elaborated schematic confirms the mapping to a standard 2-to-1 RTL multiplexer primitive.

![Elaborated Schematic](Elaborated%20schematic.png)

### Synthesis Schematic

Post-synthesis, the logic is mapped directly to the target architecture's lookup tables (LUTs) or multiplexer primitives.

![Synthesis Schematic](Synthesis%20schematic.png)

---

## Simulation and Tools

The original project was developed and simulated using **Xilinx Vivado**. However, being standard SystemVerilog, it can be compiled and simulated using any standard EDA toolchain (e.g., Questa, Verilator, Icarus Verilog).

### How to Run (Icarus Verilog Example)

**Prerequisites:** Ensure Icarus Verilog (`iverilog`) is installed.

1. **Compile:**
   ```bash
   iverilog -g2012 -o sim.out mux.sv mux_test.sv
   ```
2. **Run Simulation:**
   ```bash
   vvp sim.out
   ```
   *Expected Output:*
   ```text
   ...
   MUX TEST PASSED
   ```

---

## Project Structure

```text
MUX/
├── mux.sv                  # Top-level RTL design
├── mux_test.sv             # Self-checking testbench
├── Elaborated schematic.png
├── OUTPUT wavefrom.png
├── Synthesis schematic.png
└── README.md               # This documentation
```

---

## Design Parameters

| Parameter | Default | Description |
| --------- | ------: | ----------- |
| `WIDTH`   |       1 | The bit-width of the data input and output buses. |

---

## Contributing

Contributions to improve the design or verification environment are welcome.

1. Fork the repository
2. Create a feature branch
3. Implement your changes (ensure all existing tests pass)
4. Commit your changes
5. Push to the branch
6. Open a Pull Request

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**
