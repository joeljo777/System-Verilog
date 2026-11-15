# SystemVerilog Design & Verification

A collection of SystemVerilog digital design modules, testbenches, simulation waveforms, and study notes demonstrating fundamental hardware description and layered verification concepts.

---

## 📁 Repository Structure

```text
System-Verilog/
├── ADDER_SV/
│   ├── adder.sv.txt                       # Registered 4-bit adder DUT with valid handshake & async reset
│   ├── interface.sv.txt                   # Interface definition connecting testbench and DUT
│   ├── transaction.sv.txt                 # Transaction class with randomized stimulus (a, b) and response (c)
│   ├── generator.sv.txt                   # Generator class producing randomized transactions
│   ├── driver.sv.txt                      # Driver class converting transactions to interface pin wiggles
│   ├── monitor.sv.txt                     # Monitor class sampling pin activity and packaging transactions
│   ├── scoreboard.sv.txt                  # Scoreboard class verifying DUT outputs against reference model
│   ├── environment.sv.txt                 # Environment class orchestrating TB components and phases
│   ├── test.sv.txt                        # Top-level test program configuring and starting the test
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

A registered 4-bit binary adder design accompanied by a modular, object-oriented SystemVerilog layered testbench environment following industry-standard verification methodology.

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

---

#### B. Layered Testbench Architecture

The testbench structure adopts standard SystemVerilog OOP verification practices with clear separation of concerns across layered components:

```text
+-------------------------------------------------------------------------------+
|                                 Environment                                   |
|                                                                               |
|  +---------------+      gen2driv      +------------+                          |
|  |   Generator   | -----------------> |   Driver   |                          |
|  +---------------+    (mailbox trans) +------------+                          |
|          |                                   |                                |
|          | event ended                       | pin-level drive (reset, valid) |
|          v                                   v                                |
|    Synchronization                  Virtual Interface (vif)                   |
|  +-------------------------------------------+-----------------------------+  |
|  |                  CLK / RST / VALID / A / B / C                          |  |
|  +-------------------------------------------+-----------------------------+  |
|                                              |                                |
|                                              v pin-level sample               |
|  +---------------+      mon2scb       +------------+                          |
|  |  Scoreboard   | <----------------- |  Monitor   |                          |
|  | (ref model &  |    (mailbox trans) +------------+                          |
|  |  self-check)  |                                                            |
|  +---------------+                                                            |
+-------------------------------------------------------------------------------+
                                       |
                                       v
                             +-------------------+
                             |     DUT (addr)    |
                             +-------------------+
```

#### C. Verification Components Breakdown

| Component | File | Description |
| :--- | :--- | :--- |
| **Transaction** | `transaction.sv.txt` | Encapsulates stimulus and response fields (`rand bit [3:0] a, b`, `bit [4:0] c`) with custom banner formatting via `display()`. |
| **Interface** | `interface.sv.txt` | Groups physical signals (`clk`, `rst`, `valid`, `a`, `b`, `c`) into a bundle (`intf`) to eliminate port clutter between modules and classes. |
| **Generator** | `generator.sv.txt` | Generates randomized transaction packets for `repeat_count` iterations, verifies `.randomize()`, pushes packets into `mailbox gen2driv`, and triggers `->ended`. |
| **Driver** | `driver.sv.txt` | Pulls transactions from `gen2driv`, handles reset sequencing (`reset` task), and drives synchronous stimulus on clock edges (`vif.valid`, `vif.a`, `vif.b`). |
| **Monitor** | `monitor.sv.txt` | Passively samples interface lines on clock edges when `vif.valid` is asserted, captures input/output data, and forwards packaged transactions via `mailbox mon2scb`. |
| **Scoreboard** | `scoreboard.sv.txt` | Self-checking reference model that consumes transactions from `mon2scb`, checks `(trans.a + trans.b) == trans.c`, tracks transaction counts, and reports verification errors. |
| **Environment** | `environment.sv.txt` | Top-level verification environment that instantiates and connects all components and mailboxes, managing test lifecycle across four phases (`pre_test` $\rightarrow$ `test` $\rightarrow$ `post_test` $\rightarrow$ `run`). |
| **Test Program** | `test.sv.txt` | Dedicated test container (`program test`) that configures parameters (e.g., `env.gen.repeat_count = 10`) and executes the simulation run. |

##### Environment Phase Flow
1. **`pre_test()`**: Invokes driver reset sequence (`driv.reset()`) to place the DUT in a known state.
2. **`test()`**: Concurrently executes `gen.main()`, `driv.main()`, `mon.main()`, and `scb.main()` inside a `fork ... join_any` block.
3. **`post_test()`**: Synchronizes completion by waiting on `gen.ended.triggered` and validating that `repeat_count` equals both driver transactions and scoreboard checked transactions.
4. **`run()`**: Orchestrates `pre_test()` $\rightarrow$ `test()` $\rightarrow$ `post_test()` and terminates cleanly via `$finish`.

#### D. Simulation Waveform

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
   # For Registered 4-bit Adder & Testbench
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

### Using ModelSim / QuestaSim / Vivado / VCS
1. Add design and testbench files as SystemVerilog sources.
2. Compile and set the top-level testbench (`tb` or top-level testbench module).
3. Run simulation (`run -all`) and inspect scoreboard reports, monitors, and waveform outputs.
