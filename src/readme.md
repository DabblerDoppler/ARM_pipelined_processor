```markdown
# Gate-Level 5-Stage Pipelined CPU (12-Instruction Subset)

This project implements a 64-bit, 5-stage pipelined processor entirely in SystemVerilog using gate-level design. All components — from control logic to data hazard forwarding — are built from basic logic gates and multiplexers. No behavioral modeling or high-level synthesis tools were used.

## Instruction Set

The CPU supports a 12-instruction subset of the ARMv8-A architecture, including:

- Arithmetic: `ADD`, `ADDI`, `SUB`, `SUBI`
- Logical: `AND`, `ORR`
- Comparison: `SUBS`
- Memory: `LDUR`, `STUR`
- Branch: `B`, `CBZ`, `CBNZ`

## Pipeline Stages

- **IF** – Instruction Fetch  
- **RF** – Register Fetch (renamed from Decode to match internal code naming)  
- **EX** – Execute  
- **MEM** – Memory Access  
- **WB** – Writeback

## Key Features

- **Gate-Level Construction**: All control logic (e.g., muxes, decoders, equality checkers) built manually using gates.
- **Data Hazard Handling**: Full forwarding logic from EX, MEM, and WB stages to RF stage for both source operands.
- **Register File**: 32 general-purpose registers with proper handling of `X31` as a zero-register.
- **Control Signals**: Custom control unit determines branching, memory operations, and ALU behavior.
- **Simulation-Ready**: Includes waveform simulations of data forwarding, memory load/store operations, and pipeline behavior.

## Example Programs

The `/test/` directory contains hand-assembled programs with instruction memory images and expected output.

Example sequence:
```armasm
ADDI X3, X31, #5      // X3 = 5
ADDI X4, X3, #2       // X4 = 7
SUBS X5, X4, X3       // X5 = 2
STUR X5, [X31, #0]    // Store X5 to address 0
LDUR X6, [X31, #0]    // Load from address 0 to X6
```

This sequence tests register forwarding, memory access, and ALU operations in a data-dependent chain.

## File Structure

```
/src/               # Core modules (ALU, register file, control logic, etc.)
/test/              # Sample programs and simulation input/output
/doc/               # Technical report and diagrams
cpu.sv              # Top-level module
```

## Build & Simulate

Simulation requires a SystemVerilog-compatible simulator such as ModelSim, VCS, or Icarus Verilog (if gate-level modules are adapted).

Basic simulation flow:
1. Load `cpu.sv` and relevant modules.
2. Initialize instruction memory with test program.
3. Run simulation and verify waveform output.

## Author Notes

This project was completed for a computer architecture course under strict constraints disallowing any behavioral abstraction or premade IP blocks. Forwarding logic, branching, and memory behavior were developed and debugged entirely at the signal and gate level.
```