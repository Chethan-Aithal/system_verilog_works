`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2026 10:37:14
// Design Name: 
// Module Name: typedefs
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

package typedefs;
//OPCODE define in the enum 3 bit logic
typedef enum logic[2:0]{HLT=3'b000,SKZ,ADD,AND,XOR,LDA,STO,JMP}opcode_t;
//the  fsm states in the enum 3 bit logic
typedef enum logic[2:0]{INST_ADDR=3'b000,INST_FETCH,INST_LOAD,IDLE,OP_ADDR,OP_FETCH,ALU_OP,STORE}state_t;
endpackage:typedefs
