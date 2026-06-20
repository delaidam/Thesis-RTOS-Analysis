# FreeRTOS-TetriSaraj

This work builds on top of:

1) [TetriSaraj-Tango](https://github.com/chili-chips-ba/openXC7-TetriSaraj/tree/main/99.more-boards/0.tang-nano-9k) project, authored by @juninho99
2) [openXC-TetriSaraj](https://github.com/chili-chips-ba/openXC7-TetriSaraj), authored by @kerimbavcic and @harunkovacevic 

It aims to convert the game algorithm from baremetal 'C' application to hosted framework.

### Project Continuation

This repository was initially started with a very concrete academic goal: to
complete the FreeRTOS-hosted version of TetriSaraj in time for Delaida's
Bachelor thesis. In the usual real-project fashion, we slipped past that formal
deadline. The work, however, did not stop there. It is now realized as a
standalone project, with the HW, SW, measurements and documentation kept here in
the open.

The original TetriSaraj version is a bare-metal C application running on a small
RISC-V soft-core system. This continuation keeps that implementation as the
reference point, and moves the game toward a FreeRTOS structure. The game logic
was separated from direct platform access, while UART, GPIO/buttons and video
memory access were moved into a small platform layer. On top of that, the
application was reorganized around FreeRTOS tasks for input sampling, game-state
updates, rendering and debug/status output.

The first proof was intentionally headless. Instead of trying to debug the RTOS
port and HDMI rendering at the same time, the game loop was first executed under
FreeRTOS and observed over UART. That proved that the scheduler runs, the tasks
communicate, the falling piece advances, the field changes and the score updates
on real Tang Nano 9K hardware.

The next challenge was to fit FreeRTOS together with the video front-end into
the limited Tang Nano 9K resources. The initial combined design was blocked not
only by logic usage, but by block-RAM pressure. The solution came from two
directions: unused firmware sections were removed during linking, and a 640x480
video path was added so the Mega-Character video memory could fit in the
available BSRAM. A useful practical lesson was that Gowin synthesis behaves much
better when ROM and RAM depths remain powers of two.

The current path includes a FreeRTOS boot proof on PicoRV32/Tang Nano 9K, a
headless TetriSaraj game proof over UART, a fitting 640x480 FreeRTOS + HDMI
build, a firmware video initialization path adapted to 16x16 Mega-Characters,
and a hardware context-switch benchmark for the FreeRTOS port. The HDMI build
boots and the firmware reaches the video initialization code. The final visual
confirmation of the game image still depends on checking the monitor output, so
the milestone notes and UART captures are kept as evidence, and the claims stay
limited to what was actually measured or observed.

The current project documentation is available in
[`0.doc/dokumentacija/Glavna.pdf`](0.doc/dokumentacija/Glavna.pdf). The shorter
engineering trail is documented through milestone notes in `0.doc/`, especially
the FreeRTOS boot proof, the headless game proof, the 640x480 fit work, the
video initialization milestone and the context-switch benchmark. Run `make help`
for the current firmware, bitstream and flash targets.


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
