`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2026 10:55:38
// Design Name: 
// Module Name: controller
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

import typedefs::*;
module controller(
input bit clk,
input logic rst_,
input opcode_t opcode,
input logic zero,
output logic mem_rd,
output logic load_ir,
output logic halt,
output logic inc_pc,
output logic load_ac,
output logic load_pc,
output logic mem_wr
    );
state_t state;
state_t next_state;

logic ALUOP;
assign ALUOP=(opcode==ADD||opcode==XOR||opcode==AND||opcode==LDA);

always_ff@(posedge clk or negedge rst_)
begin
if(!rst_)
state<=INST_ADDR;
else
state<=next_state;
end

always_comb
begin
        mem_rd   = 1'b0;
        load_ir  = 1'b0;
        halt     = 1'b0;
        inc_pc   = 1'b0;
        load_ac  = 1'b0;
        load_pc  = 1'b0;
        mem_wr   = 1'b0;
        next_state = state;

case(state)

INST_ADDR:
begin
next_state=INST_FETCH;
end

INST_FETCH:
begin
mem_rd=1'b1;
next_state=INST_LOAD;
end

INST_LOAD:
begin
load_ir=1'b1;
mem_rd=1'b1;
next_state=IDLE;
end

IDLE:
begin
load_ir=1'b1;
mem_rd=1'b1;
next_state=OP_ADDR;
end

OP_ADDR:
begin
mem_rd=1'b0;
load_ir=1'b0;
halt=(opcode==HLT);
inc_pc=1'b1;
next_state=OP_FETCH;
end

OP_FETCH:
begin
mem_rd=ALUOP;
halt=1'b0;
inc_pc=1'b0;
next_state=ALU_OP;
end

ALU_OP:
begin
mem_rd=ALUOP;
inc_pc=((opcode==SKZ)&&zero)?1'b1:1'b0;
load_ac=ALUOP;
load_pc=(opcode==JMP);
mem_wr=1'b0;
next_state=STORE;
end

STORE:
begin
mem_rd=ALUOP;
inc_pc=(opcode==JMP);
load_ac=ALUOP;
load_pc=(opcode==JMP);
mem_wr=(opcode==STO);
next_state=INST_ADDR;
end

default:next_state=INST_ADDR;
endcase
end
endmodule
