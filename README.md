# SAP-1+ Enhanced 8-Bit Processor on AMD Spartan-7 FPGA
# 🖥️ 8-Bit SAP Computer on FPGA
### Simple As Possible (SAP-1) Architecture — Implemented in Verilog HDL

[![Verilog](https://img.shields.io/badge/HDL-Verilog--2001-blue?style=for-the-badge&logo=v&logoColor=white)](https://en.wikipedia.org/wiki/Verilog)
[![FPGA](https://img.shields.io/badge/FPGA-Xilinx%20Spartan--7-orange?style=for-the-badge&logo=xilinx&logoColor=white)](https://www.xilinx.com/)
[![Board](https://img.shields.io/badge/Board-Boolean%20XC7S50-red?style=for-the-badge)](https://www.realdigital.org/hardware/boolean)
[![Tool](https://img.shields.io/badge/Tool-Vivado%202023-green?style=for-the-badge&logo=xilinx)](https://www.xilinx.com/products/design-tools/vivado.html)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

<br>

## Overview

This project presents the design and implementation of an enhanced SAP (Simple-As-Possible) 8-bit processor using Verilog HDL on the AMD Spartan-7 XC7S50-CSGA324-1 FPGA (Boolean Board).

The processor follows a shared-bus SAP architecture and extends the traditional SAP-1 design by integrating a 12-operation Arithmetic Logic Unit (ALU), Carry and Zero flag generation, programmable memory, and hardware visualization through LEDs and seven-segment displays.

---

<img width="1536" height="1024" alt="ChatGPT Image Jun 20, 2026, 04_26_37 AM" src="https://github.com/user-attachments/assets/e2306edd-489c-4814-b952-752163eab75c" />


## Key Features

* 8-bit datapath
* Shared bus architecture
* 16 instruction opcodes
* 12 ALU operations
* Carry and Zero flags
* Program Counter (PC)
* Memory Address Register (MAR)
* Instruction Register (IR)
* Accumulator (A Register)
* B Register
* Output Register
* Control Unit
* FPGA implementation on Spartan-7
* Vivado simulation and synthesis
---
<img width="1536" height="1024" alt="ChatGPT Image Jun 18, 2026, 04_54_40 PM" src="https://github.com/user-attachments/assets/8d5244a0-d54a-4ae3-a13e-26bdea95a819" />

## Target FPGA

Board: Boolean FPGA Development Board

FPGA Device:
XC7S50-CSGA324-1

Vendor:
AMD Xilinx Spartan-7

---

## 🧩 Module Summary

| Module | File | Type | Description |
|---|---|:---:|---|
| **Top Level** | `sapp_computer.v` | Structural | Instantiates all modules, W-bus |
| **ALU** | `alu.v` | Combinational | ADD / SUB, carry & zero flags |
| **Program Counter** | `pc.v` | Sequential | 4-bit, increment / jump load |
| **MAR** | `mar.v` | Sequential | Holds memory address for RAM |
| **RAM** | `ram.v` | Sequential | 16×8 program + data memory |
| **IR** | `ir.v` | Sequential | Splits opcode [7:4] + addr [3:0] |
| **Register A** | `reg_a.v` | Sequential | Accumulator, drives W-bus |
| **Register B** | `reg_b.v` | Sequential | Second ALU operand |
| **Output Reg** | `out_reg.v` | Sequential | Latches result → 8 LEDs |
| **Control Unit** | `control_unit.v` | FSM | Generates all control signals |
| **Clock Divider** | `clk_div.v` | Sequential | 100 MHz → 1 Hz for LED demo |

---

## Instruction Set

| Opcode | Mnemonic | Function               |
| ------ | -------- | ---------------------- |
| 0x0    | NOP      | No Operation           |
| 0x1    | LDA      | Load Accumulator       |
| 0x2    | ADD      | Addition               |
| 0x3    | SUB      | Subtraction            |
| 0x4    | ANA      | AND                    |
| 0x5    | XRA      | XOR                    |
| 0x6    | ORA      | OR                     |
| 0x7    | CMA      | Complement Accumulator |
| 0x8    | INR      | Increment              |
| 0x9    | DCR      | Decrement              |
| 0xA    | SHL      | Shift Left             |
| 0xB    | SHR      | Shift Right            |
| 0xC    | NAND     | NAND                   |
| 0xD    | NOR      | NOR                    |
| 0xE    | OUT      | Output                 |
| 0xF    | HLT      | Halt                   |

---

## ALU Operations

ADD,
SUB,
AND,
XOR,
OR,
NOT,
INC,
DEC,
SHL,
SHR,
NAND,
NOR,

---

## Processor Execution Flow

Fetch Cycle

T0:
MAR ← PC

T1:
PC ← PC + 1

T2:
IR ← RAM[MAR]

Execute Cycle

T3:
Operand Decode

T4:
Operand Fetch

T5:
ALU Execution / Register Update

---
<img width="1536" height="1024" alt="ChatGPT Image Jun 18, 2026, 05_34_18 PM" src="https://github.com/user-attachments/assets/22a9627b-3e68-4ea1-bd89-a8f7fcbd9e67" />

## Flags

* Carry Flag (C)

* Generated when arithmetic overflow occurs.

* Zero Flag (Z)

* Generated when ALU result equals zero.

---

## FPGA Outputs

* LED[7:0]      : Output Register

* LED[10:8]     : T-State Counter

* LED[11]       : Carry Flag

* LED[12]       : Zero Flag

* LED[15:13]    : Current Opcode

---
<img width="1641" height="838" alt="Screenshot 2026-06-20 012048" src="https://github.com/user-attachments/assets/f23033c8-604f-4dd0-9a1a-b8963934cf45" />

## Development Tools

* Vivado Design Suite

* Language:
Verilog HDL

* Target Device:
XC7S50-CSGA324-1

* Simulation:
Vivado Simulator

* Synthesis:
Vivado Synthesis

* Implementation:
Vivado Implementation Flow

* Bitstream Generation:
Vivado Bitstream Generator

---

## Future Enhancements

* Conditional Branching

* Jump Instructions

* Memory Write Support

* UART Interface

* Custom Assembler

* Pipeline Architecture

---

