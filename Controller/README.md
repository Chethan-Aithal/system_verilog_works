# Controller

A synchronized, 8-state finite state machine (FSM) control unit for an 8-bit multi-cycle processor architecture implemented in SystemVerilog. The controller orchestrates instruction fetch, decode, operand fetch, execution, and memory writeback phases while managing program flow based on instruction opcodes and condition flags.

## File Header

```text
// File name   : controller.sv
// Title       : Controller
// Project     : SystemVerilog Works
// Created     : 2026-09-04
// Description : Multi-cycle CPU controller FSM orchestrating instruction fetch, decode, operand fetch, execution, and memory writeback phases.
```

---

## Overview

In multi-cycle CPU architectures, instructions execute across multiple sequential clock cycles rather than a single cycle. This design implements the central micro-sequencer/controller that generates synchronized control strobes for the datapath (Program Counter, Instruction Register, Accumulator, and Memory). 

The controller is implemented as a Moore/Mealy hybrid FSM with eight sequential states. It decodes eight distinct processor instructions (`HLT`, `SKZ`, `ADD`, `AND`, `XOR`, `LDA`, `STO`, `JMP`), evaluates status flags such as `zero`, and generates active-high control strobes with precise cycle timing.

---

## Features

- **8-Stage Multi-Cycle Sequencing:** Dedicated execution phases (`INST_ADDR`, `INST_FETCH`, `INST_LOAD`, `IDLE`, `OP_ADDR`, `OP_FETCH`, `ALU_OP`, `STORE`).
- **Comprehensive Instruction Decode:** Full control logic for 8 core CPU opcodes including arithmetic, logical, memory load/store, conditional skip, and unconditional branch.
- **Conditional Program Flow:** Implements conditional skip logic (`SKZ`) gated by the datapath `zero` flag.
- **SystemVerilog Package & Typed Enums:** Uses a shared `typedefs` package defining strongly typed enumerations (`state_t`, `opcode_t`) for synthesis clarity and waveform readability.
- **Safe Combinational Defaults:** Comprehensive default signal assignment in the combinational block eliminates unintentional latch inference.
- **Automated Self-Checking Testbench:** Pattern-driven verification environment comparing runtime response vectors against golden memory files with error reporting.

---

## Architecture

The controller interfaces directly between the CPU Instruction Register / status flags and the peripheral execution units.

```text
               ┌────────────────────────────────────────────────────────┐
               │                    CONTROLLER FSM                      │
               │                                                        │
   clk ───────►│  Sequential Block                                      ├──► mem_rd
   rst_ ──────►│  (always_ff @posedge clk / negedge rst_)               ├──► load_ir
               │    state <= next_state                                 ├──► halt
               │                                                        ├──► inc_pc
 opcode[2:0] ─►│  Combinational Decode & Control                        ├──► load_ac
   zero ──────►│  (always_comb)                                         ├──► load_pc
               │    Next-state transitions & active-high control strobes├──► mem_wr
               │                                                        │
               └────────────────────────────────────────────────────────┘
```

### Control Flow Pipeline

