module mz80a_wxeda(
	input				CLK,
	input	[3:0]		KEYS,

inout	[15:0]	SDRAM_DQ,
output	[12:0]	SDRAM_A,
output			SDRAM_DQML,
output			SDRAM_DQMH,
output			SDRAM_WE_N,
output			SDRAM_CAS_N,
output			SDRAM_RAS_N,
output			SDRAM_CS_N,
output [1:0]	SDRAM_BA,

output			SDRAM_CLK,
output			SDRAM_CKE = 1'b1,

inout			SD_DAT,
inout			SD_DAT3,
inout			SD_CMD,
output			SD_CLK,

inout		 	PS2_DAT,
inout			PS2_CLK,

output			VGA_HS,
output			VGA_VS,
output	[4:0]	VGA_R,
output	[5:0]	VGA_G,
output	[4:0]	VGA_B,
inout			DAC_OUT_L,
inout			DAC_OUT_R,
output		BUZZER);



wire 			clk_sys;
wire 			locked;
wire 			r, g, b;
wire 			hs, vs, hb, vb;
wire 			bln = ~(hb | vb);

pll pll(
	.inclk0(CLK),
	.c0(clk_sys),
	.locked(locked)
	);

reg [7:0] reset_cnt;
always @(posedge clk_sys) begin
	if(!locked || ~KEYS[0])
		reset_cnt <= 8'h0;
	else if(reset_cnt != 8'd255)
		reset_cnt <= reset_cnt + 8'd1;
end 

wire reset = (reset_cnt != 8'd255);

wire white = ~KEYS[2];
wire turbo = ~KEYS[3];

assign VGA_R = bln ? (white ? {g,g,g,g,g} : {r,r,r,r,r}) : "00000";
assign VGA_G = bln ? ({g,g,g,g,g,g}) : "000000";
assign VGA_B = bln ? (white ? {g,g,g,g,g} : {b,b,b,b,b}) : "00000";

mz80k_top mz80k_top(
	.CLK_50MHZ(clk_sys),
	.RESET(reset),
	.PS2_CLK(PS2_CLK), 
	.PS2_DATA(PS2_DAT),
	.VGA_RED(r), 
	.VGA_GREEN(g), 
	.VGA_BLUE(b), 
	.VGA_HSYNC(VGA_HS), 
	.VGA_VSYNC(VGA_VS),
	.VGA_HBLANK(hb),
	.VGA_VBLANK(vb),
	.TapeRead(DAC_OUT_R),
	.TapeWrite(DAC_OUT_L),
	.TURBO(turbo),
	.TP1(BUZZER)
	);

endmodule 