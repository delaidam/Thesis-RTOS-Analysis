module top_hdmi_test
   import hdmi_pkg::*;
(
    input logic clk_27,
    input logic btnL,

    output logic [5:0] led_n,

    output logic hdmi_clk_p,
    output logic hdmi_clk_n,
    output bus3_t hdmi_dat_p,
    output bus3_t hdmi_dat_n
);
    logic clk_pix;
    logic srst_n;
    logic frame_done;
    logic mfram_done;
    logic video_on;
    bus12_t hcount;
    bus12_t vcount;
    pix_t pix;
    logic [25:0] board_blink;
    logic frame_blink;

    always_ff @(posedge clk_27 or negedge btnL) begin
        if (!btnL) begin
            board_blink <= '0;
        end else begin
            board_blink <= board_blink + 26'd1;
        end
    end

    always_ff @(negedge srst_n or posedge clk_pix) begin
        if (!srst_n) begin
            frame_blink <= 1'b0;
        end else if (mfram_done) begin
            frame_blink <= ~frame_blink;
        end
    end

    always_comb begin
        pix = '{R: 8'h00, G: 8'h00, B: 8'h00};

        if (video_on) begin
            unique case (hcount[10:8])
                3'd0: pix = '{R: 8'hff, G: 8'h00, B: 8'h00};
                3'd1: pix = '{R: 8'h00, G: 8'hff, B: 8'h00};
                3'd2: pix = '{R: 8'h00, G: 8'h00, B: 8'hff};
                3'd3: pix = '{R: 8'hff, G: 8'hff, B: 8'hff};
                3'd4: pix = '{R: 8'hff, G: 8'hff, B: 8'h00};
                default: pix = '{R: 8'h00, G: 8'hff, B: 8'hff};
            endcase

            if (hcount[5] ^ vcount[5]) begin
                pix.R = {1'b0, pix.R[7:1]};
                pix.G = {1'b0, pix.G[7:1]};
                pix.B = {1'b0, pix.B[7:1]};
            end
        end
    end

    assign led_n[0] = ~board_blink[24];
    assign led_n[1] = ~srst_n;
    assign led_n[2] = ~frame_blink;
    assign led_n[5:3] = 3'b111;

    hdmi_backend hdmi (
        .clk_ext(clk_27),
        .clk_pix(clk_pix),
        .srst_n(srst_n),
        .hcount(hcount),
        .vcount(vcount),
        .pix(pix),
        .frame_done(frame_done),
        .mfram_done(mfram_done),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_dat_p(hdmi_dat_p),
        .hdmi_dat_n(hdmi_dat_n),
        .video_on(video_on)
    );
endmodule
