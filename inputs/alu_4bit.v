// 4-bit ALU

module alu_4bit(A,B,Y,clk,Opcode);
	input [3:0]A,B;
	input [1:0]Opcode;
	input clk;
	output [7:0]Y;
	wire [7:0]y1,y2,y3,y4;
	arithmetic_unit sm1(A,B,y1,y2);
	logical_unit sm2(A,B,y3,y4);
	control_unit sm3(y1,y2,y3,y4,clk,Opcode,Y);
endmodule

module arithmetic_unit(x,y,y1,y2);
	input [3:0]x,y;
	output reg[7:0]y1,y2;
	always@(x,y)
	begin
		y1<=x+y;
		y2<=x-y;
	end
endmodule

module logical_unit(x,y,y3,y4);
	input [3:0]x,y;
	output [7:0]y3,y4;
	assign y3=x&y;
	assign y4=x^y;
endmodule

module control_unit(y1,y2,y3,y4,clk,Opcode,Y);
	input [7:0]y1,y2,y3,y4;
	input [1:0]Opcode;
	input clk;
	output reg[7:0]Y;
	always@(posedge clk)
	begin
		if(Opcode ==2'b00)
		Y<=y1;
		else if(Opcode ==2'b01)
		Y<=y2;
		else if(Opcode ==2'b10)
		Y<=y3;
		else if(Opcode ==2'b11)
		Y<=y4;
		else
		Y<=0;
	end
endmodule
