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

![Image](https://github.com/user-attachments/assets/19e32720-f45a-40e1-b293-393ac2a04a86)


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

![Image](https://github.com/user-attachments/assets/6c295d93-eef5-4228-a08d-98c3b5b95c71)


---


## Simulations

In  order to verify the logical correctness of the code, two separate testbenches were implemented: one for the serial implementation and one for the combinational version. The primary difference between the two lies in the frequency at which input signals are applied.

Both testbenches include the generation of the clock signal, reset signal, and a series of numerical values assigned to the input signals. In the testbench for the serial divider, it was also necessary to generate a start signal to manage the initiation of the computation process.

![Image](https://github.com/user-attachments/assets/7faf81bd-5c0f-4a64-bd29-aeb7a1ac06dc)

## FPGA Deployment 

For both versions of the divider, compilation was carried out by mapping the RTL code onto the EP4CE6E22C9L FPGA device, which belongs to Intel’s Cyclone IV family. The compiler was used in "balanced" mode.

To compare the performance of the two divider implementations, both Timing and Power analyses were performed.

### Timing Analysis

The Timing Analysis was conducted to determine the maximum operating frequency for both implementations of the divider that satisfies the setup and hold constraints of the registers. The clock period was specified using a dedicated .sdc file and progressively reduced until one of the constraints was violated.

![Image](https://github.com/user-attachments/assets/85894cfb-09b6-4698-a4ae-1433c0b0ddfd)

![Image](https://github.com/user-attachments/assets/d210e0a6-c9df-4848-88d2-91645f58371c)

As expected, the combinational divider requires a significantly longer clock period compared to the serial implementation—though it completes the operation in a single cycle. This is because the combinational division block consists of many more logic elements than its serial counterpart.

To satisfy the setup constraint (evaluated under worst-case conditions: slow corner, 1V, 85°C), the combinational divider requires a minimum clock period of 73 ns, whereas the serial divider operates correctly with a minimum period of just 7 ns.


## 🔋 Power Analysis

Power analysis was performed using both a fixed activity factor and one derived from input transitions in the testbench. The results align with theoretical expectations:

- **Dynamic Power (`core dynamic`)**:  
  Higher in the **serial** divider due to its direct dependency on clock frequency. The same applies to **clock control** power.

- **Static Power (`core static`)**:  
  Similar in both versions, as it does not depend on clock frequency but is sensitive to temperature.

- **Combinational Logic Power (`combinational cell`)**:  
  Significantly higher in the **combinatorial** divider, due to the larger number of logic elements and increased toggle rate.

> **Conclusion:**  
> The **combinatorial** divider consumes more power *per cycle*, but the **serial** divider requires *more cycles* to complete a division.  
> 🧮 **Result:** Total energy consumption per operation is **higher in the serial implementation**.


![Image](https://github.com/user-attachments/assets/fb465116-1758-4952-8652-5963c4c1437a)

![Image](https://github.com/user-attachments/assets/94a7f03e-ac50-4a50-8e69-3a223eb11d57)
