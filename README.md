# Thesis: Analysis of Performance and Verification of Real-Time Operating System on RISC-V Architecture

## Overview
This repository contains the complete work for my bachelor's thesis, focused on analyzing the performance and verifying the functionality of the FreeRTOS real-time operating system on the open RISC-V instruction set architecture. The work combines theoretical analysis, practical simulation-based experimental evaluation, and insights from hardware implementation efforts.

## Repository Structure

### `/docs/` - Theoretical Work & Thesis Document
- Complete literature review on RTOS and RISC-V architecture.
- Theoretical framework for real-time systems analysis.
- Mathematical models for performance evaluation.
- All finalized thesis chapters and drafts.

### `/hardware/` - Hardware Implementation & Verification Insights
- **PicoRV32 RISC-V Core**: Details on the custom RISC-V processor (PicoRV32) considered/implemented.
- **Tang Nano 9K FPGA**: Documentation related to the hardware verification platform used for implementation attempts.
- Insights into synthesis results and timing analysis, and hardware-software co-integration challenges.
- Relevant hardware documentation (if available, e.g., memory map diagrams for FPGA SoC).

### `/simulator/` - FreeRTOS Simulation & Benchmarking
- FreeRTOS port for RISC-V (configured for QEMU).
- Custom task scheduling and performance measurement code for FreeRTOS primitives.
- Real-time system test scenarios implemented for controlled environments.
- Scripts and configurations for QEMU emulation setup.

### `/analysis/` - Data Processing & Visualization
- Python scripts for automated performance data processing and parsing from UART logs.
- Statistical analysis of collected real-time metrics (latency, WCET, jitter).
- Visualization tools (e.g., Matplotlib) and generated graphs (box plots, histograms).
- Processed experimental results and comparative analysis data.

### `/results/` - Experimental Results & Conclusions
- Raw and processed performance measurement data.
- Charts and tables summarizing comparative analysis.
- Detailed functional verification outcomes.
- Final conclusions, recommendations, and identified future work directions.

## Current Status

### ✅ Completed
- [x] **Thesis Chapters 1-4 completed and reviewed.**
- [x] Comprehensive literature review and theoretical framework established.
- [x] Basic hardware verification (PicoRV32 core) on Tang Nano 9K FPGA executed, providing valuable insights.
- [x] Initial setup and configuration of FreeRTOS for RISC-V in QEMU.
- [x] Development and implementation of specific FreeRTOS performance test scenarios in QEMU.
- [x] Automated performance data collection and processing via Python scripts.
- [x] Detailed statistical analysis of collected performance metrics (latency, WCET, jitter).
- [x] Functional verification of FreeRTOS features through demonstrative applications.

### 🚧 In Progress  
- [ ] Integration of current findings and results into the main thesis document (Chapters 5 onwards).
- [ ] Comprehensive discussion and interpretation of all experimental results (ongoing refinement of Chapter 5).
- [ ] Formulation of practical implications and design recommendations based on findings (Chapter 5.6 is largely done, but may need final polish).

### 📋 Planned
- [ ] Final refinement and completion of remaining thesis chapters (including Conclusion, Future Work, Appendices).
- [ ] Final presentation preparation.

## Key Achievements

1.  **Robust Theoretical Foundation**: Established a comprehensive theoretical framework for RTOS analysis on RISC-V, covering key concepts and existing research.
2.  **Controlled Simulation Environment**: Successfully set up and configured a reproducible FreeRTOS-on-RISC-V simulation environment using QEMU for precise performance measurement.
3.  **Hardware Implementation Insights**: Gained practical experience and identified key challenges during the attempt to implement and verify the PicoRV32 RISC-V core on the Tang Nano 9K FPGA.
4.  **Automated Performance Analysis Pipeline**: Designed a system for automated data collection and initial processing of real-time performance metrics, including detailed statistical analysis and functional verification.

## Technologies Used
- **Hardware Platforms**: Tang Nano 9K FPGA, RISC-V Cores (e.g., PicoRV32).
- **Operating System**: FreeRTOS.
- **Programming Languages**: C/C++, Python.
- **Development & Simulation Tools**: QEMU, RISC-V GCC toolchain, FPGA synthesis tools (e.g., Gowin IDE), GDB.
- **Analysis & Visualization Libraries**: Python (e.g., Matplotlib, Pandas, PySerial).

## Research Objectives
- Quantify key real-time performance characteristics of FreeRTOS on RISC-V architecture in a controlled environment.
- Determine empirical Worst-Case Execution Time (WCET) for critical RTOS primitives.
- Verify core FreeRTOS functionalities through practical demonstrations.
- Provide practical recommendations for optimizing RTOS performance on RISC-V platforms.
- Contribute insights into the challenges and complexities of hardware-software co-integration for RISC-V based embedded systems.

---
*This work represents ongoing research into real-time systems performance on RISC-V architecture, contributing to the understanding of embedded systems design and optimization for critical applications.*
