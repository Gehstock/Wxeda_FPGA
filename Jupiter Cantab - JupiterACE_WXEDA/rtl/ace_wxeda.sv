`timescale 1ns / 1ps
`default_nettype none

module ace_wxeda(
	output   [3:0] 	LED,
	output  	[4:0] 	VGA_R,
	output  	[5:0] 	VGA_G,
	output  	[4:0] 	VGA_B,
	output        		VGA_HS,
	output        		VGA_VS,
	input         		CLOCK_48,
	input         		PS2_DAT,
	input         		PS2_CLK,
	input 	[3:0] 	KEY,
	inout	  [15:0]		DRAM_DQ,					//	SDRAM Data bus 16 Bits
	output  [12:0]		DRAM_ADDR,				//	SDRAM Address bus 12 Bits
	output				DRAM_LDQM,				//	SDRAM Low-byte Data Mask 
	output				DRAM_UDQM,				//	SDRAM High-byte Data Mask
	output				DRAM_WE_N,				//	SDRAM Write Enable
	output				DRAM_CAS_N,				//	SDRAM Column Address Strobe
	output				DRAM_RAS_N,				//	SDRAM Row Address Strobe
	output				DRAM_CS_N,				//	SDRAM Chip Select
	output				DRAM_BA_0,				//	SDRAM Bank Address 0
	output				DRAM_BA_1,				//	SDRAM Bank Address 0
	output				DRAM_CLK,				//	SDRAM Clock
	output				DRAM_CKE,				//	SDRAM Clock Enable
   input         		SD_DAT,
	input         		UART_RXD,
	output        		UART_TXD,
   output        		SD_DAT3,
   output        		SD_CMD,
   output        		SD_CLK

    );


wire			clk_sys;
wire 			clk_65;
wire 			clk_13;
wire 			clk_cpu;
wire        clk_sdram;
wire 			locked;



wire 			audio;
wire 			TapeIn;
wire 			TapeOut;
wire 			HSync, VSync;
wire 			video;
wire 	[7:0] kbd_rows;
wire 	[4:0] kbd_columns;
	
pll pll(
	.areset(),
	.inclk0(CLOCK_48),
	.c0(clk_sys),//26.0Mhz
	.c1(clk_65),//6.5Mhz
	.c2(clk_cpu),//3.25Mhz
	.c3(DRAM_CLK),//104Mhz
	.c4(clk_13),
	.locked(locked)
	);

reg [7:0] reset_cnt;
always @(posedge clk_sys) begin
	if(!locked | ~KEY[2])
		reset_cnt <= 8'h0;
	else if(reset_cnt != 8'd255)
		reset_cnt <= reset_cnt + 8'd1;
end 

wire reset = (reset_cnt != 8'd255);

wire [24:0]sd_addr;
wire [7:0]sd_dout;
wire [7:0]sd_din;
wire sd_we;
wire sd_rd;
wire sd_ready;

sram sram(
	.SDRAM_DQ(DRAM_DQ),
	.SDRAM_A(DRAM_ADDR),
	.SDRAM_DQML(DRAM_LDQM),
	.SDRAM_DQMH(DRAM_UDQM),
	.SDRAM_BA({DRAM_BA_1,DRAM_BA_0}),
	.SDRAM_nCS(DRAM_CS_N),
	.SDRAM_nWE(DRAM_WE_N),
	.SDRAM_nRAS(DRAM_RAS_N),
	.SDRAM_nCAS(DRAM_CAS_N),
	.SDRAM_CKE(DRAM_CKE),
	.init(~reset),
	.clk_sdram(DRAM_CLK),			
	.addr(sd_addr),   // 25 bit address
	.dout(sd_dout),	// data output to cpu
	.din(sd_din),     // data input from cpu
	.we(sd_we),       // cpu requests write
	.rd(sd_rd),       // cpu requests read
	.ready(sd_ready)
);

assign VGA_R = {video,video,video,video,video};
assign VGA_G = {video,video,video,video,video,video};
assign VGA_B = {video,video,video,video,video};
wire hs, vs;

scandoubler #(.LENGTH(575), .HALF_DEPTH(1)) scandoubler (
	.clk_sys(clk_sys),
	.ce_pix(clk_65),
	.ce_pix_actual(clk_65),
	.hs_in(hs),
	.vs_in(vs),
	.line_start(00),
	.mono(1),
	.hs_out(VGA_HS),
	.vs_out(VGA_VS)
);

jupiter_ace jupiter_ace
(
   .clk_65(clk_65),
   .clk_cpu(clk_cpu),
   .reset(~reset),
   .filas(kbd_rows),
   .columnas(kbd_columns),
   .video(video),
   .hsync(hs),
	.vsync(vs),
   .ear(UART_RXD),//Play
   .mic(UART_TXD),//Record
   .spk(audio),
	.sd_addr(sd_addr),
	.sd_dout(sd_dout),
	.sd_din(sd_din),
	.sd_we(sd_we),
	.sd_rd(sd_rd),
	.sd_ready(sd_ready)
);
/*
sigma_delta_dac sigma_delta_dac
(	
	.DACout(AUDIO_L),
	.DACin({audio}),
	.CLK(clk_65),
	.RESET(0)
);

assign AUDIO_R = AUDIO_L;*/
	
keyboard keyboard
(
   .clk(clk_65),
   .clkps2(PS2_CLK),
   .dataps2(PS2_DAT),
   .rows(kbd_rows),
   .columns(kbd_columns),
   .kbd_reset(),
   .kbd_nmi(),
   .kbd_mreset()        
);




endmodule
