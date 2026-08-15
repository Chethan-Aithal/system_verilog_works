`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2026 10:22:34
// Design Name: 
// Module Name: register
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


module register(
input logic [7:0] data,
input  logic clk,rst_,enable,
output logic [7:0] out
    );
    always_ff@(posedge clk or negedge rst_)
    begin
    if(~rst_)
    out<=8'h00;
    else
     begin
     if(enable)
     out<=data;
     else
     out<=out;
     end
     end
endmodule
