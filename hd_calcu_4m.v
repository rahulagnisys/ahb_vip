`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:35 03/02/2017 
// Design Name: 
// Module Name:    hd_calcu_4m 
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
module hd_calcu_4m(input [33:0] a,
                   output reg [5:0] hd
                  );
  always @(a)
  begin
   hd <= (a[33]+a[32]+a[31]+a[30]+a[29]+a[28]+a[27]+
	a[26]+a[25]+a[24]+a[23]+a[22]+a[21]+a[20]+a[19]+a[18]
	+a[17]+a[16]+a[15]+a[14]+a[13]+a[12]+a[11]+a[10]+a[9]+
	a[8]+a[7]+a[6]+a[5]+a[4]+a[3]+a[2]+a[1]+a[0]);
  end
endmodule

