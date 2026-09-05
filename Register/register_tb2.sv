`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2026 09:40:19
// Design Name: 
// Module Name: register_tb2
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


module register_tb2;
logic [7:0] data;
logic clk=1'b1,rst_=1'b1,enable;
logic [7:0] out;

`define PERIOD 10
always
    #(`PERIOD/2) clk = ~clk; // same as #5 clk=~clk
    
    //instance of the register
    register R1(.clk(clk),.rst_(rst_),.enable(enable),.data(data),.out(out));
    
    //Monitor  results
    initial
    begin
    $timeformat ( -9, 1, " ns", 9 );
    $monitor("$time=%t enable=%b rst_=%b data=%h out=%h",$time,enable,rst_,data,out);
    #(`PERIOD*99)
    $display("Register test timeout");
    $finish;
    end
    
    //task to self check output
    task expect_test(input [7:0]expects);
    if(out!=expects)
    begin
    $display("out=%h,should be %h",out,expects);
    $display("Test case Failed");
    $finish;
    end
    endtask
    
    
    //test cases
     initial
    begin
      @(negedge clk)
      { rst_, enable, data }=10'b1_X_XXXXXXXX; 
      @(negedge clk) 
      expect_test ( 8'hXX );
      { rst_, enable, data }=10'b0_X_XXXXXXXX; 
      @(negedge clk) 
      expect_test ( 8'h00 );
      { rst_, enable, data }=10'b1_0_XXXXXXXX; 
      @(negedge clk) 
      expect_test ( 8'h00 );
      { rst_, enable, data }=10'b1_1_10101010; 
      @(negedge clk) 
      expect_test ( 8'hAA );
      { rst_, enable, data }=10'b1_0_01010101; 
      @(negedge clk) 
      expect_test ( 8'hAA );
      { rst_, enable, data }=10'b0_X_XXXXXXXX;
       @(negedge clk) 
       expect_test ( 8'h00 );
      { rst_, enable, data }=10'b1_0_XXXXXXXX; 
      @(negedge clk) 
      expect_test ( 8'h00 );
      { rst_, enable, data }=10'b1_1_01010101; 
      @(negedge clk) 
      expect_test ( 8'h55 );
      { rst_, enable, data }=10'b1_0_10101010; 
      @(negedge clk) 
      expect_test ( 8'h55 );
      $display ( "REGISTER TEST PASSED" );
      $finish;
    end

    
endmodule
