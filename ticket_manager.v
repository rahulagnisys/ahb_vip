`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:06:04 03/25/2014 
// Design Name: 
// Module Name:    ticket_manager 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ticket_manager(t0,t1,t2,t3,clk,reset);

output reg [3:0] t0,t1,t2,t3;
input clk,reset;
parameter seed0=4'd1,seed1=4'd2,seed2=4'd3,seed3=4'd4;
wire [3:0] i0,i1,i2,i3;
 
lfsr1  #(.seed(seed0)) l1(.random_data(i0),.clk(clk),.reset(reset));
lfsr1  #(.seed(seed1)) l2(.random_data(i1),.clk(clk),.reset(reset));
lfsr1  #(.seed(seed2)) l3(.random_data(i2),.clk(clk),.reset(reset));
lfsr1  #(.seed(seed3)) l4(.random_data(i3),.clk(clk),.reset(reset)); 

always @(negedge clk)
  begin
  t0<=i0;
  t1<=i1;
  t2<=i2;
  t3<=i3;
  end


endmodule
