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

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/602119dc-a94c-4c60-b48f-0e2881b630e6" />



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
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/7df82aec-950b-4daf-917d-11a028a27fa2" />


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
| 0x5    | STA      | Store                  |
| 0x6    | ORA      | OR                     |
| 0x7    | CMA      | Complement Accumulator |
| 0x8    | INR      | Increment              |
| 0x9    | DCR      | Decrement              |
| 0xA    | SHL      | Shift Left             |
| 0xB    | SHR      | Shift Right            |
| 0xC    | JMP      | Jump                   |
| 0xD    | JC       | Jump if carry          |
| 0xE    | OUT      | Output                 |
| 0xF    | HLT      | Halt                   |

---
<img width="1086" height="670" alt="image" src="https://github.com/user-attachments/assets/6e9ff684-ca62-4847-ad52-dcb1a0244068" />

## ALU Operations

ADD,
SUB,
AND,
STA,
OR,
NOT,
INC,
DEC,
SHL,
SHR,
JMP,
JC,

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
<img width="1535" height="1024" alt="image" src="https://github.com/user-attachments/assets/97e4348f-f764-4844-8fe3-22c654da7cf0" />


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
<img width="1145" height="978" alt="image" src="https://github.com/user-attachments/assets/7b358ac0-bb2b-41b3-ba90-271c3b74109b" />


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

## Output waveform
<img width="1919" height="1011" alt="Screenshot 2026-06-20 003701 (1)" src="https://github.com/user-attachments/assets/707c8386-a5ee-419e-8711-31c05adda6ca" />
<img width="1919" height="827" alt="Screenshot 2026-06-20 003717 (1)" src="https://github.com/user-attachments/assets/f4053b88-5aab-462c-a5a4-4c2a102ca9e8" />
<img width="1919" height="1014" alt="Screenshot 2026-06-20 003710" src="https://github.com/user-attachments/assets/f97bb5f4-6675-4c0f-aeda-1a4e136b0015" />

## Live Hardware Demo

<p align="center">
  <img src="Videos/Outout video.gif" width="700">
</p>

## Design timing Summary
<img width="1027" height="266" alt="WhatsApp Image 2026-06-20 at 1 56 41 PM" src="https://github.com/user-attachments/assets/0f694637-708b-40ed-bb0b-0b8f986bec71" />


## Current Advancement 
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/552b66c1-436e-4a42-9e6c-9c9eccad69aa" />


## Future Enhancements

* Sensor Intergration

* Jump Instructions

* Memory Write Support

* UART Interface

* Custom Assembler

* Pipeline Architecture

---

## Contributors

- [Rahul Sivesh S](https://github.com/Rahul-Sivesh)
- [Praaveen Hari GS](https://github.com/Praaveen007)
- [Indrapriyadharshani MG](https://github.com/INDRA2006MG)
