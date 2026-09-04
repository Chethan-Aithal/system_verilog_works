# ALU

An 8-bit Arithmetic Logic Unit (ALU) implemented in SystemVerilog, featuring eight parameterized opcodes covering arithmetic, bitwise, data movement, and flow-control operations. The design uses a clocked datapath triggered on the negative clock edge and a purely combinational zero-flag generator.

## File Header

```text
// File name   : ALU.sv
// Title       : ALU
// Project     : SystemVerilog Works
// Created     : 2026-09-03
// Description : An 8-bit Arithmetic Logic Unit (ALU) with eight parameterized opcodes, negedge-clocked datapath, and combinational zero flag.
```

---

## Overview

This ALU is modelled after the execution unit of a simple 8-bit processor. It accepts an 8-bit accumulator value, an 8-bit data operand, and a 3-bit opcode, then produces an 8-bit result registered on the falling clock edge. The zero flag is computed combinationally and reflects the accumulator state continuously. The opcode encoding directly mirrors common instruction sets used in educational CPU designs, making this a practical component for integrating into a larger processor datapath.

---

## Features

- **8 parameterized opcodes** covering HLT, SKZ, ADD, AND, XOR, LDA, STO, JMP operations.
- **Registered output** on the negative edge of the clock — suitable for pipeline stage integration.
- **Combinational zero flag** derived directly from the accumulator, independent of the clock.
- **Default case** prevents latch inference and handles undefined opcodes.
- **Fully parameterized opcodes** — opcode encodings can be overridden at instantiation.

---

## RTL Architecture

```text
         ┌──────────────────────────────────────┐
         │              ALU Module              │
         │                                      │
data[7:0]│──────────────────────────────────────┤
         │         always_ff (negedge clk)      │
accum[7:0│──┬───────────────────────────────────┤──► out[7:0]
         │  │    case(opcode)                   │
opcode[2:│──┤     ADD → data + accum            │
         │  │     AND → data & accum            │
clk      │──┘     XOR → data ^ accum            │
         │         LDA → data                   │
         │         STO/HLT/SKZ/JMP → accum      │
         │                                      │
         │  always_comb                         │
accum[7:0│──────────────────────────────────────┤──► zero
         │   zero = (accum == 8'h00)            │
         └──────────────────────────────────────┘
```

---

## Interface

| Signal      | Direction | Width | Description |
| ----------- | --------- | :---- | ----------- |
| `clk`       | Input     | 1     | Clock — output registers on the **negative** edge. |
| `opcode`    | Input     | 3     | Operation select. Encoded via parameters. |
| `data`      | Input     | 8     | Second operand from the data bus / memory. |
| `accum`     | Input     | 8     | Accumulator value — primary operand. |
| `out`       | Output    | 8     | Registered ALU result. |
| `zero`      | Output    | 1     | Combinational flag — high when `accum == 8'h00`. |

---

## Opcode Encoding

| Parameter | Encoding | Operation | Result (`out`) |
| --------- | :------: | --------- | -------------- |
| `HLT`     | `3'b000` | Halt      | `accum` (passthrough) |
| `SKZ`     | `3'b001` | Skip if Zero | `accum` (passthrough) |
| `ADD`     | `3'b010` | Add       | `data + accum` |
| `AND`     | `3'b011` | Bitwise AND | `data & accum` |
| `XOR`     | `3'b100` | Bitwise XOR | `data ^ accum` |
| `LDA`     | `3'b101` | Load Accumulator | `data` |
| `STO`     | `3'b110` | Store     | `accum` (passthrough) |
| `JMP`     | `3'b111` | Jump      | `accum` (passthrough) |

---

## RTL Implementation

The design uses two separate always blocks to cleanly separate concerns:

**Sequential datapath** (`always_ff @(negedge clk)`): A `case` statement selects the operation from the opcode. Non-blocking assignments (`<=`) drive the registered `out` output. Triggering on `negedge clk` is intentional, as is common in designs where the falling edge is used for ALU result capture while the rising edge handles control flow.

**Combinational zero flag** (`always_comb`): The `zero` flag is derived purely from the accumulator input with no clock dependency, making it immediately available to upstream control logic — for example, to evaluate the `SKZ` condition before the next clock edge.

---

## Verification

### Testbench Architecture

The testbench `alu_tb` instantiates the `ALU` DUT with default opcode parameters. It generates a 10 ns clock and systematically applies all eight opcodes using a mix of fixed time delays and `@(negedge clk)` synchronization points.

```text
         alu_tb
            │
     ┌──────┴──────┐
     │             │
 Clock Gen      Stimulus
 always #5      (initial block)
     │             │
     └──────┬──────┘
            ▼
        DUT (ALU)
```

### Verification Strategy

The testbench applies fixed operands (`data = 8'h12`, `accum = 8'h34`) across all eight opcodes and observes the registered `out` and combinational `zero` outputs. A final test case sets `accum = 8'h00` and applies the `SKZ` opcode to specifically exercise the zero-flag path.

### Simulation Results

The waveform demonstrates all opcodes firing sequentially and the `out` register updating correctly on each negative clock edge.

![ALU Output Waveform](ALU%20output%20waveform.png)
*All eight opcodes exercised with fixed operands. The `zero` flag transitions when `accum` is set to `8'h00`.*

---

## Synthesis Considerations

The design is fully synthesizable. The use of `always_ff` ensures the synthesis tool correctly infers negative-edge-triggered flip-flops for `out`, while `always_comb` produces purely combinational logic for `zero`.

### Elaborated Schematic

![Elaborated Schematic](Elaborated%20schematic.png)

### Synthesized Design

![Synthesized Design](Synthesized%20Design.png)

---

## Project Structure

```text
ALU/
├── ALU.sv                   # Top-level RTL design
├── alu_tb.sv                # Functional verification testbench
├── ALU output waveform.png
├── Elaborated schematic.png
├── Synthesized Design.png
└── README.md
```

---

## Design Parameters

| Parameter | Default  | Description |
| --------- | :------: | ----------- |
| `HLT`     | `3'b000` | Halt opcode encoding |
| `SKZ`     | `3'b001` | Skip-if-Zero opcode encoding |
| `ADD`     | `3'b010` | Add opcode encoding |
| `AND`     | `3'b011` | Bitwise AND opcode encoding |
| `XOR`     | `3'b100` | Bitwise XOR opcode encoding |
| `LDA`     | `3'b101` | Load opcode encoding |
| `STO`     | `3'b110` | Store opcode encoding |
| `JMP`     | `3'b111` | Jump opcode encoding |

All parameters are overridable at instantiation, allowing re-mapping of the opcode space without modifying RTL.

---

## How to Run (Icarus Verilog)

**Compile:**
```bash
iverilog -g2012 -o sim.out ALU.sv alu_tb.sv
```
**Run Simulation:**
```bash
vvp sim.out
```

---

## Simulation and Tools

Developed and verified using **Xilinx Vivado**. Compatible with any IEEE 1800 (SystemVerilog) compliant simulator.

---

## Contributing

Improvements welcome — particularly around:
- Signed arithmetic support
- Carry/overflow flag generation
- Expanded opcode set (shift, rotate, NOT)
- Self-checking assertions in the testbench

1. Fork → Branch → Implement → Simulate → PR

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**
