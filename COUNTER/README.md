# 5-Bit Synchronous Counter with Parallel Load

A synchronous 5-bit up-counter with asynchronous active-low reset, synchronous parallel load, and an active-high count enable signal, written in SystemVerilog.

---

## Overview

Counters are essential building blocks in digital logic for generating delays, tracking states, or sequencing events. This project demonstrates a hardware-friendly 5-bit sequential counter. The design correctly implements sequential logic priorities using `always_ff`, ensuring synthesis tools properly map it to dedicated flip-flops with enable and synchronous set/reset pins where available.

---

## Features

- **Asynchronous Reset:** Immediate clearing of the counter state independent of the clock.
- **Synchronous Parallel Load:** Direct assignment of the counter value from a 5-bit input bus.
- **Synchronous Enable:** Control signal to pause or resume counting.
- **Priority Logic Handling:** Strict enforcement of logic priorities: Reset > Load > Enable > Hold.

---

## RTL Architecture

The architecture relies on a single sequential process evaluating the control signals sequentially to assign the 5-bit register state.

```text
               ┌─────────────┐
               │             │
 data [4:0] ──►│   5-Bit     ├─► count [4:0]
      load  ──►│   Up        │
    enable  ──►│   Counter   │
      clk   ──►│             │
      rst_  ──►│             │
               └─────────────┘
```

---

## Interface

| Signal   | Direction | Width | Description |
| -------- | --------- | :---- | ----------- |
| `clk`    | Input     | 1     | Clock signal driving the sequential logic. |
| `rst_`   | Input     | 1     | Asynchronous active-low reset. |
| `load`   | Input     | 1     | Synchronous control to load `data` into `count`. |
| `enable` | Input     | 1     | Synchronous control to increment `count`. |
| `data`   | Input     | 5     | Parallel data input for loading. |
| `count`  | Output    | 5     | Current 5-bit counter value. |

---

## RTL Implementation

The `counter` module utilizes a positive edge-triggered `always_ff` block and an active-low reset `negedge rst_` in its sensitivity list, which naturally models flip-flops with asynchronous clear pins.

The control logic strictly uses an `if-else if` structure, establishing a clear hardware priority:
1. `!rst_` forces `count` to `00000` asynchronously.
2. `load` forces `count` to match `data` synchronously on the clock edge, overriding the `enable` signal.
3. `enable` increments the counter by 1.
4. If no conditions are met, the counter securely holds its current state (`count <= count`).

---

## Verification

### Testbench Architecture

The testbench (`counter_tb.sv`) instantiates the DUT (Design Under Test) and verifies the logical priorities deterministically.

### Verification Strategy

The test bench specifically validates each control signal systematically:
1. **System Initialization:** Sets default states.
2. **Asynchronous Reset Test:** Asserts `rst_` (0) alongside don't-care inputs to prove reset overrides everything immediately.
3. **Parallel Load Priority Test:** Asserts both `load` and `enable` simultaneously to prove that `load` takes priority over counting, successfully latching `5'b01010`.
4. **Normal Count Up Increment Test:** Removes `load` and maintains `enable`, allowing the counter to increment freely over several clock cycles.
5. **State Holding Test:** De-asserts `enable`, proving the counter retains its value without incrementing.

### Simulation Results

The resulting waveforms demonstrate that all priorities function correctly.

![System Waveform](sys%20waveform.png)
*Waveform capturing all operational stages: Reset, Load, Increment, and Hold.*

![Counter Detail](waveform%20counter.png)
*Detailed view of the counter logic transitions.*

---

## Synthesis Considerations

Because of the correct usage of `always_ff` and non-blocking assignments (`<=`), the code is fully synthesizable without latch inference or race conditions.

### Elaborated Schematic

The synthesis tool interprets this logic to create an adder feeding into a D-type flip-flop structure with a multiplexer for the load and enable signals.

![Elaborated Schematic](elaborated%20schematic.png)

---

## Simulation and Tools

The original verification was performed using **Xilinx Vivado**. The standard SystemVerilog code can be compiled in any simulator.

### How to Run (Icarus Verilog Example)

**Compile:**
```bash
iverilog -g2012 -o sim.out counter.sv counter_tb.sv
```
**Run Simulation:**
```bash
vvp sim.out
```

---

## Project Structure

```text
COUNTER/
├── counter.sv                # RTL design file
├── counter_tb.sv             # Verification testbench
├── elaborated schematic.png  
├── sys waveform.png          
├── waveform counter.png      
└── README.md                 # Project documentation
```

---

## Contributing

Contributions are welcome for adding new functionality like parameterization, count-down capabilities, or terminal count flags.

1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request

---

## License

License information has not yet been specified.
