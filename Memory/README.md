# Memory

A synchronous 32-word by 8-bit RAM module implemented in SystemVerilog, integrated into a modular test harness demonstrating modern port connection idioms (`.*` and `.name`) and automated self-checking verification.

## File Header

```text
// File name   : mem.sv
// Title       : Memory
// Project     : SystemVerilog Works
// Created     : 2026-09-06
// Description : Synchronous 32x8-bit RAM with synchronous read and write operations, modular top-level harness, and automated verification testbench.
```

---

## Overview

Random Access Memory (RAM) is a critical storage block in digital computation and embedded processor architectures. This design implements a synchronous single-port 32x8-bit RAM (256-bit total capacity) using a 2D unpacked array. 

The design enforces strict mutual exclusion between read and write operations to prevent write-through hazards and race conditions. A top-level harness (`mem_top`) cleanly instantiates the memory DUT (`mem`) alongside a modular testbench (`mem_tb`), showcasing modern SystemVerilog connection syntax such as wildcard named ports (`.*`) and explicit dot-name ports (`.name`).

---

## Features

- **32 x 8-Bit Synchronous Storage:** Addressable 5-bit address space (`addr[4:0]`) indexing 32 locations of byte-wide data.
- **Synchronous Write Operation:** Clocked memory writes with positive edge sensitivity and `#1` intra-assignment transport delay modeling.
- **Synchronous Registered Read:** Edge-aligned data read using `always_ff` preventing combinational read glitches.
- **Mutual Exclusion Protection:** Logic gating (`write && !read` and `!write && read`) prevents contention between simultaneous read and write strobes.
- **Modern Connection Idioms:** Demonstrates implicit `.*` wildcard and `.name` port connections in `mem_top`.
- **Self-Checking Verification Suite:** Systematic tests covering memory clearance, address-to-data mapping, automated error counting, and timeout guards.

---

## Architecture

The project employs a modular top-level structure where `mem_top` acts as the system harness connecting clock generation, stimulus/checking (`mem_tb`), and the memory core (`mem`).

```text
               ┌────────────────────────────────────────────────────────┐
               │                        mem_top                         │
               │                                                        │
               │  always #5 clk = ~clk;                                 │
               │                                                        │
               │   ┌────────────────┐             ┌─────────────────┐   │
               │   │     mem_tb     │   addr[4:0] │       mem       │   │
               │   │   (Stimulus &  ├────────────►│   (32x8 RAM)    │   │
               │   │    Checkers)   │  data_in[7:0│                 │   │
               │   │                ├────────────►│  memory[31:0]   │   │
               │   │                │  read, write│                 │   │
               │   │                ├────────────►│                 │   │
               │   │                │ data_out[7:0│                 │   │
               │   │                │◄────────────┤                 │   │
               │   └────────────────┘             └─────────────────┘   │
               │                                                        │
               └────────────────────────────────────────────────────────┘
```

---

## Module Hierarchy

| Module | Purpose | Source File |
| :--- | :--- | :--- |
| `mem_top` | Top-level integration harness & clock generator | [`mem_top.sv`](mem_top.sv) |
| `mem` | 32x8-bit synchronous RAM core (DUT) | [`mem.sv`](mem.sv) |
| `mem_tb` | Modular stimulus generator & self-checking verification engine | [`mem_tb.sv`](mem_tb.sv) |

---

## Interface

### `mem` (DUT Ports)

| Port | Direction | Width | Type | Description |
| :--- | :---: | :---: | :--- | :--- |
| `clk` | Input | 1 | `logic` | Positive-edge master clock |
| `read` | Input | 1 | `logic` | Active-high memory read enable strobe |
| `write` | Input | 1 | `logic` | Active-high memory write enable strobe |
| `addr` | Input | 5 | `logic [4:0]` | 5-bit address bus (indexes locations `0` to `31`) |
| `data_in` | Input | 8 | `logic [7:0]` | 8-bit input data bus to be written into memory |
| `data_out` | Output | 8 | `logic [7:0]` | 8-bit registered output data bus read from memory |

### `mem_top` (Interconnect Signals)

| Net | Width | Type | Connection Description |
| :--- | :---: | :--- | :--- |
| `clk` | 1 | `bit` | 10 ns period master clock generated via `always #5 clk = ~clk;` |
| `read`, `write` | 1 | `wire` | Read and write control strobes from `mem_tb` to `mem` |
| `addr` | 5 | `wire [4:0]` | 5-bit address bus driven by `mem_tb` |
| `data_in` | 8 | `wire [7:0]` | Data bus driven by `mem_tb` into `mem` |
| `data_out` | 8 | `wire [7:0]` | Data bus driven by `mem` into `mem_tb` |

---

## RTL Implementation

