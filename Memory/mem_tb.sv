`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2026 11:51:43
// Design Name: 
// Module Name: mem_tb
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


module mem_tb
( input logic clk, 
  output logic read, 
  output logic write, 
  output logic [4:0] addr, 
  output logic [7:0] data_in,     // data TO memory
  input  wire [7:0] data_out     // data FROM memory
                );
bit debug=1;
logic[7:0] rdata;//stores data read from memory for checking


  initial 
  begin
      $timeformat( -9, 0, " ns", 9 );
#40000ns $display( "MEMORY TEST TIMEOUT" );
      $finish;
    end
initial
  begin: memtest
  int error_status;

    $display("Clear Memory Test");
    for (int i=0; i< 32; i++)
    //use of write task
       write_mem (i, 0, debug);
    for (int i=0; i<32; i++)
      begin 
      //use of read task
       read_mem (i, rdata, debug);
       // check each memory location for data = 'h00
       error_status=checkit (i, rdata, 8'h00);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);

    $display("Data = Address Test");
    for (int i = 0; i< 32; i++)
    //use of write task
       write_mem (i, i, debug);
    for (int i=0; i<32; i++)
      begin
      //use of read task
       read_mem (i, rdata, debug);
       // check each memory location for data = address
       error_status=checkit (i, rdata, i);
      end
// void function
    printstatus(error_status);

    $finish;
  end

//writing the memory
task write_mem (input [4:0] waddr, input [7:0] wdata, input debug = 0);
  @(negedge clk);
  write<=1;
  read<=0;
  addr<= waddr;
  data_in<=wdata;
  @(negedge clk);
  write<=0;
  if (debug == 1)
    $display("Write - Address:%d  Data:%h", waddr, wdata);
endtask

//reading the memory
task read_mem (input [4:0]raddr,output [7:0]rdata, input debug=0);
   @(negedge clk);
   write<=0;
   read<=1;
   addr<=raddr;
   @(negedge clk);
   read<=0;
   rdata=data_out;
   if (debug==1) 
   $display("Read  - Address:%d  Data:%h", raddr, rdata);
endtask

function int checkit (input [4:0] address, input [7:0] actual, expected);
  static int error_status;   // static variable
  if(actual!==expected) begin
$display("ERROR:  Address:%h  Data:%h  Expected:%h", address, actual, expected);
   error_status++;
   end
return (error_status);
endfunction: checkit

function void printstatus(input int status);
if (status==0)
$display("Test Passed - No Errors!");
else
$display("Test Failed with %d Errors",status);
endfunction

endmodule
