// Copyright (C) 1991-2014 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.1.4 Build 182 03/12/2014 SJ Web Edition"
// CREATED		"Fri Jun 29 15:46:54 2018"

module tll74145 (
	A,
	B,
	C,
	D,
	O9N,
	O8N,
	O7N,
	O6N,
	O5N,
	O4N,
	O3N,
	O2N,
	O1N,
	O0N
);


input wire	A;
input wire	B;
input wire	C;
input wire	D;
output wire	O9N;
output wire	O8N;
output wire	O7N;
output wire	O6N;
output wire	O5N;
output wire	O4N;
output wire	O3N;
output wire	O2N;
output wire	O1N;
output wire	O0N;

wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;
wire	SYNTHESIZED_WIRE_28;




assign	O0N = ~(SYNTHESIZED_WIRE_25 & SYNTHESIZED_WIRE_26 & SYNTHESIZED_WIRE_27 & SYNTHESIZED_WIRE_28);

assign	O1N = ~(A & SYNTHESIZED_WIRE_26 & SYNTHESIZED_WIRE_27 & SYNTHESIZED_WIRE_28);

assign	O2N = ~(SYNTHESIZED_WIRE_25 & B & SYNTHESIZED_WIRE_27 & SYNTHESIZED_WIRE_28);

assign	O3N = ~(A & B & SYNTHESIZED_WIRE_27 & SYNTHESIZED_WIRE_28);

assign	O4N = ~(SYNTHESIZED_WIRE_25 & SYNTHESIZED_WIRE_26 & C & SYNTHESIZED_WIRE_28);

assign	O5N = ~(A & SYNTHESIZED_WIRE_26 & C & SYNTHESIZED_WIRE_28);

assign	O6N = ~(SYNTHESIZED_WIRE_25 & B & C & SYNTHESIZED_WIRE_28);

assign	O7N = ~(A & B & C & SYNTHESIZED_WIRE_28);

assign	O9N = ~(A & SYNTHESIZED_WIRE_26 & SYNTHESIZED_WIRE_27 & D);

assign	O8N = ~(SYNTHESIZED_WIRE_25 & SYNTHESIZED_WIRE_26 & SYNTHESIZED_WIRE_27 & D);

assign	SYNTHESIZED_WIRE_25 =  ~A;

assign	SYNTHESIZED_WIRE_26 =  ~B;

assign	SYNTHESIZED_WIRE_27 =  ~C;

assign	SYNTHESIZED_WIRE_28 =  ~D;


endmodule
