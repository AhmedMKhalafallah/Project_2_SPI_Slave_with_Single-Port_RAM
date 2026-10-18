# SPI Slave with Single-Port RAM: Verilog Design & FPGA Implementation

Verilog HDL implementation of an SPI Slave integrated with a Single-Port RAM. The project combines sequential and combinational logic to handle SPI communication, decode read and write commands, and coordinate data transfers between the SPI interface and memory.

The design was simulated using QuestaSim and evaluated through the Vivado FPGA design flow, including FSM encoding comparison, timing analysis, and implementation.
[![Project report](cover.png)](SPI_Slave_RAM_Project_Report.pdf)

**[Open the full project report (PDF)](DSP48A1_Project_Report.pdf)**
## Project Overview

The SPI Slave communicates with an SPI Master through the SPI interface signals. An FSM controls the communication sequence, identifies read and write operations, and coordinates memory access.

The project focuses on integrating the communication protocol, control logic, and memory into a single digital system.

## Key Features

- SPI Slave interface implemented using Verilog HDL.
- Single-Port RAM integration for data storage and retrieval.
- FSM-based control of SPI communication and memory access.
- Read and write command handling.
- Sequential and combinational logic integration.
- Comparison of three FSM encoding techniques:
  - Sequential (Binary)
  - Gray
  - One-Hot
- Timing analysis to evaluate the implementation results of different FSM encodings.

## Repository Contents

| Folder / File | Description |
|---|---|
| `RTL/` | Verilog source files for the design modules. |
| `Testbench/` | Testbench files used to simulate the design. |

*Folder names may vary depending on the final repository structure.*

## Design Flow

1. **RTL Design:** Implement the SPI Slave, RAM interface, and FSM control logic using Verilog HDL.
2. **Simulation:** Use QuestaSim to simulate SPI transactions and inspect the relevant signal waveforms.
3. **Linting:** Check the RTL for linting issues.
4. **Synthesis:** Run Vivado synthesis and compare the results for different FSM encodings.
5. **Implementation:** Analyze FPGA resource utilization and timing reports to evaluate the implemented design.
6. **FSM Encoding Comparison:** Compare Sequential, Gray, and One-Hot encodings using the resulting implementation and timing reports.

## Verification Through Simulation

The testbench is used to exercise the SPI communication flow, including writing data to RAM and reading data back through the SPI interface.

Simulation waveforms and additional project evidence are available in the project report.

## Tools & Technologies

- **HDL:** Verilog
- **Simulation:** Siemens QuestaSim
- **FPGA Design & Implementation:** AMD/Xilinx Vivado
- **Design Analysis:** RTL Linting, Synthesis Reports, Timing Analysis, and FPGA Resource Utilization

## Project Report

See the full PDF report for the RTL design, testbench, simulation waveforms, linting results, synthesis and implementation reports, and FSM encoding comparisons.

**Project Type:** Collaborative Team Project
## Team Members

- [Ahmed M. Khalafallah](ضع-لينك-LinkedIn-هنا)
