// 640x480 combined FreeRTOS + HDMI top for Tang Nano 9K / PicoRV32.
//
// Same as top_freertos_game.v but tuned to fit the Tang Nano 9K BSRAM budget:
//   - the video front-end uses the 640x480 path (hdmi_wrapper_640), whose
//     character RAM is 4096 words instead of 12288 (saves BSRAM);
//   - the program ROM is sized to a power-of-two word depth by progmem.py, so
//     the gc-sections firmware (< 16 KB / 4096 words) claims 8 pROM blocks
//     instead of 16.
// All memory depths are kept power-of-two so Gowin infers BSRAM cleanly.
// Build firmware with APP=freertos_game_640 (gc-sections, 16 KB data RAM).
module top_freertos_game_640 (
    input clk_27,

    input btnL,
    input btnR,

    output [5:0] led_n,
    input uart_rx,
    output uart_tx,

    output hdmi_clk_p,
    output hdmi_clk_n,
    output [2:0] hdmi_dat_p,
    output [2:0] hdmi_dat_n
);
    wire clk = clk_27;

    reg [15:0] reset_counter = 16'd0;
    reg por_done = 1'b0;

    // Power-on reset only. S1 (btnL) is a game button (UP) in this top, so it
    // must not reset the CPU; reload the bitstream or power-cycle to restart.
    always @(posedge clk) begin
        if (!por_done) begin
            reset_counter <= reset_counter + 16'd1;
            por_done <= &reset_counter;
        end
    end

    wire resetn = por_done;

    wire iomem_valid;
    wire [3:0] iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    wire [31:0] iomem_rdata;
    wire iomem_ready;

    reg [31:0] timer_rdata;
    reg timer_ready;
    reg [31:0] timer_counter;
    reg timer_irq_enable;
    reg timer_irq_pending;
    reg [31:0] timer_irq_period;
    reg [31:0] timer_irq_countdown;
    reg [31:0] timer_irq_event_count;
    reg soft_irq;

    reg [31:0] gpio;
    reg [31:0] gpio_rdata;
    reg gpio_ready;
    wire vga_ready;

    wire timer_en = iomem_valid && (iomem_addr[31:24] == 8'h03);
    wire gpio_en = iomem_valid && (iomem_addr[31:24] == 8'h04);
    wire video_en = iomem_valid && (iomem_addr[31:24] == 8'h05);
    wire [4:0] buttons = {1'b0, 1'b0, btnL, btnR, 1'b0};

    assign iomem_ready = timer_en ? timer_ready :
                         gpio_en ? gpio_ready :
                         video_en ? vga_ready :
                         1'b0;
    assign iomem_rdata = timer_en ? timer_rdata :
                         gpio_en ? gpio_rdata :
                         32'h0000_0000;

    always @(posedge clk) begin
        if (!resetn) begin
            timer_ready <= 1'b0;
            timer_rdata <= 32'h0000_0000;
            timer_counter <= 32'd0;
            timer_irq_enable <= 1'b0;
            timer_irq_pending <= 1'b0;
            timer_irq_period <= 32'd2700000;
            timer_irq_countdown <= 32'd2700000;
            timer_irq_event_count <= 32'd0;
            soft_irq <= 1'b0;
        end else begin
            timer_ready <= 1'b0;
            timer_counter <= timer_counter + 32'd1;
            soft_irq <= 1'b0;

            if (timer_irq_enable && !timer_irq_pending) begin
                if (timer_irq_countdown == 32'd0) begin
                    timer_irq_pending <= 1'b1;
                    timer_irq_event_count <= timer_counter;
                    timer_irq_countdown <= timer_irq_period;
                end else begin
                    timer_irq_countdown <= timer_irq_countdown - 32'd1;
                end
            end

            if (timer_en && !iomem_ready) begin
                timer_ready <= 1'b1;

                case (iomem_addr[4:2])
                    3'b000: timer_rdata <= timer_counter;
                    3'b001: timer_rdata <= 32'd27000000;
                    3'b010: timer_rdata <= {31'd0, timer_irq_enable};
                    3'b011: timer_rdata <= {31'd0, timer_irq_pending};
                    3'b100: timer_rdata <= timer_irq_period;
                    3'b101: timer_rdata <= timer_irq_countdown;
                    3'b110: timer_rdata <= timer_irq_event_count;
                    default: timer_rdata <= 32'h0000_0000;
                endcase

                if (iomem_wstrb != 4'b0000) begin
                    case (iomem_addr[4:2])
                        3'b000: timer_counter <= iomem_wdata;
                        3'b010: timer_irq_enable <= iomem_wdata[0];
                        3'b011: if (iomem_wdata[0]) timer_irq_pending <= 1'b0;
                        3'b100: begin
                            timer_irq_period <= iomem_wdata;
                            timer_irq_countdown <= iomem_wdata;
                        end
                        3'b111: soft_irq <= iomem_wdata[0];
                        default: begin
                        end
                    endcase
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!resetn) begin
            gpio <= 32'h0000_0000;
            gpio_ready <= 1'b0;
            gpio_rdata <= 32'h0000_0000;
        end else begin
            gpio_ready <= 1'b0;
            if (gpio_en && !iomem_ready) begin
                gpio_ready <= 1'b1;
                gpio_rdata <= {8'h00, 1'b0, 1'b0, 1'b0, buttons[4:0], gpio[15:0]};
                if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
                if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
                if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
                if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
            end
        end
    end

    assign led_n[0] = btnL;
    assign led_n[1] = btnR;
    assign led_n[5:2] = ~gpio[5:2];

    wire [31:0] ram_data = 32'h0000_0000;
    wire [31:0] ram_addr = 32'h0000_0000;
    wire progmem_wen = 1'b0;

    picosoc_noflash #(
        .MEM_WORDS(4096),       // 16 KB data RAM (power-of-two; matches default linker)
        .BARREL_SHIFTER(1'b0),
        .COMPRESSED_ISA(1'b0),
        .ENABLE_MUL(1'b1),
        .ENABLE_DIV(1'b0)
    ) soc (
        .clk(clk),
        .resetn(resetn),

        .ser_tx(uart_tx),
        .ser_rx(uart_rx),

        .irq_5(timer_irq_pending),
        .irq_6(soft_irq),
        .irq_7(1'b0),

        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),

        .progmem_wen(progmem_wen),
        .progmem_waddr(ram_addr),
        .progmem_wdata(ram_data)
    );

    hdmi_wrapper_640 video (
        .clk_ext(clk_27),
        .clk(clk),
        .reset(!resetn),

        .vga_iomem_ready(vga_ready),
        .iomem_valid(iomem_valid && video_en),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),

        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_dat_p(hdmi_dat_p),
        .hdmi_dat_n(hdmi_dat_n)
    );
endmodule
