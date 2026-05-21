module hdmi_backend_640
   import hdmi_pkg::*;
(
   input  logic   clk_ext,
   output logic   clk_pix,
   output logic   srst_n,

   output bus12_t hcount,
   output bus12_t vcount,
   input  pix_t   pix,

   output logic   frame_done,
   output logic   mfram_done,

   output logic   hdmi_clk_p,
   output logic   hdmi_clk_n,
   output bus3_t  hdmi_dat_p,
   output bus3_t  hdmi_dat_n,

   output logic   video_on
);

   localparam int HFRAME         = 800;
   localparam int HSCREEN        = 640;
   localparam int HSYNC_START    = 656;
   localparam int HSYNC_END      = 752;
   localparam bit HSYNC_POLARITY = LO;

   localparam int VFRAME         = 525;
   localparam int VSCREEN        = 480;
   localparam int VSYNC_START    = 490;
   localparam int VSYNC_END      = 492;
   localparam bit VSYNC_POLARITY = LO;

   logic clk_pix5;
   logic hsync;
   logic vsync;
   logic blank;
   logic frame_done0;
   mfram_cnt_t mfram_cnt;

   fpga_pll_640 u_fpga_pll (
      .clk_ext  (clk_ext),
      .srst_n   (srst_n),
      .clk_pix5 (clk_pix5),
      .clk_pix  (clk_pix)
   );

   assign frame_done0 = (hcount == HSCREEN) & (vcount == VSCREEN);
   assign video_on = ~blank;

   always_ff @(negedge srst_n or posedge clk_pix) begin
      if (!srst_n) begin
         hcount     <= '0;
         vcount     <= '0;
         hsync      <= LO;
         vsync      <= LO;
         blank      <= HI;
         frame_done <= LO;
         mfram_done <= LO;
         mfram_cnt  <= '0;
      end else begin
         if (hcount == HFRAME - 1) begin
            hcount <= '0;
            if (vcount == VFRAME - 1) begin
               vcount <= '0;
            end else begin
               vcount <= 12'(vcount + 12'(1));
            end
         end else begin
            hcount <= 12'(hcount + 12'(1));
         end

         if ((hcount >= HSYNC_START) && (hcount < HSYNC_END)) begin
            hsync <= HSYNC_POLARITY;
         end else begin
            hsync <= ~HSYNC_POLARITY;
         end

         if ((vcount >= VSYNC_START) && (vcount < VSYNC_END)) begin
            vsync <= VSYNC_POLARITY;
         end else begin
            vsync <= ~VSYNC_POLARITY;
         end

         blank <= (hcount >= HSCREEN) | (vcount >= VSCREEN);

         frame_done <= frame_done0;
         mfram_done <= frame_done0 & (mfram_cnt == MFRAM_CNT_MAX - 1);

         if (mfram_done) begin
            mfram_cnt <= '0;
         end else if (frame_done) begin
            mfram_cnt <= mfram_cnt_t'(mfram_cnt + mfram_cnt_t'(1));
         end
      end
   end

   logic      srst;
   tdms_pix_t tdms_pix;
   tdms_pix_t tdms_enc;
   bus3_t     tdms_sdat;
   logic      tdms_sclk;

   always_comb begin
      srst = ~srst_n;
      tdms_pix[2].c = '0;
      tdms_pix[1].c = '0;
      tdms_pix[0].c = {vsync, hsync};

      tdms_pix[2].d = pix.R;
      tdms_pix[1].d = pix.G;
      tdms_pix[0].d = pix.B;
   end

   for (genvar i = 0; i < 3; i++) begin: tmds_data
      hdmi_tdms_enc u_tmds (
         .clk     (clk_pix),
         .blank   (blank),
         .raw     (tdms_pix[i]),
         .encoded (tdms_enc[i])
      );

      fpga_oser10 u_oser_dat (
         .arst    (srst),
         .clk_par (clk_pix),
         .clk_ser (clk_pix5),
         .d       (tdms_enc[i]),
         .q       (tdms_sdat[i])
      );

      fpga_olvds u_obuf_dat (
         .i       (tdms_sdat[i]),
         .o       (hdmi_dat_p[i]),
         .ob      (hdmi_dat_n[i])
      );
   end

   fpga_oser10 u_oser_clk (
      .arst    (srst),
      .clk_par (clk_pix),
      .clk_ser (clk_pix5),
      .d       (10'b00000_11111),
      .q       (tdms_sclk)
   );

   fpga_olvds u_obuf_clk (
      .i       (tdms_sclk),
      .o       (hdmi_clk_p),
      .ob      (hdmi_clk_n)
   );

endmodule
