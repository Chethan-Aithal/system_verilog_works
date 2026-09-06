`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2026 10:38:52
// Design Name: 
// Module Name: mem_top
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


module mem_top;
bit clk;
wire read;
wire write;
wire [4:0]addr;
wire [7:0]data_out;      // data_from_mem
wire [7:0]data_in;       // data_to_mem
//  implicit .* port connections
mem_tb test (.*);
//  implicit .name port connections
mem memory (.clk, .read, .write, .addr,.data_in, .data_out);
always #5 clk=~clk;

endmodule
