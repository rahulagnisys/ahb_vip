`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:14:05 03/25/2014 
// Design Name: 
// Module Name:    random_no_gen 
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

module random_no_gen#(parameter seed=6'b000001)(random_no,clk,reset);
output reg [5:0] random_no;
input clk,reset;
reg [5:0] im_data=seed;

always @(negedge clk, posedge reset)
  begin
    if(reset)
	  im_data<=seed;
	 else
 	 begin
    im_data<={im_data[4:0],im_data[5]^im_data[4],im_data[2]^im_data[1]};
	 random_no<=im_data;
	 end
	 end

endmodule
