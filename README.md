# ⚙️ VHDL Divider

This repository contains the implementation of **Combinational** and **Sequential (Serial)** dividers in VHDL.

---

## 🧾 Project Overview

The divider module accepts two 16-bit **unsigned integers** as input—designated as the **dividend** and the **divisor**—and computes their corresponding **quotient** and **remainder**, both also represented as 16-bit unsigned integers.

Two architectural approaches have been developed:

- ✅ **Combinational** implementation  
- 🔄 **Sequential (Serial)** implementation

The performance, design trade-offs, and structural differences between the two approaches are explored and analyzed in this project.

---

## ⚡ Combinational Divider

The **combinational divider** performs division in a **single clock cycle**, leveraging the `IEEE.numeric_std.all` library for arithmetic operations.

### 🏗️ Architecture

- Uses **pure combinational logic** to compute results.
- Incorporates **four 16-bit registers**:
  - Two for input sampling (dividend, divisor)
  - Two for output storage (quotient, remainder)

📐 **Total Register Usage**: 64 bits

🔧 Register Characteristics:
- Active-low **asynchronous reset**
- **No enable signals**

### 📊 Performance Metrics

- **Latency**: 1 clock cycle
- **Throughput**: `1 / Tclock` ⏱️

![Combinational Divider](https://github.com/user-attachments/assets/19e32720-f45a-40e1-b293-393ac2a04a86)

---

## 🔁 Sequential Divider

The **sequential divider** performs division over multiple clock cycles using a **single adder** and additional control logic. It includes three extra signals:  
- `start` (input)  
- `elab` (output - elaboration in progress)  
- `done` (output - computation complete)

### 🏗️ Architecture

- Register Usage:
  - One 31-bit register
  - Three 16-bit registers
  - One 4-bit counter register
  - One 2-bit FSM state register

📐 **Total Register Usage**: 85 bits

### 🧠 Control Logic

Governed by a **Mealy Finite State Machine (FSM)** with three states:

- 🛑 **IDLE**: Waits for `start`; samples inputs when triggered.
- 🔧 **CALC**: Performs 16-cycle division; sets `elab` high.
- ✅ **OUTPUT**: Finalizes computation; sets `done` high, resets counter, returns to IDLE.

### 🔢 Division Algorithm

- The dividend is extended to **31 bits** (`2N - 1`).
- Each cycle:
  - Subtracts the 16 MSBs of the dividend from the divisor.
  - The **sign bit** of the result becomes the next **LSB of the quotient**.
  - Result affects the next shift operation.
- Final subtraction yields the **remainder**.

### 📊 Performance Metrics

- **Latency**: 17 clock cycles ⏱️
- **Throughput**: `1 / (17 × Tclock)`

![Sequential Divider](https://github.com/user-attachments/assets/6c295d93-eef5-4228-a08d-98c3b5b95c71)

---

## 🧪 Simulations

To verify functional correctness, two separate **testbenches** were created:

- 🧮 One for the **combinational** divider  
- ⏳ One for the **sequential** divider (includes start signal logic)

All testbenches include:
- Clock signal generation
- Reset logic
- Controlled input stimulus

![Simulation](https://github.com/user-attachments/assets/7faf81bd-5c0f-4a64-bd29-aeb7a1ac06dc)

---

## 🖥️ FPGA Deployment

Both architectures were synthesized and tested on the **Intel Cyclone IV** (EP4CE6E22C9L) FPGA. Compilation was performed in **balanced mode**, followed by:

### ⏱️ Timing Analysis

- Conducted using `.sdc` constraints
- Minimum clock periods:
  - 🧮 Combinational: **73 ns**
  - 🔁 Sequential: **7 ns**

![Timing 1](https://github.com/user-attachments/assets/85894cfb-09b6-4698-a4ae-1433c0b0ddfd)  
![Timing 2](https://github.com/user-attachments/assets/d210e0a6-c9df-4848-88d2-91645f58371c)

📝 **Note**: While the combinational divider operates in a single cycle, it demands a much longer clock period due to its complexity.

---

## 🔋 Power Analysis

Power was analyzed using:
- A fixed toggle activity factor
- Switching activity extracted from simulations

### 🔍 Key Observations

- **Dynamic Power**:  
  Higher in the **sequential divider** due to more clock cycles ⏲️  
- **Static Power**:  
  Similar across both architectures, temperature-dependent 🌡️  
- **Combinational Cell Power**:  
  Higher in the **combinational divider**, reflecting its logic complexity 🔌

📌 **Conclusion**:  
- The **combinational** divider uses more power *per cycle*  
- The **sequential** divider consumes *more total energy per operation* ⚖️

![Power 1](https://github.com/user-attachments/assets/fb465116-1758-4952-8652-5963c4c1437a)  
![Power 2](https://github.com/user-attachments/assets/94a7f03e-ac50-4a50-8e69-3a223eb11d57)

---

## 🧱 Standard Cell Deployment

Both dividers were synthesized using the **Nangate 45nm** standard cell library and evaluated under varying clock constraints.

### 📏 Results Summary

- Minimum clock periods:
  - Combinational: **9.5 ns**
  - Sequential: **2 ns**

Compared to FPGA results:
- ⬆️ **Higher frequencies** supported
- ⬇️ **Lower power consumption**

⚠️ As expected, the combinational divider still exhibits higher **instantaneous power**, but requires fewer cycles—resulting in lower **total energy** consumption per division.

![Standard Cell 1](https://github.com/user-attachments/assets/c59cf22f-efa8-42d8-bcb5-e67b9cb8553c)  

![Standard Cell 2](https://github.com/user-attachments/assets/00977af0-f99e-40e4-b196-927a6efecc20)
