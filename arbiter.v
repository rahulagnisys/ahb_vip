`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:56:15 03/26/2014 
// Design Name: 
// Module Name:    arbiter 
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
module arbiter(gr0,gr1,gr2,gr3,r0,r1,r2,r3,clk,reset,enable);
output  gr0,gr1,gr2,gr3;
input r0,r1,r2,r3;
input clk,reset,enable;
//wire [3:0] random_data;
//lfsr1 x1(random_data,clk,reset);
     wire [3:0] t0,t1,t2,t3;
     wire [3:0] s0;
     wire [4:0] s1;
	  wire [5:0] s2,s3;
	  wire [5:0] random_no;
	  
	
     ticket_manager y1(t0,t1,t2,t3,clk,reset);
	  lottery_manager y2(s0,s1,s2,s3,r0,r1,r2,r3,t0,t1,t2,t3);
	  random_no_gen y3(random_no,clk,reset);
	  comparator_gen y4(g0,g1,g2,g3,s0,s1,s2,s3,r0,r1,r2,r3,random_no,clk,enable);
 
 assign  gr0=g0;
 assign  gr1=g1;
 assign  gr2=g2;
 assign  gr3=g3;

endmodule

