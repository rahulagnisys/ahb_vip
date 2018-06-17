`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:03:50 03/25/2014 
// Design Name: 
// Module Name:    lottery_manager 
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
module lottery_manager(s0,s1,s2,s3,r0,r1,r2,r3,t0,t1,t2,t3);

output reg [3:0] s0;
output reg [4:0] s1;
output reg [5:0] s2,s3;
input r0,r1,r2,r3;
input [3:0] t0,t1,t2,t3;
reg [4:0] h0=0,h1=0,h2=0,h3=0;
//wire [3:0] t0,t1,t2,t3;
//ticket_manager y1(t0,t1,t2,t3,clk,reset);
always @(t0,t1,t2,t3)
begin
h0 =r0?t0:0;
h1 =r1?t1:0;
h2 =r2?t2:0;
h3 =r3?t3:0;
s0 =h0;
s1 =h0+h1;
s2 =h0+h1+h2;
s3 =h0+h1+h2+h3;
end
endmodule

