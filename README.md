# FreeRTOS-TetriSaraj

This work builds on top of:

1) [TetriSaraj-Tango](https://github.com/chili-chips-ba/openXC7-TetriSaraj/tree/main/99.more-boards/0.tang-nano-9k) project, authored by @juninho99
2) [openXC-TetriSaraj](https://github.com/chili-chips-ba/openXC7-TetriSaraj), authored by @kerimbavcic and @harunkovacevic 

It aims to convert the game algorithm from baremetal 'C' application to hosted framework.


### Additional references:

3) [Articles on real-time OSs](https://drive.google.com/file/d/1OIz4fVYDCALmUTbzGTsK-B_8oDVpLg37) based on FreeRTOS, by Simon Southwell
4) [FreeRTOS port to RV32 RISC-V ISS](https://github.com/wyvernSemi/riscV/tree/main/iss)
5) [TangNano9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) hardware platform
6) [GowinEDA](https://www.gowinsemi.com/en/support/download_eda) tools
7) [PicoRV32](https://github.com/YosysHQ/picorv32) RISC-V micro-controller
8) [FreeRTOS](https://www.freertos.org/Using-FreeRTOS-on-RISC-V) framework
9) [eduBOS5](https://fpga-ignite.github.io/presentations-pdf/presentation16.pdf) Bosnian RISC-V micro-controller

> Part 4 of Ref[3] discusses what was needed to port FreeRTOS to the **rv32** ISS, including the minimum HW requirements (very little---mostly an interrupt generating timer and a minimum set of CSR registers) and the configuring of the `FreeRTOSConfig.h` and `freertos_riscv_chip_specific_extensions.h` files. There is also a (simple) customised `crt0.S` file and information on compiling and linking FreeRTOS with a small demo program which runs two concurrent tasks. **rv32** has the option of using cycle counts as the basis of its internal timer or, as for the demo, a real-time counter returning microsecond counts, making the 1 second delays in the demo real-time, and the timer settings are scaled accordingly. So Part 4 of the document might be a good place to start and running the demo with **rv32**. All this should be applicable to _PicoRV32_, with just choosing memory sizes/locations, scaling settings for the specific timer (which can be derived from the system clock [if invariant] or a real-time clock) and enabling/disabling FreeRTOS features as required. The article's sub-section explains this sufficiently to make a start with _PicoRV32_ to, say, run the demo program. Some memory, a UART TX and a timer to generate a timer irq is all that's needed in addition to the processor for this demo.

**Delaida, this is just an initial seed -- You are free to add, delete, correct and indeed obliged to further build it.**

### Public postings
- [Kerim's MSEE work](https://www.linkedin.com/posts/kerim-bavcic_excited-to-share-that-i-have-completed-my-activity-7246625339408359424-6oHB/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAJv-TcBSi_5ff0VNMrInrT-xg44YF3jnyU) - First TetriSaraj academic appearance
- [TYRO BSEE project](https://www.linkedin.com/feed/update/urn:li:ugcPost:7316172259537113088?commentUrn=urn%3Ali%3Acomment%3A%28ugcPost%3A7316172259537113088%2C7320491750358220800%29&replyUrn=urn%3Ali%3Acomment%3A%28ugcPost%3A7316172259537113088%2C7320855089076719616%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287320491750358220800%2Curn%3Ali%3AugcPost%3A7316172259537113088%29&dashReplyUrn=urn%3Ali%3Afsd_comment%3A%287320855089076719616%2Curn%3Ali%3AugcPost%3A7316172259537113088%29) - Another TangNano9K academic appearance

#### End of Document
