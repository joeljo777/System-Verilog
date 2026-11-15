# SystemVerilog Design & Verification

A collection of SystemVerilog digital design modules, testbenches, simulation waveforms, and study notes demonstrating fundamental hardware description and verification concepts.

---

## 📁 Repository Structure

```text
System-Verilog/
├── ADDER_SV/
│   ├── adder.sv.txt                       # Registered 4-bit adder with valid handshake & async reset
│   ├── transaction.sv.txt                 # Transaction class with randomized stimuli (a, b)
│   ├── interface.sv.txt                   # Interface definition connecting testbench and DUT
│   ├── generator.sv.txt                   # Generator class producing randomized transactions
│   └── Screenshot 2026-11-14 153845.png  # Simulation waveform
├── up_down_counter/
│   ├── up_down.sv.txt                     # 4-bit synchronous up/down counter design & testbench
│   └── Screenshot 2026-11-14 113728.png  # Simulation waveform
├── blocking vs non_blocking/
│   ├── blocking_vs non_blocking.sv.txt   # Comparison between blocking (=) & non-blocking (<=)
│   └── Screenshot 2026-11-14 111457.png  # Comparative simulation waveform
├── Verilog_SystemVerilog_Study_Notes.docx # Comprehensive study & interview notes
├── Sysyem_Verilog.png                     # SystemVerilog architecture & reference diagram
└── README.md
```

---

## 📌 Projects & Modules

### 1. Synchronous 4-Bit Adder & Layered Verification Environment (`ADDER_SV/`)

A registered 4-bit binary adder design accompanied by a modular, object-oriented SystemVerilog layered testbench environment.

#### A. Design Under Test (DUT - `adder.sv.txt`)
- **Bit-width:** Adds two 4-bit inputs (`a[3:0]`, `b[3:0]`) producing a 5-bit registered sum output (`c[4:0]`) to accommodate carry-out.
- **Clock Edge & Reset:** Uses `always_ff @(posedge clk or posedge rst)` for sequential registered logic with asynchronous active-high reset.
- **Valid Enable Handshake (`valid`):** Computes and registers `a + b` into `tmp_c` only when `valid = 1`.
- **Registered Output:** Continuous assignment `assign c = tmp_c;` safely drives the registered lower 5 bits.

##### Port List

| Port Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 bit | System clock signal |
| `rst` | Input | 1 bit | Asynchronous active-high reset |
| `valid` | Input | 1 bit | Input data valid flag (enables addition) |
| `cin` | Input | 1 bit | Carry-in signal |
| `a` | Input | 4 bits | 4-bit operand input A |
| `b` | Input | 4 bits | 4-bit operand input B |
| `c` | Output | 5 bits | 5-bit registered sum output (`tmp_c[4:0]`) |

#### B. Layered Testbench Architecture

The testbench structure adopts standard SystemVerilog OOP verification practices:

```text
+------------------+          +---------+          +--------+
|    Generator     | -------> | Mailbox | -------> | Driver | ---> Interface ---> DUT
| (random stimuli) |  (trans) |         |  (trans) |        |      (inf)      (addr)
+------------------+          +---------+          +--------+
         |
         v
    event ended (completion)
```

- **Transaction (`transaction.sv.txt`):**
  - Defines the transaction packet containing randomized stimulus variables (`rand bit [3:0] a, b`) and response container (`bit [4:0] c`).
  - Implements a `display(string name)` helper method for consistent simulation logging.
- **Interface (`interface.sv.txt`):**
  - Encapsulates the pin-level connectivity (`valid`, `a`, `b`, `c`) with `clk` and `rst`.
  - Simplifies DUT-to-testbench connections and avoids wiring clutter.
- **Generator (`generator.sv.txt`):**
  - Generates randomized transactions over `repeat_count` iterations.
  - Verifies randomization success using `if(!trans.randomize()) $fatal(...)`.
  - Transmits transaction objects to the driver via `mailbox gen2driv.put(trans)`.
  - Triggers `->ended` event to signal when all stimuli have been dispatched.

#### C. Simulation Waveform

![Adder Simulation Waveform](ADDER_SV/Screenshot%202026-11-14%20153845.png)

---

### 2. 4-Bit Up/Down Counter (`up_down_counter/`)

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

### 3. Blocking vs Non-Blocking Assignment Comparison (`blocking vs non_blocking/`)

Demonstrates and compares the behavior of **Blocking (`=`)** and **Non-Blocking (`<=`)** procedural assignments in sequential logic blocks.

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

## 📚 Study Notes & Reference Materials

- **`Verilog_SystemVerilog_Study_Notes.docx`**: In-depth reference notes covering data types, procedural blocks (`always_comb`, `always_ff`, `always_latch`), OOP in SystemVerilog, constraints, randomization, and verification concepts.
- **`Sysyem_Verilog.png`**: High-level visual cheat sheet / diagram outlining key language constructs and verification architecture.

---

## 🚀 How to Run and Simulate

You can simulate these files using standard EDA tools or online simulators like [EDA Playground](https://www.edaplayground.com/):

### Using Icarus Verilog (`iverilog`) & GTKWave

1. **Compile and Run:**
   ```bash
   # For Registered 4-bit Adder
   iverilog -g2012 -o adder_sim ADDER_SV/adder.sv.txt
   vvp adder_sim

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
2. Compile and set the top-level module to the respective testbench (`tb`).
3. Run simulation (`run -all`) and inspect the waveform and console monitor outputs.
