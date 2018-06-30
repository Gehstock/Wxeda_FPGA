`timescale 1ns / 1ps

module sound(
	input CLK_50MHZ,
	input SW,
	output reg TP1);
	
	reg [14:0] count = 0;
	reg [14:0] count2 = 1;


always @(posedge CLK_50MHZ)
	begin
		count <= count + 1;
	end

always @(posedge count[12])
	begin
		if ( count2 >= SW )
		begin
			TP1 <= SW != 0 ? ~TP1: TP1;
			count2 <= 1;
		end else
		begin
			count2 <= count2 + 1;
		end
	end


endmodule
