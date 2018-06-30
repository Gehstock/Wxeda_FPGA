
module mz80k_top(
	input		CLK_50MHZ,
	input		RESET,
	input		PS2_CLK, 
	input		PS2_DATA,
	output	VGA_RED, 
	output	VGA_GREEN, 
	output	VGA_BLUE, 
	output	VGA_HSYNC, 
	output	VGA_VSYNC,
	output	VGA_HBLANK,
	output	VGA_VBLANK,
	input		TapeRead,
	output	TapeWrite,
	input		[7:0] SW,
	input   	TURBO,
	input   	SCREEN,
	output	TP1
	);
	

	wire			CLK_CPU;
	reg			CLK_2M = 0, CLK_31250 = 0;
	reg	[4:0]		count_2M = 0;
	reg	[10:0]	count_31250 = 0;
	reg	[32:0]	clk_count = 0;
	
	always @(posedge CLK_50MHZ) begin
		clk_count <= clk_count + 1;
	end
	
	always @(posedge CLK_50MHZ) begin
		count_2M		<= count_2M >= 13 ? 0 : count_2M + 1;
		count_31250	<= count_31250 >= 800 ? 0 : count_31250 + 1;
		CLK_2M		<= count_2M == 0 ? ~CLK_2M : CLK_2M;
		CLK_31250	<= count_31250 == 0 ? ~CLK_31250 : CLK_31250;
	end
	
	assign CLK_CPU = TURBO ?  clk_count[2] : clk_count[3];		// 3MHZ

// Z80
	wire	[15:0] cpu_addr;
	wire	[7:0] cpu_data_in, cpu_data_out;
	wire	mreq, iorq, rd, wr, busreq, busack, intack;
	wire	start, waitreq;

