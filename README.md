# Thesis: Analysis of Performance and Verification of Real-Time Operating System on RISC-V Architecture

## Overview
This repository contains the complete work for my bachelor's thesis on analyzing performance and verifying real-time operating systems on RISC-V architecture. The work combines theoretical analysis, hardware implementation, and experimental evaluation.

## Repository Structure

### `/docs/` - Theoretical Work
- Complete literature review on RTOS and RISC-V architecture
- Theoretical framework for real-time systems analysis
- Mathematical models for performance evaluation
- Final thesis document and drafts

### `/hardware/` - Hardware Implementation
- **PicoTiny RISC-V Core**: Custom RISC-V processor implementation
- **Tang Nano 9K FPGA**: Hardware verification platform
- Synthesis results and timing analysis
- Hardware documentation and schematics

### `/simulator/` - Software Analysis
- FreeRTOS Windows simulator implementation
- Task scheduling and performance measurement code
- Real-time system test scenarios
- Timing analysis and benchmarking tools

### `/analysis/` - Data Analysis
- Python scripts for performance data processing
- Statistical analysis of real-time metrics
- Visualization tools and generated graphs
- Experimental results and comparisons

### `/results/` - Experimental Results
- Performance measurement data
- Comparative analysis charts
- Hardware verification results
- Final conclusions and recommendations

## Current Status

### ✅ Completed
- [x] Literature review and theoretical framework
- [x] PicoTiny RISC-V core hardware implementation
- [x] Basic hardware verification on FPGA
- [x] Theoretical analysis of RTOS performance

### 🚧 In Progress  
- [ ] FreeRTOS simulator setup and implementation
- [ ] Performance measurement and data collection
- [ ] Python analysis scripts development
- [ ] Final thesis document completion

### 📋 Planned
- [ ] Comprehensive performance evaluation
- [ ] Hardware vs software comparison
- [ ] Final presentation preparation

## Key Achievements

1. **Hardware Verification**: Successfully implemented and verified PicoTiny RISC-V core on Tang Nano 9K FPGA
2. **Theoretical Foundation**: Established comprehensive theoretical framework for RTOS analysis on RISC-V
3. **Practical Implementation**: Developing FreeRTOS-based performance analysis tools

## Technologies Used
- **Hardware**: Tang Nano 9K FPGA, PicoTiny RISC-V Core
- **Software**: FreeRTOS, Python, C/C++
- **Tools**: FPGA synthesis tools, GCC RISC-V toolchain, QEMU
- **Analysis**: Python (matplotlib, pandas), statistical analysis

## Research Objectives
- Analyze real-time performance characteristics of RISC-V architecture
- Compare theoretical models with practical implementations  
- Evaluate FreeRTOS performance on RISC-V platforms
- Provide recommendations for RISC-V RTOS optimization

---
*This work represents ongoing research into real-time systems performance on RISC-V architecture, contributing to the understanding of embedded systems design and optimization.*
