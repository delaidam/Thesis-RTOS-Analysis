module fpga_pll_640 (
   input  logic clk_ext,

   output logic srst_n,
   output logic clk_pix5,
   output logic clk_pix
);

   logic pll_lock;
   logic srst_n_pipe;

   // 27 MHz input -> about 126 MHz serial clock, divided by 5 to about
   // 25.2 MHz pixel clock. This is close to the standard 640x480p60 clock.
   rPLL #(
      .DEVICE           ("GW1NR-9C"),
      .FCLKIN           ("27"),
      .DYN_IDIV_SEL     ("false"),
      .IDIV_SEL         (2),
      .DYN_FBDIV_SEL    ("false"),
      .FBDIV_SEL        (13),
      .DYN_ODIV_SEL     ("false"),
      .ODIV_SEL         (4),
      .PSDA_SEL         ("0000"),
      .DYN_DA_EN        ("true"),
      .DUTYDA_SEL       ("1000"),
      .CLKOUT_FT_DIR    (1'b1),
      .CLKOUTP_FT_DIR   (1'b1),
      .CLKOUT_DLY_STEP  (0),
      .CLKOUTP_DLY_STEP (0),
      .CLKFB_SEL        ("internal"),
      .CLKOUT_BYPASS    ("false"),
      .CLKOUTP_BYPASS   ("false"),
      .CLKOUTD_BYPASS   ("false"),
      .DYN_SDIV_SEL     (2),
      .CLKOUTD_SRC      ("CLKOUT"),
      .CLKOUTD3_SRC     ("CLKOUT")
   )
   u_pll (
      .CLKOUT   (clk_pix5),
      .LOCK     (pll_lock),
      .CLKOUTP  (),
      .CLKOUTD  (),
      .CLKOUTD3 (),

      .RESET    (1'b0),
      .RESET_P  (1'b0),
      .CLKIN    (clk_ext),
      .CLKFB    (1'b0),
      .FBDSEL   ('0),
      .IDSEL    ('0),
      .ODSEL    ('0),
      .PSDA     ('0),
      .DUTYDA   ('0),
      .FDLY     ('0)
   );

   CLKDIV #(
      .DIV_MODE ("5"),
      .GSREN    ("false")
   )
   u_clkdiv (
      .CLKOUT   (clk_pix),
      .HCLKIN   (clk_pix5),
      .RESETN   (pll_lock),
      .CALIB    (1'b0)
   );

   always_ff @(negedge pll_lock or posedge clk_pix) begin
      if (!pll_lock) begin
         srst_n_pipe <= 1'b0;
         srst_n      <= 1'b0;
      end else begin
         srst_n_pipe <= 1'b1;
         srst_n      <= srst_n_pipe;
      end
   end

endmodule
