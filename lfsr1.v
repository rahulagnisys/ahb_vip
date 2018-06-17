`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:50 03/25/2014 
// Design Name: 
// Module Name:    lfsr1 
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
module lfsr1 #(parameter seed=4'b0001,size=4)(random_data,clk,reset);
output reg [size-1:0] random_data;
input clk,reset;
reg [3:0] im_data=seed;


always@ (negedge clk,posedge reset)
begin
if(reset)
random_data<=seed;
else
begin
im_data<={im_data[2:0],(im_data[3]^im_data[2])};
random_data<=im_data;
end
end

endmodule
