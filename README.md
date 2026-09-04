# SystemVerilog Works

A repository of SystemVerilog, RTL design, and verification projects maintained in an organized and independent structure.

## Repository Projects

| Project | Description | Design File | Testbench |
| :--- | :--- | :--- | :--- |
| [Register](Register/) | 8-bit storage register with synchronous enable and asynchronous active-low reset | [`Register.sv`](Register/Register.sv) | [`register_tb.sv`](Register/register_tb.sv) |
| [MUX](MUX/) | Parameterized 2-to-1 multiplexer using `always_comb` and `unique case` | [`mux.sv`](MUX/mux.sv) | [`mux_test.sv`](MUX/mux_test.sv) |
| [COUNTER](COUNTER/) | 5-bit synchronous up-counter with parallel load and asynchronous active-low reset | [`counter.sv`](COUNTER/counter.sv) | [`counter_tb.sv`](COUNTER/counter_tb.sv) |
| [ALU](ALU/) | 8-bit Arithmetic Logic Unit with 8 parameterized opcodes and zero flag | [`ALU.sv`](ALU/ALU.sv) | [`alu_tb.sv`](ALU/alu_tb.sv) |
| [Controller](Controller/) | Multi-cycle CPU 8-state controller FSM with golden vector-driven testbench | [`controller.sv`](Controller/controller.sv) | [`controller_tb.sv`](Controller/controller_tb.sv) |

---

© 2026 Chethan Aithal. All rights reserved.

---

## Author

**Chethan Aithal**