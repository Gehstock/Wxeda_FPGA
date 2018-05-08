module apple1_wxeda(
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

wire 	clk25;
wire	r, g, b;
assign VGA_R = {r,r,r,r,r};
assign VGA_G = {g,g,g,g,g,g};
assign VGA_B = {b,b,b,b,b};

pll pll(
	.inclk0		( CLOCK_48	),
	.c0			( clk25		)
	);
	
apple1 apple1(
	.clk25		( clk25		),
	.rst_n		( KEY[2]		),
	.uart_rx		( UART_RXD	),
	.uart_tx		( UART_TXD	),
	.uart_cts	(				),
	.ps2_clk		( PS2_CLK	),
	.ps2_din		( PS2_DAT	),
	.ps2_select	( 1'b1		),
	.vga_h_sync	( VGA_HS		),
   .vga_v_sync	( VGA_VS		),
	.vga_red		( r			),
	.vga_grn		( g			),
	.vga_blu		( b			),
	.vga_cls		(				),
   .pc_monitor	(				)
	);

endmodule 