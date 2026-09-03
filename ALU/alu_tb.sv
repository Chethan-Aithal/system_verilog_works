`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 19:05:21
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb;
parameter logic [2:0] HLT = 3'b000;
parameter logic [2:0] SKZ = 3'b001;
parameter logic [2:0] ADD = 3'b010;
parameter logic [2:0] AND = 3'b011;
parameter logic [2:0] XOR = 3'b100;
parameter logic [2:0] LDA = 3'b101;
parameter logic [2:0] STO = 3'b110;
parameter logic [2:0] JMP = 3'b111;
logic [7:0]data,accum;
 logic [2:0]opcode;
bit clk;
 logic [7:0]out;
 bit zero;
   
ALU dut(.data(data),.clk(clk),.accum(accum),.opcode(opcode),.out(out),.zero(zero));

always #5 clk=~clk;

initial
begin
clk=1'b0;
data=8'h12;
accum=8'h34;
    opcode=HLT;
    #10;
    opcode=SKZ;
    @(negedge clk);
    opcode=ADD;
    #10;
    opcode=AND;
    @(negedge clk);
    opcode=XOR;
    #10;
    opcode=LDA;
    #10;
    opcode=STO;
    @(negedge clk);
    opcode=JMP;
    #10;
    accum=8'h00;
    opcode=SKZ;
    @(negedge clk);
    #10 $finish;
    end
endmodule
