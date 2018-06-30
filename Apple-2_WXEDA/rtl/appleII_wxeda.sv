module appleII_wxeda (
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


wire CLK_28M, CLK_14M;
wire pll_locked;

pll pll
(
	.inclk0(CLOCK_48),
	.areset(0),
	.c0(CLK_28M),
	.c1(CLK_14M),
	.locked(pll_locked)
);


wire 			power_on_reset;
wire 			reset = power_on_reset | ~KEY[2];
wire [22:0] flash_clk;
wire 			hsync,vsync;
assign LED = 1;
wire 			blankn = ~(hblank | vblank);
wire 			hblank, vblank;
wire 			hs, vs;
wire 			VIDEO, COLOR_LINE, LD194, speaker;
wire 			read;
wire 	[7:0] K;
wire 	[5:0] r,g,b;

  
always @(CLK_14M) begin
	if (flash_clk[22] == 1'b1) power_on_reset = 1'b0;
end

always @(CLK_14M) begin
	//rising_edge(CLK_14M) then flash_clk <= flash_clk + 1;
end

	wire ram_we;
	wire [12:0]ram_address;
	wire [7:0]ram_data;
	wire [7:0]ram_q;
	
ram ram(
		.clock(CLK_14M),
		.address(ram_address),
		.data(ram_data),
		.q(ram_q),
		.wren(ram_we)
		);

apple2 apple2 (
	.CLK_14M        (CLK_14M),
	.CLK_2M         (),//: out std_logic;
	.PRE_PHASE_ZERO (),//: out std_logic;
	.FLASH_CLK      (),//: in  std_logic;        -- approx. 2 Hz flashing char clock
	.reset          (reset),
	.ADDR           (),//: out unsigned(15 downto 0);  -- CPU address
	.ram_addr       (ram_address),//: out unsigned(15 downto 0);  -- RAM address
	.D              (ram_data),//: out unsigned(7 downto 0);   -- Data to RAM
	.ram_do         (ram_q),//: in unsigned(7 downto 0);    -- Data from RAM
	.PD             (),//: in unsigned(7 downto 0);    -- Data to CPU from peripherals
	.ram_we         (ram_we),//: out std_logic;              -- RAM write enable
	.VIDEO          (VIDEO),
	.COLOR_LINE     (COLOR_LINE),
	.HBL            (hblank),
	.VBL            (vblank),
	.LD194          (LD194),
	.K              (K),
	.READ_KEY       (read),
	.AN             (),//: out std_logic_vector(3 downto 0);  -- Annunciator outputs
// GAMEPORT input bits:
//  7    6    5    4    3   2   1    0
// pdl3 pdl2 pdl1 pdl0 pb3 pb2 pb1 casette
	.GAMEPORT       (),//: in std_logic_vector(7 downto 0);
	.PDL_STROBE     (),//: out std_logic;         -- Pulses high when C07x read
	.STB            (),//: out std_logic;         -- Pulses high when C04x read
	.IO_SELECT      (),//: out std_logic_vector(7 downto 0);
	.DEVICE_SELECT  (),//: out std_logic_vector(7 downto 0);
	.pcDebugOut     (),//: out unsigned(15 downto 0);
	.opcodeDebugOut (),//: out unsigned(7 downto 0);
	.speaker        (speaker)
	);
	
keyboard keyboard (
   .PS2_Clk      	(PS2_CLK),
   .PS2_Data      (PS2_DAT),
   .CLK_14M      	(CLK_14M),
   .reset      	(reset),
   .read      		(read),
   .K      			(K),
   );
	
vga_controller vga_controller (
   .CLK_28M      		(CLK_28M),
   .VIDEO      		(VIDEO),
   .COLOR_LINE      	(COLOR_LINE),
	.COLOR				(~KEY[0]),
   .HBL      			(hblank),
   .VBL      			(vblank),
   .LD194      		(LD194),
   .VGA_HS      		(VGA_HS),
   .VGA_VS      		(VGA_VS),
   .VGA_R      		(VGA_R),
   .VGA_G      		(VGA_G),
   .VGA_B      		(VGA_B),
    );

dac dac (
	.CLK_DAC (CLK_28M),
   .RST     (),
   .IN_DAC  (speaker & 15'b0),
   .OUT_DAC (AUDIO_L)
	);

assign AUDIO_R = AUDIO_L;//todo


endmodule
