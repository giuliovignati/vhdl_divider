# VHDL Divider

Implementation of **Combinational** and **Sequential** Dividers in VHDL.

## Project Overview

The divider module takes two 16-bit **unsigned integers** as input—used respectively as **dividend** and **divisor**—and computes the corresponding **quotient** and **remainder**, both also 16-bit unsigned integers.

Two architectures have been developed:
- A **combinational** implementation
- A **sequential** (serial) implementation

The performance and structural differences between these two approaches have been analyzed and compared.

---

## Combinational Divider

The **combinational divider** performs division using functionality provided by the `IEEE.numeric_std.all` library, enabling the computation of both quotient and remainder **within a single clock cycle**.

### Architecture

- The logic block performs a single-cycle division using combinational logic.
- Four 16-bit registers are used:
  - Two registers for input sampling (dividend and divisor)
  - Two registers for output sampling (quotient and remainder)

This results in a total of **64 bits of registers**.

All registers are:
- Equipped with **active-low asynchronous reset**
- **Not controlled** by any enable signal

### Performance Metrics

- **Latency**: 1 clock cycle
- **Throughput**: `1 / Tclock` (maximum rate = clock frequency)

---

## Sequential Divider Description

The **serial divider** employs a single adder and performs the division operation over multiple clock cycles. It takes an additional `start` input signal and outputs the signals `elab` and `done`, in addition to the `quotient` and `remainder`.

The divider uses **four registers** for input and output data:
- One 31-bit register
- Three 16-bit registers
- One 4-bit register for the internal counter
- One 2-bit register for the state

This results in a total of **85 registers**.

### Control Logic

The processing is governed by a **Mealy finite state machine (FSM)**, which manages transitions based on the `start` input and an internal counter. The FSM includes the following states:

- **IDLE**: Waits for the `start` input to go high. Upon activation, the input data is sampled, and the FSM transitions to the CALC state.
- **CALC**: Performs the division on the sampled inputs while keeping the `elab` output high. A counter tracks the 16 clock cycles required for the computation. Upon completion, the FSM moves to the OUTPUT state.
- **OUTPUT**: Lasts one clock cycle. During this state, output registers are enabled, the counter is reset, the `done` flag is set high, and the FSM returns to the IDLE state.

### Division Algorithm

The actual division is handled by a dedicated block and consists of a series of **subtractions and shifts**, repeated `N` times, where `N` is the bit width of the dividend and divisor.

Steps:
- The dividend is initially extended to `2N - 1` bits (31 bits in this case).
- At each clock cycle, the 16 most significant bits of the dividend are subtracted by the divisor.
- The **sign bit** of the subtraction result becomes the **least significant bit (LSB)** of the quotient (achieved by shifting).
- This sign bit also influences the most significant bits of the dividend.
- The **remainder** is determined by the final subtraction.

### Performance Metrics

- **Latency**: The total latency, defined as the time interval between the input sampling and the corresponding output availability, is **17 clock cycles**.
- **Throughput**: The maximum frequency at which the `start` signal can be asserted is `1 / (17 * Tclock)`.