```text
INST_ADDR ──► INST_FETCH ──► INST_LOAD ──► IDLE ──► OP_ADDR ──► OP_FETCH ──► ALU_OP ──► STORE
   ▲                                                                                      │
   └──────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Module Hierarchy

| Module / Package | Type | Purpose | Source File |
| :--- | :--- | :--- | :--- |
| `typedefs` | Package | Defines `opcode_t` and `state_t` enumerations | [`typedefs.sv`](typedefs.sv) |
| `controller` | Module (Top) | Multi-cycle controller FSM and control signal generation | [`controller.sv`](controller.sv) |
| `controller_tb` | Testbench | Golden-vector self-checking verification harness | [`controller_tb.sv`](controller_tb.sv) |

---

## Interface

### Inputs

| Port | Type / Width | Direction | Description |
| :--- | :--- | :---: | :--- |
| `clk` | `bit` (1-bit) | Input | Master system clock |
| `rst_` | `logic` (1-bit) | Input | Active-low asynchronous master reset |
| `opcode` | `opcode_t` (3-bit enum) | Input | 3-bit instruction opcode from Instruction Register |
| `zero` | `logic` (1-bit) | Input | Zero condition flag from Accumulator/ALU |

### Outputs

| Port | Type / Width | Direction | Description |
| :--- | :--- | :---: | :--- |
| `mem_rd` | `logic` (1-bit) | Output | Memory read enable strobe for instruction and operand fetch |
| `load_ir` | `logic` (1-bit) | Output | Instruction Register load enable |
| `halt` | `logic` (1-bit) | Output | Processor halt status flag; asserted during `HLT` execution |
| `inc_pc` | `logic` (1-bit) | Output | Program Counter increment enable |
| `load_ac` | `logic` (1-bit) | Output | Accumulator load enable strobe for ALU operations |
| `load_pc` | `logic` (1-bit) | Output | Program Counter load enable (branch/jump address target) |
| `mem_wr` | `logic` (1-bit) | Output | Memory write enable strobe for store operations |

---

## FSM & Control Logic

The controller sequences through an 8-state ring architecture. State decoding and signal assertion follow the timing table below:

| State | State Code | Active Control Outputs | Description / Conditions |
| :--- | :---: | :--- | :--- |
| `INST_ADDR` | `3'b000` | None | Instruction address output cycle to memory bus |
| `INST_FETCH` | `3'b001` | `mem_rd` | Asserts memory read to access instruction byte |
| `INST_LOAD` | `3'b010` | `mem_rd`, `load_ir` | Latches fetched byte into Instruction Register |
| `IDLE` | `3'b011` | `mem_rd`, `load_ir` | Pipeline alignment / decode cycle |
| `OP_ADDR` | `3'b100` | `inc_pc`, `halt` | Increments PC to operand address; asserts `halt` if `opcode == HLT` |
| `OP_FETCH` | `3'b101` | `mem_rd` (if `ALUOP`) | Reads operand from memory if instruction is an ALU operation |
| `ALU_OP` | `3'b110` | `mem_rd`, `load_ac`, `inc_pc`, `load_pc` | Evaluates arithmetic/logic (`load_ac`), jump (`load_pc`), or skip (`inc_pc` on `zero`) |
| `STORE` | `3'b111` | `mem_wr`, `load_ac`, `load_pc`, `inc_pc` | Writes accumulator to memory if `opcode == STO`; returns to `INST_ADDR` |

### Instruction Set & Control Mapping

The package [`typedefs.sv`](typedefs.sv) defines the 3-bit opcode set:

| Opcode | Mnemonic | Operation | Behavior in `ALU_OP` & `STORE` |
| :---: | :---: | :--- | :--- |
| `3'b000` | `HLT` | Halt | Asserts `halt` in `OP_ADDR` |
| `3'b001` | `SKZ` | Skip if Zero | Asserts `inc_pc` in `ALU_OP` if `zero == 1'b1` |
| `3'b010` | `ADD` | Add | Asserts `mem_rd` and `load_ac` |
| `3'b011` | `AND` | Bitwise AND | Asserts `mem_rd` and `load_ac` |
| `3'b100` | `XOR` | Bitwise XOR | Asserts `mem_rd` and `load_ac` |
| `3'b101` | `LDA` | Load Accumulator | Asserts `mem_rd` and `load_ac` |
| `3'b110` | `STO` | Store Accumulator | Asserts `mem_wr` during `STORE` phase |
| `3'b111` | `JMP` | Jump | Asserts `load_pc` and `inc_pc` |

---

## RTL Implementation

1. **Two-Process FSM Style:**
   - Sequential process (`always_ff @(posedge clk or negedge rst_)`) handles asynchronous active-low reset initialization to `INST_ADDR` and synchronous state advancement.
   - Purely combinational process (`always_comb`) decodes next-state transitions and control output strobes.
2. **Defensive Coding:**
   - Every control output is initialized to `1'b0` at the head of the `always_comb` block, guaranteeing no inferable latches across unhandled conditions.
3. **Synthesis Optimization:**
   - Internal boolean `ALUOP` flag groups common operations (`ADD`, `XOR`, `AND`, `LDA`) to share gating logic across `mem_rd` and `load_ac`.

---

## Verification

The verification environment in [`controller_tb.sv`](controller_tb.sv) utilizes a vector-driven, golden-response verification methodology.

### Testbench Architecture

```text
                      ┌───────────────────────────────────────────────┐
                      │                 controller_tb                 │
                      │                                               │
   stimulus.pat ─────►│ Stimulus Memory (64 vectors x 4 bits)         │
                      │   [3] = zero flag, [2:0] = opcode             │
                      │                         │                     │
                      │                         ▼                     │
                      │               controller (DUT)                │
                      │                         │                     │
                      │                         ▼                     │
                      │ Measured Response: {mem_rd,load_ir,halt,      │
                      │                    inc_pc,load_ac,load_pc,    │
                      │                    mem_wr}                    │
                      │                         │                     │
                      │                         ▼                     │
   response.pat ─────►│ Response Memory (550 vectors x 7 bits)        │
                      │ Golden comparison every negedge clk           │
                      │                                               │
                      └───────────────────────────────────────────────┘
```

