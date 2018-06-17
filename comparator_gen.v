`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:04:26 03/26/2014 
// Design Name: 
// Module Name:    comparator_gen 
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
module comparator_gen(gr0,gr1,gr2,gr3,s0,s1,s2,s3,r0,r1,r2,r3,random_no,clk,enable);
output reg gr0,gr1,gr2,gr3;
input [3:0]s0;
input clk,enable;
input[4:0]s1;
input [5:0]s2,s3;
input [5:0]random_no;
input r0,r1,r2,r3;

reg g0,g1,g2,g3;
  

	    always @ (s0,s1,s2,s3,random_no)
			begin
			 if(enable)
				begin
				 if(0<random_no && random_no<=s0 && r0==1)
					begin
					 g0=1; g1=0;g2=0; g3=0;
					end
				 else if(s0<random_no && random_no<=s1 && r1==1)
				   begin
				     g0=0; g1=1; g2=0; g3=0;
					end
				 else if(s1<random_no && random_no<=s2 && r2==1)
				   begin
				    g0=0;g1=0;g2=1;g3=0;
				   end
			    else if(s2<random_no && random_no<=s3 && r3==1)
			      begin
			       g0=0;g1=0;g2=0;g3=1;
			      end
			    else begin
			      g0=g0;
			      g1=g1;
			      g2=g2;
			      g3=g3;
			    end
			   end
			 else
		    	begin
			    g0=g0;
			    g1=g1;
			    g2=g2;
			    g3=g3;
			   end
			end

always @(posedge clk)
 begin
 gr0<=g0;
 gr1<=g1;
 gr2<=g2;
 gr3<=g3;
end
endmodule


