`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 18:34:38
// Design Name: 
// Module Name: ALU
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


module ALU#(
parameter logic [2:0] HLT = 3'b000,
parameter logic [2:0] SKZ = 3'b001,
parameter logic [2:0] ADD = 3'b010,
parameter logic [2:0] AND = 3'b011,
parameter logic [2:0] XOR = 3'b100,
parameter logic [2:0] LDA = 3'b101,
parameter logic [2:0] STO = 3'b110,
parameter logic [2:0] JMP = 3'b111
)
(
input logic [7:0]data,accum,
input logic [2:0]opcode,
input bit clk,
output logic [7:0]out,
output bit zero
    );
    
    always_comb
    begin
    zero=(accum==8'h00);
    end
    
    always_ff@(negedge clk)
    begin
    case (opcode)
    HLT: out <= accum;
    SKZ: out <= accum;
    ADD: out <= data + accum;
    AND: out <= data & accum;
    XOR: out <= data ^ accum;
    LDA: out <= data;
    STO: out <= accum;
    JMP: out <= accum;
    default: out <= accum;
    endcase
    end
endmodule
