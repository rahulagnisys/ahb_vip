`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:29:10 03/03/2016 
// Design Name: 
// Module Name:    decoder 
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
module decoder(output reg hsel0,hsel1,hsel2,hsel3,
input [1:0]haddr
    );

always @(haddr)
 begin
  if(haddr==2'b00) begin
    hsel0=1'b1;
	 hsel1=1'b0;
	 hsel2=1'b0;
	 hsel3=1'b0;
	 end
	else if(haddr==2'b01) begin
    hsel0=1'b0;
	 hsel1=1'b1;
	 hsel2=1'b0;
	 hsel3=1'b0;
	 end
	 else if(haddr==2'b10) begin
    hsel0=1'b0;
	 hsel1=1'b0;
	 hsel2=1'b0;
	 hsel3=1'b1;
	 end
	 else if(haddr==2'b11) begin
    hsel0=1'b0;
	 hsel1=1'b0;
	 hsel2=1'b0;
	 hsel3=1'b1;
	 end
	 end
	 

endmodule

