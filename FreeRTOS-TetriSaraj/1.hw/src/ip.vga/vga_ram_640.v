
// 640x480 variant of vga_ram.
// 16 characters of 16x16 pixels @ 12bpp = 4096 words, vs 12288 for 1280x720.
// The smaller character RAM is what lets the combined FreeRTOS + HDMI top fit
// the Tang Nano 9K BSRAM budget.
module vga_ram_640 (
    input clk,
	input wen,
	input [11:0] waddr,
	input [11:0] wdata,
    input ren,
	input [11:0] raddr,
    output reg [11:0] rdata
);
	(* ram_style = "block" *) reg [11:0] ram [0:4095];   // 16 chars x 16x16 px @ 12bpp

    always @(posedge clk)
	begin
		if (ren)
			rdata <= ram[raddr];
	end

    always @(posedge clk)
	begin
		if (wen)
			ram[waddr] <= wdata;
    end

endmodule
