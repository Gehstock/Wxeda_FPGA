module orao_wxeda(
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
	input         		UART_RXD,	
	output        		UART_TXD
	);

wire   		video;
assign 		VGA_R = {video,video,video,video,video};
assign 		VGA_G = {video,video,video,video,video,video};
assign 		VGA_B = {video,video,video,video,video};
wire 			clk_50, clk_25;

pll pll (
	.inclk0			( CLOCK_48		),
	.c0				( clk_50			),
	.c1				( clk_25			)
);

orao #(.ram_kb(6), .clk_mhz(25), .serial_baud(9600)) orao (
	.n_reset		( KEY[2]			),
	.clk			( clk_25			),
	.clkvid		( clk_50			),
	.video		( video 			),
	.hs			( VGA_HS			),
	.vs			( VGA_VS			),
	.cs			( 					),
	.rxd			( UART_RXD		),
	.txd			( UART_TXD		),
	.rts			( 					),
	.key_b      ( 					),
	.key_c      ( 					),
	.key_enter  ( 					),
	.ps2clk		( PS2_CLK  		),
	.ps2data		( PS2_DAT		)
);

endmodule 