### Verification Strategy

- **Pattern-Driven Stimulus:** 64 consecutive test vectors containing various opcode and zero-flag combinations are applied across all 8 phases of each instruction cycle.
- **Continuous Golden Comparison:** At every negative clock edge, all 7 control outputs (`{mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr}`) are evaluated against the golden response vector.
- **Automatic Failure Notification:** If any signal deviates from expectation, the testbench displays a descriptive mismatch breakdown with current state, opcode, and zero values, and halts immediately with `$stop`.
- **Watchdog Timeout:** A `#12000ns` timeout guard ensures non-responsive simulation runs terminate automatically.

---

## Simulation Results

### Timing Waveform

The simulation waveform below illustrates the 8-state sequence progressing from instruction fetch (`INST_ADDR` through `INST_LOAD`), decode, and multi-cycle execution:

![Controller Waveform](Controller%20Waveform.png)

### Verification Confirmation

All 64 instruction test cases executed without discrepancy, concluding with test pass confirmation:

![TCL Console Pass Confirmation](TCL%20console%20till%205.2us%28TEST%20pass%20confirmation%29.png)

---

## Synthesis Considerations

The design synthesizes cleanly with zero latches and optimal LUT utilization.

### Elaborated Schematic

![Elaborated Schematic](Elaborated%20schematic.png)

### Synthesized Gate-Level Schematic

![Synthesized Schematic](Synthesized%20schematic.png)

---

## Tools and Simulation

- **Simulation Tool:** AMD Vivado Simulator (XSim)
- **Synthesis Tool:** AMD Vivado Synthesis
- **Language Standard:** IEEE 1800-2012 / 1800-2017 SystemVerilog

### Running Simulation (Vivado xsim batch mode)

```bash
# Analyze package and design sources
xvlog -sv typedefs.sv controller.sv controller_tb.sv

# Elaborate testbench top
xelab controller_tb -s sim_snapshot

# Run simulation
xsim sim_snapshot -R
```

### Running Simulation (Icarus Verilog)

```bash
# Compile package, design, and testbench
iverilog -g2012 -o controller_sim typedefs.sv controller.sv controller_tb.sv

# Execute simulation
vvp controller_sim
```

---

## Getting Started

### Prerequisites

- AMD Vivado Design Suite (2020.1 or newer) or any IEEE 1800-compliant SystemVerilog simulator (Icarus Verilog 11+, ModelSim/Questa, VCS, Xcelium).

### Setup

Ensure that `stimulus.pat` and `response.pat` reside in the working directory from which simulation is invoked, as the testbench reads these patterns via `$readmemb`.

---

## Project Structure

```text
Controller/
├── typedefs.sv                                       # Package with opcode_t and state_t enums
├── controller.sv                                     # Top-level multi-cycle controller FSM
├── controller_tb.sv                                  # Pattern-based self-checking testbench
├── stimulus.pat                                      # Input stimulus vector file (64 entries)
├── response.pat                                      # Golden response vector file (550 entries)
├── Controller Waveform.png                           # Simulation timing waveform
├── Elaborated schematic.png                          # RTL elaborated schematic overview
├── Elaborated schematic 1 view.png                   # Elaborated schematic detailed view 1
├── Elaborated schematic 2 view.png                   # Elaborated schematic detailed view 2
├── Synthesized schematic.png                         # Gate-level mapped schematic
├── TCL console till 5.2us(TEST pass confirmation).png# Testbench pass confirmation log
└── README.md                                         # Project documentation
```

---

## Technologies

- **SystemVerilog (IEEE 1800)**
- **RTL Design & Finite State Machines (FSM)**
- **Computer Architecture & CPU Control Unit Design**
- **AMD Vivado Design Suite**
- **Pattern-Based Self-Checking Verification**

---

## Contributing

Contributions focusing on expanding the instruction set, adding pipeline hazard controls, or extending formal assertions (SVA) are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/controller-enhancement`)
3. Commit your modifications
4. Verify simulation passes with 100% compliance
5. Submit a detailed Pull Request

---

## Future Improvements

- **Interrupt Handling:** Add asynchronous interrupt input (`intr`) and interrupt-acknowledge sequencing.
- **Conditional Branch Extensions:** Support additional flag evaluations (carry, negative, overflow).
- **SystemVerilog Assertions (SVA):** Embed formal properties verifying mutual exclusion of `mem_rd` and `mem_wr`, and correct state progression.

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**
