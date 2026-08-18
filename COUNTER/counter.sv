`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 21:58:16
// Design Name: 
// Module Name: counter
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


module counter(
input logic[4:0]data,
input bit rst_,clk,enable,load,
output logic[4:0]count
    );
    always_ff@(posedge clk or negedge rst_)
    begin
     if(!rst_)begin
            count<=5'b00000;
        end else if(load)begin
            count<=data;
        end else if(enable)begin
            count<=count+1'b1;
        end else begin
            count<=count;
        end
    end
//   begin
//   if(!rst_)
//   begin
//   count<=5'b00000;
//   end
   
//   else 
//   begin
   
//   if(load)
//   begin
//   count<=data;
//   end
   
//   else
//   begin
//   if(enable)
//   count<=count+1;
//   else
//   count<=count;
//   end
//   end
//   end
   endmodule
