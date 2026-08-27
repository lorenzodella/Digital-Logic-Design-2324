# Digital Logic Design Final Project (A.Y. 2023–2024)

Final project for the **Digital Logic Design** (*Reti Logiche*) course at **Politecnico di Milano** (A.Y. 2023-2024).

**Final Grade: 30L / 30 with honors (30 e Lode)**

## 📌 Project Overview

The objective of the project is to design and implement a synchronous digital hardware component in **VHDL** that interfaces with a Single-Port Block RAM. 

The module processes a sequence of $K$ 8-bit words ($W$) located at even memory offsets starting from base address `ADD` ($ADD, ADD+2, ADD+4, \dots, ADD+2(K-1)$). In parallel, it calculates and writes a **credibility value** $C \in [0, 31]$ directly into the adjacent odd byte ($ADD+1, ADD+3, \dots$).

### Functional Rules:
1. **Valid Data ($W > 0$):**
   - The original word is kept in memory.
   - The value is saved internally as the latest valid reading.
   - Credibility $C$ is reset to its maximum value: **31** (`0x1F`).
2. **Missing / Unspecified Data ($W = 0$):**
   - The missing word in memory is replaced by the *last valid non-zero word* read.
   - The credibility value $C$ is decremented by 1 ($C = C - 1$).
   - $C$ is saturating at zero: once it reaches **0**, it cannot decrease further.
3. **Leading Zeros:**
   - If the sequence starts with zeros before any valid word has been encountered, the value remains `0` and credibility $C$ is written as `0`.


## 📐 Component Interface

```vhdl
entity project_reti_logiche is
  port (
    i_clk      : in  std_logic;                     -- System Clock
    i_rst      : in  std_logic;                     -- Asynchronous Global Reset
    i_start    : in  std_logic;                     -- Start computation signal
    i_add      : in  std_logic_vector(15 downto 0); -- Starting memory address
    i_k        : in  std_logic_vector(9 downto 0);  -- Sequence length (number of words)
    
    o_done     : out std_logic;                     -- Computation finished signal
    
    o_mem_addr : out std_logic_vector(15 downto 0); -- Memory address bus
    i_mem_data : in  std_logic_vector(7 downto 0);  -- Memory data input (Read)
    o_mem_data : out std_logic_vector(7 downto 0);  -- Memory data output (Write)
    o_mem_we   : out std_logic;                     -- Memory Write Enable (1 = Write, 0 = Read)
    o_mem_en   : out std_logic                      -- Memory Enable
  );
end project_reti_logiche;

```

## 🏗️ Hardware Architecture

The design follows a standard Datapath + Control Unit (FSM) architecture.

### Datapath Modules:

* **`counter_add` (16-bit up-counter):** Tracks the current memory address being read or written.
* **`register` (8-bit register):** Stores the most recent non-zero word read from memory.
* **`counter_c` (5-bit down-counter):** Holds the credibility metric $C$ (saturates at 0, presets to 31).
* **`counter_k` (10-bit down-counter):** Decrements with each processed word to track the remaining workload.
* **`MUX` (2-to-1 8-bit multiplexer):** Directs either the stored word or the credibility value to `o_mem_data`.

## 🔄 Finite State Machine (FSM)

The control unit is implemented as a synchronous **Moore Finite State Machine** with 7 states:

1. **`INIT` (S0):** Resets internal registers and counters upon `i_rst` or when waiting for `i_start = '1'`. Loads `i_add` and `i_k`.
2. **`CHECK` (S1):** Checks if $K > 0$. If words remain, transitions to `READ`; if $K = 0$, transitions to `DONE`.
3. **`READ` (S2):** Reads the current byte $W$ from memory. Routes to `DATA` if $W > 0$, or `NO_DATA` if $W = 0$.
4. **`DATA` (S3):** Saves the non-zero word into the internal register, resets credibility counter $C \leftarrow 31$, increments `counter_add`, and moves to `WRITE`.
5. **`NO_DATA` (S4):** Overwrites the empty byte with the last saved valid word (`MUX = 0`, `we = 1`), decrements $C$ (if $C > 0$), increments `counter_add`, and moves to `WRITE`.
6. **`WRITE` (S5):** Writes the credibility value $C$ to the adjacent byte (`MUX = 1`, `we = 1`), decrements $K$, increments `counter_add`, and loops back to `CHECK`.
7. **`DONE` (S6):** Asserts `o_done = '1'` and holds until `i_start` returns to `0`.

## 📊 Synthesis & Performance

Synthesized with **Xilinx Vivado**:

| Resource / Timing Metric | Result | Target / Limit |
| --- | --- | --- |
| **Slice LUTs** | **51** | 134,600 (0.04%) |
| **Slice Registers (FF)** | **42** | 269,200 (0.02%) |
| **Latches** | **0** | Clean synchronous design |
| **Clock Period** | **20.0 ns** | 50 MHz |
| **Worst Negative Slack (WNS)** | **+16.947 ns** | Timing constraints met |
| **Max Data Path Delay** | **2.902 ns** | — |

## 📂 Documentation & Assets

* 📄 [Project Specifications (PDF)](docs/specs.pdf)
* 📄 [Full Project Report (PDF)](docs/report.pdf)
* 🖼️ [Circuit Diagram (PNG)](docs/circuit.png)
* 🖼️ [FSM State Transition Diagram (PNG)](docs/fdm.png)