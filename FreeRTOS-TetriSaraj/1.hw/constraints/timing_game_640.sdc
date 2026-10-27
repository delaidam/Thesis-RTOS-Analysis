#=======================================
# Timing Constraints file -- freertos_game_640 (HDMI 640x480)
#
# Same as timing.sdc plus the clocks derived inside hdmi_backend_640:
#   27 MHz -> rPLL (x14/3) -> 126 MHz serial clock (clk_pix5)
#          -> CLKDIV /5    -> 25.2 MHz pixel clock (clk_pix)
# Kept in a separate file because the hierarchical pin names below do not exist
# in the other tops that share timing.sdc.
#=======================================

# 37ns = 27MHz, which is the frequency of external XTAL oscillator
create_clock -name clk_27 -period 37.037 -waveform {0 18.518} [get_ports {clk_27}]

create_generated_clock -name clk_pix5 -source [get_ports {clk_27}] -master_clock clk_27 -multiply_by 14 -divide_by 3 [get_pins {video/u_hdmi_backend/u_fpga_pll/u_pll/CLKOUT}]
create_generated_clock -name clk_pix -source [get_pins {video/u_hdmi_backend/u_fpga_pll/u_pll/CLKOUT}] -master_clock clk_pix5 -divide_by 5 [get_pins {video/u_hdmi_backend/u_fpga_pll/u_clkdiv/CLKOUT}]

#___End-of-File
