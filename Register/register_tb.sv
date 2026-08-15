`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2026 10:36:16
// Design Name: 
// Module Name: register_tb
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


module register_tb;
//signals declared
logic [7:0]data;
logic clk,rst_,enable;
logic [7:0]out;
 //dut
register r1(.data(data),.clk(clk),.rst_(rst_),.enable(enable),.out(out));

always
#5 clk=~clk;

initial
begin
clk=1'b0;
rst_=1'b1;
enable=1'b1;
data=8'h00;

@(negedge clk)
begin
data=8'hff;
end

@(negedge clk)
begin
data=8'hxx;
end

// Asynchronous Reset
@(negedge clk)
begin
data=8'haa;
rst_=1'b0;
end

#20;           
$display("Simulation Finished Successfully.");

$finish;
end

initial 
begin
$monitor("Time=%0t ns | rst_=%b | enable=%b | data=%h | out=%h",$time, rst_, enable, data, out);
end
  
endmodule