// I/O
	wire	io_e000 = (cpu_addr[15:0] == 16'he000) & mreq;
	wire	io_e001 = (cpu_addr[15:0] == 16'he001) & mreq;
	wire	io_e002 = (cpu_addr[15:0] == 16'he002) & mreq;
	wire	io_8253 = (cpu_addr[15:2] == 14'b11100000000001) & mreq;
	wire	io_8255 = (cpu_addr[15:2] == 14'b11100000000000) & mreq;
	wire	io_e008 = (cpu_addr[15:0] == 16'he008) & mreq;

	
//	CS00<='0' when A(15 downto 12)="0000" and reg00='0' and MREQ='0' else '1';
//	CSD0<='0' when A(15 downto 11)="11010" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CSD8<='0' when A(15 downto 11)="11011" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CSE8<='0' when A(15 downto 11)="11101" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CSPPI<='0' when A(15 downto 11)="11100" and A(4 downto 2)="000" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CSPIT<='0' when A(15 downto 11)="11100" and A(4 downto 2)="001" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CS367<='0' when A(15 downto 11)="11100" and A(4 downto 2)="010" and regIO='0' and regEX='0' and MREQ='0' else '1';
//	CSPCG<='0' when A(15 downto 11)="11100" and A(4 downto 2)="100" and regIO='0' and regEX='0' and MREQ='0' else '1';
	
	
	reg		[3:0] key_no;
	reg				speaker_enable;
	always @(posedge CLK_CPU or posedge RESET) begin
		if (RESET) begin
			key_no <= 0;
			speaker_enable <= 0;
		end else  begin
			if (io_e000 & wr ) begin
				key_no <= cpu_data_out[3:0];
			end else if (io_e008 & wr ) begin
				speaker_enable <= cpu_data_out[0];
			end
		end
	end

// Z80
	assign waitreq = start;
	fz80 z80(
		.data_in(cpu_data_in), 
		.data_out(cpu_data_out),
		.reset_in(RESET), 
		.clk(CLK_CPU),
		.mreq(mreq), 
		.iorq(iorq), 
		.rd(rd), 
		.wr(wr),
		.adr(cpu_addr), 
		.waitreq(waitreq),
		.nmireq(0), 
		.intreq(out2 & 0), 
		.busreq(busreq), 
		.busack_out(busack),
		.start(start)
		);
		
	wire	[7:0] i8253_data_out;	
	wire	[7:0] i8255_data_out;
	wire	out0, out1, out2;	
		
// 8253(CLK0=2M CLK1=31.25K CLK2=OUT1)

	i8253 i8253_1(
		.reset(RESET), 
		.clk(CLK_CPU), 
		.addr(cpu_addr[1:0]), 
		.data_out(i8253_data_out), 
		.data_in(cpu_data_out),
		.cs(io_8253 & ~start), 
		.rd(rd), 
		.wr(wr),
		.clk0(CLK_2M), 
		.clk1(CLK_31250), 
		.clk2(out1),
		.out0(out0), 
		.out1(out1), 
		.out2(out2) 
		);
		
	wire [7:0] paIN, pbIN, pcIN;
	wire [7:0] paOUT, pbOUT, pcOUT;
	assign pcIN[5] = TapeRead;
	assign pcIN[4] = 1'b1;
	assign pcOUT[1] = TapeWrite;
	/*
i8255 i8255 (
		.RST(RESET),
      .A(cpu_addr[1:0]),
      .CS(io_8255 & rd),
      .WR(wr),
      .DI(cpu_data_out),
      .DO(i8255_data_out),
		
		.LDDAT(ps2_dat),
      .CLKIN(CLK_CPU),
		.KCLK(CLK_CPU),//Keyboard Clock
		.VBLNK(),
		.INTMSK(),
      .RBIT(),
		.SENSE(),
		.MOTOR(),
		.PS2CK(PS2_CLK),
		.PS2DT(PS2_DATA)
		);*/
/*		
I82C55 I82C55(
		.I_ADDR(cpu_addr[1:0]),
		.I_DATA(cpu_data_out),
		.O_DATA(i8255_data_out),
		.O_DATA_OE_L(1'b1),
		.I_CS_L(io_8255 & ~start),
		.I_RD_L(rd),
		.I_WR_L(wr),
		
		.I_PA(paIN),
		.O_PA(paOUT),//Keyboard data
		.O_PA_OE_L(1'b1),

		.I_PB(pbIN),//Keyboard data
		.O_PB(pbOUT),
		.O_PB_OE_L(1'b1),

		.I_PC(pcIN),
		.O_PC(pcOUT),
		.O_PC_OE_L(1'b1),
		
		.RESET(RESET),
		.ENA(1'b1),
		.CLK(CLK_CPU)
		);*/


// KEYBOARD
	wire [7:0] ps2_dat;
	ps2 ps2_1(
		.clk(CLK_50MHZ), 
		.reset(RESET), 
		.ps2_clk(PS2_CLK), 
		.ps2_data(PS2_DATA), 
		.cs(io_e001 & rd), 
		.rd(rd), 
		.addr(key_no), 
		.data(ps2_dat)
		);
		
// VGA
	wire [11:0] vga_addr;
	vga vga1(
		.CLK_50MHZ(CLK_50MHZ), 
		.VGA_RED(VGA_RED), 
		.VGA_GREEN(VGA_GREEN), 
		.VGA_BLUE(VGA_BLUE),
		.VGA_HSYNC(VGA_HSYNC), 
		.VGA_VSYNC(VGA_VSYNC),
		.VGA_VBLANK(VGA_VBLANK),
		.VGA_HBLANK(VGA_HBLANK),
		.VGA_ADDR(vga_addr), 
		.VGA_DATA(vram_data), 
		.BUS_REQ(busreq), 
		.BUS_ACK(busack)
		);

// MAIN RAM
	wire ram_select  = (( cpu_addr[15:15] == 1'b0 || cpu_addr[15:12] == 4'b1000) & mreq) & ~busack;
	wire ram_en, ram_we;
	wire [7:0] ram_data_out, ram_data_in;
	
	monrom mon_rom(
		.address(cpu_addr),
		.clock(CLK_50MHZ),
		.data(ram_data_in),
		.q(ram_data_out),
		.clken(ram_en),
		.wren(ram_we)
		);

	assign ram_en = ram_select;
	assign ram_we = wr;
	assign ram_data_in = cpu_data_out;

// VRAM
	wire vram_select  = ((cpu_addr[15:11] == 5'b11010) & mreq) | busack;
	wire [11:0] vram_addr;
	wire vram_rd, vram_wr;
	wire [7:0] vram_data, vram_data_in;
	
	ram2 ram2_2(
		.address(vram_addr),
		.clock(CLK_50MHZ),
		.data(vram_data_in),
		.q(vram_data),
		.clken(vram_select),
		.rden(vram_rd),
		.wren(vram_wr)
		);
	assign vram_data_in = (vram_select & wr) ? cpu_data_out : 8'hzz;

		
	assign vram_addr[11:0] = busack ? vga_addr[11:0] : cpu_addr[11:0];
	assign vram_rd = busack | rd;
	assign vram_wr = busack ? 1'b0 : wr;
// Memory
	assign cpu_data_in = 
								( io_e001 & rd ) ? ps2_dat :
								( io_e002 & rd ) ? {VGA_VSYNC, clk_count[24], 6'b0000000} :
								( io_8253 & rd ) ? i8253_data_out :
								( io_8255 & rd ) ? i8255_data_out :
								( io_e008 & rd ) ? {7'b0000000, clk_count[19]} :		// MUSIC���Ȃǂ�WAIT�ŏd�v
								(vram_select & rd) ? vram_data :
								(ram_select & rd) ? ram_data_out: 8'hzz;
	assign TP1	= speaker_enable & out0;
endmodule

