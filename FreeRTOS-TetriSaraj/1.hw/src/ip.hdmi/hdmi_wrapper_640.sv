///////////////////////////////////////////////////////////////////////////////
// 640x480 variant of hdmi_wrapper.
//
// Identical structure to hdmi_wrapper.sv, but uses the 640x480 back-end and the
// smaller 16x16 character RAM (vga_ram_640). This shrinks the video character
// memory from 12288 to 4096 words so the combined FreeRTOS + HDMI top fits the
// Tang Nano 9K BSRAM budget.
//
// Address maps for 640x480 (40x30 mega-characters of 16x16 px):
//   read_address     = {map_rdata[3:0], y[3:0], x[3:0]}     (12-bit, 0..4095)
//   map_read_address = (y >> 4) * 40 + (x >> 4)             (12-bit, 0..1199)
///////////////////////////////////////////////////////////////////////////////

module hdmi_wrapper_640
   import hdmi_pkg::*;
(
   input  logic  clk_ext, // External clock: GoWin=27MHz
   input  logic  clk,
   input  logic  reset,

   output logic vga_iomem_ready,
   input logic iomem_valid,
   input logic iomem_ready,
   input [3:0]  iomem_wstrb,
   input [31:0] iomem_addr,
   input [31:0] iomem_wdata,

   output logic  hdmi_clk_p,
   output logic  hdmi_clk_n,
   output bus3_t hdmi_dat_p,
   output bus3_t hdmi_dat_n
);

   logic   clk_pix;
   logic   srst_n;
   logic   frame_done;
   logic   mfram_done;

   bus12_t x, y;
   pix_t   pix;

   logic video_on;

	// signal declarations
	reg char_mem_write, map_mem_write;
	wire [11:0] write_address;
	wire [11:0] map_read_address;
	wire [11:0] read_address;
	wire [11:0] rgb_rdata;
	wire [3:0] map_rdata;

	always @(posedge clk)
	begin
		if (reset) begin
			char_mem_write <= 0;
			map_mem_write <= 0;
		end else begin
			vga_iomem_ready <= 0;
			char_mem_write <= 0;
			map_mem_write <= 0;
			if (iomem_valid && !iomem_ready) begin
				vga_iomem_ready <= 1;
				if(iomem_addr[23:20]==4'h1) begin
					if(iomem_wstrb[0]) begin
						char_mem_write <= 1;
					end
				end else if(iomem_addr[23:20]==4'h2) begin
					if(iomem_wstrb[0]) begin
						map_mem_write <= 1;
					end
				end
			end
		end
	end

	assign write_address = iomem_addr[13:2];                       // word address (mod 4096)
	// Both RAMs are read on the pixel clock (write port stays on the CPU clock),
	// so the video read path never crosses from the 27 MHz domain into the TMDS
	// encoder. The map RAM output is one pixel clock behind (x, y); delay the
	// in-tile x/y by the same amount so they index the tile that map_rdata names.
	// The picture ends up shifted right by ~2 pixels (map + char RAM latency).
	logic [3:0] x_d, y_d;
	always_ff @(posedge clk_pix) begin
		x_d <= x[3:0];
		y_d <= y[3:0];
	end

	assign read_address = {map_rdata, y_d, x_d};                  // for 640x480
	assign map_read_address = (y >> 4) * 6'd40 + ( x >> 4 );      // for 640x480

	vga_map_ram map(
		.clk(clk),
		.rclk(clk_pix),
		.wen(map_mem_write),
		.waddr(write_address),
		.wdata(iomem_wdata[3:0]),
		.ren(1'b1),
		.raddr(map_read_address),
		.rdata(map_rdata)
	);

	vga_ram_640 ram(
		.clk(clk),
		.rclk(clk_pix),
		.wen(char_mem_write),
		.waddr(write_address),
		.wdata(iomem_wdata[11:0]),
		.ren(1'b1),
		.raddr(read_address),
		.rdata(rgb_rdata)
	);

    // rgb multiplexing circuit
    always @(*)
	begin
        if(~video_on)
            pix = 24'h000000;      // blank
        else
            pix[23:20] = rgb_rdata[11:8];   // R[3:0]
            pix[19:16] = 4'b0000;
            pix[15:12] = rgb_rdata[7:4];    // G[3:0]
            pix[11:8]  = 4'b0000;
            pix[7:4]   = rgb_rdata[3:0];    // B[3:0]
            pix[3:0]   = 4'b0000;
	end

//-----------------------------------------------------------
// HDMI Backend: 640x480 display renderer
//-----------------------------------------------------------
   hdmi_backend_640 u_hdmi_backend (
      .clk_ext    (clk_ext),    //i
      .clk_pix    (clk_pix),    //o
      .srst_n     (srst_n),     //o

      .hcount     (x),          //o[11:0]
      .vcount     (y),          //o[11:0]
      .pix        (pix),        //i[7:0].R/G/B

      .frame_done (frame_done), //o
      .mfram_done (mfram_done), //o

      .hdmi_clk_p (hdmi_clk_p), //o
      .hdmi_clk_n (hdmi_clk_n), //o
      .hdmi_dat_p (hdmi_dat_p), //o[2:0]
      .hdmi_dat_n (hdmi_dat_n), //o[2:0]

      .video_on   (video_on)
   );

endmodule: hdmi_wrapper_640
