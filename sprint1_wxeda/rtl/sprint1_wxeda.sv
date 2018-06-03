module sprint1_wxeda(
	output   [3:0] 	LED,
	output  	[4:0] 	VGA_R,
	output  	[5:0] 	VGA_G,
	output  	[4:0] 	VGA_B,
	output        		VGA_HS,
	output        		VGA_VS,
	input         		CLOCK_48,
	input         		PS2_DAT,
	input         		PS2_CLK,
	output        		AUDIO_L,
	output        		AUDIO_R,
	input 	[3:0] 	KEY
);



wire  [9:0] kbjoy;
wire  		audio;
wire			video;

wire clk_48, clk_12;
wire locked;
pll pll
(
	.inclk0(CLOCK_48),
	.c0(clk_48),//48.384
	.c1(clk_12),//12.096
	.locked(locked)
);

sprint1 sprint1 (
	.CLOCK_48(clk_48),
	.clk_12(clk_12),
	.Reset_n(~KEY[2]),
	.VideoW_O(),
	.VideoB_O(),
	.Sync_O(),					
	.Hs(hs),
	.Vs(vs),
	.Vb(vb),		
	.Hb(hb),
	.Video(video),			
	.Audio(audio),
	.Coin1_I(~kbjoy[7]),//esc
	.Coin2_I(~kbjoy[7]),//esc
	.Start_I(~kbjoy[5]),//f1
	.Gas_I(~kbjoy[4]),//space
	.Gear1_I(),
	.Gear2_I(),
	.Gear3_I(),
	.Test_I(),
	.SteerA_I(),
	.SteerB_I(),
	.StartLamp_O(~LED[0])
);

wire hs, vs, hb, vb;
wire blankn = ~(hb | vb);
scandoubler #(.LENGTH(480), .HALF_DEPTH(1) ) scandoubler (
	.clk_sys(clk_48),
	.ce_pix(clk_12),
	.ce_pix_actual(clk_12),
	.hs_in(~hs),
	.vs_in(~vs),
	.r_in(blankn ? {video,video,video} : "000"),
	.g_in(blankn ? {video,video,video} : "000"),
	.b_in(blankn ? {video,video,video} : "000"),
	.line_start(0),
	.mono(0),
	.hq2x(0),
	.hs_out(VGA_HS),
	.vs_out(VGA_VS),
	.r_out(VGA_R),
	.g_out(VGA_G),
	.b_out(VGA_B)		
	
);

assign AUDIO_L = audio;
assign AUDIO_R = audio;

keyboard keyboard(
	.clk(clk_48),
	.reset(),
	.ps2_kbd_clk(PS2_CLK),
	.ps2_kbd_data(PS2_DAT),
	.joystick(kbjoy)
	);


endmodule
