# SystemVerilog Design & Verification

A collection of SystemVerilog digital design modules, testbenches, and simulation examples demonstrating fundamental hardware description concepts.

---

## 📁 Repository Structure

```text
System-Verilog/
├── up_down_counter/
│   ├── up_down.sv.txt                     # 4-bit synchronous up/down counter design & testbench
│   └── Screenshot 2026-11-14 113728.png  # Simulation waveform
├── blocking vs non_blocking/
│   ├── blocking_vs non_blocking.sv.txt   # Comparison between blocking (=) & non-blocking (<=)
│   └── Screenshot 2026-11-14 111457.png  # Comparative simulation waveform
└── README.md
```

---

## 📌 Projects & Modules

### 1. 4-Bit Up/Down Counter (`up_down_counter/`)

A 4-bit synchronous binary counter capable of counting up or down based on a control input.

#### Features
- **Bit-width:** 4-bit (`[3:0]`), counting from `0` to `15` (`4'h0` to `4'hF`) with rollover.
- **Clock Edge:** Synchronous operation triggered on the rising edge of `clk` (`posedge clk`).
- **Synchronous Reset (`rst`):** When active high (`rst = 1`), resets `count` to `4'b0000`.
- **Direction Control (`up_down`):**
  - `up_down = 1`: Increments `count` by `1` (`count + 1`).
  - `up_down = 0`: Decrements `count` by `1` (`count - 1`).

#### Port List

| Port Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 bit | System clock signal |
| `rst` | Input | 1 bit | Synchronous active-high reset |
| `up_down` | Input | 1 bit | Direction selector (`1` = Up, `0` = Down) |
| `count` | Output (reg) | 4 bits | 4-bit counter output register |

#### Simulation Waveform

![Up/Down Counter Waveform](up_down_counter/Screenshot%202026-11-14%20113728.png)

---

### 2. Blocking vs Non-Blocking Assignment Comparison (`blocking vs non_blocking/`)

This module demonstrates and compares the behavior of **Blocking (`=`)** and **Non-Blocking (`<=`)** procedural assignments in sequential logic blocks.

#### Modules Implemented
- `blocking_counter`: Uses blocking procedural assignments (`=`) inside `always @(posedge clk)`.
- `nonblocking_counter`: Uses non-blocking procedural assignments (`<=`) inside `always @(posedge clk)`.
- `tb`: Testbench instantiating both designs simultaneously with identical clock and control inputs to compare outputs side-by-side.

#### Key Concept Comparison

| Feature | Blocking Assignment (`=`) | Non-Blocking Assignment (`<=`) |
| :--- | :--- | :--- |
| **Execution Order** | Evaluated and assigned immediately in sequential order | Right-hand side (RHS) evaluated first; scheduled to update in the NBA region |
| **Synthesized Logic** | Typically used for combinational logic (`always_comb` / `always @*`) | Recommended standard for sequential logic (`always_ff` / `always @(posedge clk)`) |
| **Race Conditions** | Can cause simulation race conditions and mismatch between RTL and gate-level netlists | Eliminates race conditions across communicating synchronous flip-flops |

> **Best Practice Rule:**
> - Use non-blocking assignments (`<=`) when modeling sequential logic (registers / flip-flops).
> - Use blocking assignments (`=`) when modeling combinational logic.

#### Simulation Waveform

![Blocking vs Non-Blocking Waveform](blocking%20vs%20non_blocking/Screenshot%202026-11-14%20111457.png)

---

## 🚀 How to Run and Simulate

You can simulate these files using standard EDA tools or online simulators like [EDA Playground](https://www.edaplayground.com/):

### Using Icarus Verilog (`iverilog`) & GTKWave

1. **Compile and Run:**
   ```bash
   # For 4-bit Up/Down Counter
   iverilog -g2012 -o counter_sim up_down_counter/up_down.sv.txt
   vvp counter_sim

   # For Blocking vs Non-Blocking Comparison
   iverilog -g2012 -o b_vs_nb_sim "blocking vs non_blocking/blocking_vs non_blocking.sv.txt"
   vvp b_vs_nb_sim
   ```

2. **View VCD Waveform:**
   ```bash
   gtkwave dump.vcd
   ```

### Using ModelSim / QuestaSim / Vivado
1. Add the design file as a SystemVerilog source.
2. Compile and set the top-level module to `tb`.
3. Run simulation (`run -all`) and inspect the waveform and console monitor outputs.
