`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 22:58:33
// Design Name: 
// Module Name: counter_tb
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

module counter_tb;
logic[4:0]data;
logic[4:0]count;
bit rst_,enable,load,clk;
counter c1(.data(data),.rst_(rst_),.clk(clk),.enable(enable),.load(load),.count(count));
always #5 clk=~clk;
initial begin
// Operation: System Initialization
rst_=0;
enable=0;
load=0;
data=0;
#2;
// Operation: Asynchronous Reset Test
{rst_,enable,load,data}={1'b0,1'bx,1'bx,5'bxxxxx};
#10;
// Operation: Parallel Load Priority Test
{rst_,enable,load,data}={1'b1,1'b1,1'b1,5'b01010};
#10;
// Operation: Normal Count Up Increment Test
{rst_,enable,load,data}={1'b1,1'b1,1'b0,5'b00000};
#40;
// Operation: Counter Disabled / State Holding Test
{rst_,enable,load,data}={1'b1,1'b0,1'b0,5'b00000};
#20;
$finish;
end
endmodule