1. **Storage Array Declaration:**
   ```systemverilog
   logic [7:0] memory [31:0];
   ```
   An unpacked array of 32 elements, each 8 bits wide, modeled for synthesis into FPGA distributed/block RAM.

2. **Mutual Exclusion Write Process:**
   ```systemverilog
   always @(posedge clk) begin
       if (write && !read)
           #1 memory[addr] <= data_in;
   end
   ```
   Write operations only trigger when `write` is asserted and `read` is deasserted. An intra-assignment delay `#1` models realistic transport delay in RTL behavioral simulation.

3. **Registered Read Process:**
   ```systemverilog
   always_ff @(posedge clk) begin
       if (!write && read)
           data_out <= memory[addr];
   end
   ```
   Data is sampled synchronously on the clock edge, ensuring output transitions are synchronous with the clock domain.

4. **SystemVerilog Port Connection Styles:**
   In `mem_top.sv`, two different modern connection styles are highlighted:
   - `mem_tb test (.*);` — Uses wildcard syntax to automatically connect all matching net names.
   - `mem memory (.clk, .read, .write, .addr, .data_in, .data_out);` — Uses named concise syntax for explicit matching without redundant parenthetical repetition.

---

## Verification

The verification environment in [`mem_tb.sv`](mem_tb.sv) performs automated end-to-end memory checking:

### Verification Structure

- **`write_mem` Task:** Drives address and data onto the buses, asserts `write` for one clock cycle on `negedge clk`, deasserts on the next negative edge, and logs the operation if `debug == 1`.
- **`read_mem` Task:** Asserts `read` on `negedge clk`, holds for one cycle, samples `data_out` into a local variable, and logs the operation.
- **`checkit` Function:** Compares actual output against expected data, logs any discrepancies, and increments an internal `static int error_status` variable.
- **`printstatus` Function:** Evaluates the accumulated error count and prints `"Test Passed - No Errors!"` or reports total error count.
- **Timeout Watchdog:** `#40000ns` timeout aborts the test with `"MEMORY TEST TIMEOUT"` if execution stalls.

### Test Scenarios

1. **Clear Memory Test:**
   - Writes `8'h00` to all 32 memory addresses (`0` through `31`).
   - Reads back all 32 addresses and verifies that every location contains `8'h00`.
2. **Data = Address Test:**
   - Writes value `i` to location `i` for all 32 addresses (`memory[0]=0`, `memory[1]=1`, ..., `memory[31]=31`).
   - Reads back all 32 addresses and verifies that `memory[i] == i`.

---

## Simulation Results

### Timing Waveforms

#### Complete Test Overview
The overall simulation waveform capturing memory write and read phases across the full address spectrum:

![Simulation Overview](Output%20waveform%201.png)

#### Clear Memory Phase
Waveform detail showing sequential writes of `8'h00` followed by verification reads:

![Clear Memory Waveform](Output%20waveform%204.png)

#### Data = Address Phase
Waveform detail showing patterned data writes matching memory addresses followed by verification reads:

![Data=Address Waveform](Output%20waveform%205.png)

### Console Verification Logs

#### Clear Memory Verification Pass
Confirmation showing all 32 locations cleared and verified with zero errors:

![Clear Memory Console Pass](console%20op%203.png)

#### Data = Address Verification Pass
Confirmation showing all 32 locations verified with address matching data:

![Data=Address Console Pass](console%20op%205.png)

---

## Schematics

### Elaborated Schematic

The top-level elaborated schematic generated in AMD Vivado shows the interconnection between `mem_tb` and `mem`:

![Elaborated Schematic](elaborated%20schematic.png)

### Synthesized Gate-Level Design

The synthesized design mapped to FPGA primitives:

![Synthesized Design](Synethsized%20design.png)

---

## How to Run Simulation

### Using Icarus Verilog

```bash
# Compile design, top harness, and testbench
iverilog -g2012 -o mem_sim.out mem.sv mem_tb.sv mem_top.sv

# Execute simulation
vvp mem_sim.out
```

### Using AMD Vivado (xsim batch mode)

```bash
# Analyze sources
xvlog -sv mem.sv mem_tb.sv mem_top.sv

# Elaborate top module
xelab mem_top -s mem_snapshot

# Run simulation
xsim mem_snapshot -R
```

---

## Technologies

- **SystemVerilog (IEEE 1800)**
- **RTL RAM Design & Memory Modeling**
- **Implicit Port Connections (`.*` and `.name`)**
- **Automated Verification (Tasks, Static Functions)**
- **AMD Vivado Design Suite**

---

## Contributing

Contributions focusing on parameterization (configurable data width and address depth), dual-port / true dual-port RAM architectures, and formal verification assertions are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/ram-enhancements`)
3. Commit your modifications
4. Verify simulation passes with zero errors
5. Submit a Pull Request

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**
