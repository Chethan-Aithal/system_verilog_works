`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2026 11:38:25
// Design Name: 
// Module Name: mem
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


module mem(
input logic read,write,clk,
input logic[4:0] addr,
input logic [7:0] data_in,
output logic [7:0] data_out
    );
    logic [7:0] memory [31:0];
    
    //Write operation
    always@(posedge clk)
    begin
    if(write&&!read)
    #1 memory[addr]<=data_in;
    end
    
    //read operation
    always_ff@(posedge clk)
    begin
    if(!write&&read)
    data_out<=memory[addr];
    end
    
endmodule
