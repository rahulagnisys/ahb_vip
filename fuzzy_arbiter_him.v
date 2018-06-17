
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:58 10/27/2015 
// Design Name: 
// Module Name:    fuzzy_arbiter 
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
module fuzzy_arbiter_him(
    input M_req_0,
    input M_req_1,
    input M_req_2,
    input M_req_3,
	 input clk,
	 input rst,
	 input enable_u,
    output  reg grant_0,
	 output  reg grant_1,
	 output  reg grant_2,
	 output  reg grant_3
    );



parameter  low=2'b00, med=2'b01,high=2'b11;  // used gray code to reduce power.

reg [15:0] M_req_0_count,M_req_1_count,
        M_req_2_count,M_req_3_count;
reg [15:0] M_grant_0_count,M_grant_1_count,
        M_grant_2_count,M_grant_3_count;
reg enable;
reg [1:0] Ap0,Ap1,Ap2,Ap3;	  		  
wire [15:0] acceptance_rate0,acceptance_rate1,
          acceptance_rate2,acceptance_rate3;
		  
wire gr0,gr1,gr2,gr3;
reg M_grant_0,M_grant_1,M_grant_2,M_grant_3;		  
		  
		  // -x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x dynamic aribter instantiatin -x-x-x-x-x-x-x-x-x-x-xx-
	arbiter ar(gr0,gr1,gr2,gr3,M_req_0,M_req_1,M_req_2,M_req_3,clk2,rst,enable);	 

//-x-x-x-x-x-x-x-x- functin divider -x-x-x-x-x-x-x-x-x-x-x-x-x-		  
function automatic [15:0] quotient;
input [15:0] dividend, divider;
reg [31:0] scaled_divider, temp_remainder, temp_result;
integer i;
begin
if(divider==0)
  begin
   quotient='bx;
	end
	else
	begin
scaled_divider = {1'b0, divider, 15'h0000};
temp_remainder = {16'h0000, dividend};

for(i = 0;i < 16; i = i + 1) begin
temp_result = temp_remainder - scaled_divider;

if(temp_result[31 - i]) begin // Negative result, Quotient set to '0'
quotient[15 - i] = 1'b0;
end
else begin // Positive result, Quotient set to '1'
quotient[15 - i] = 1'b1;
temp_remainder = temp_result;
end

scaled_divider = scaled_divider >> 1;
end

//remainder = temp_remainder[15:0];
end
end

endfunction

//-x-x-x-x-x-x-x-x- gated clck fr dynamic arbiter -x-x-x-x-x-x-x
assign clk2=enable?clk:'bz;


// logic and condition  for fuzzy and dynamic arbiter

	always @(posedge clk, posedge rst)
	 begin
     if(rst==1)
       begin
        	M_grant_0<=1'b1;
         M_grant_1<=1'b0;
         M_grant_2<=1'b0;
         M_grant_3<=1'b0;
			end
    else 
    begin
	 	case({M_req_0, M_req_1, M_req_2, M_req_3,enable_u})
		//5'b00001: begin   M_grant_0<=1'b0; M_grant_1<=1'b0; M_grant_2<=1'b0; M_grant_3<=1'b0; end // park mode 
		5'b00011: begin M_grant_3<=1'b1;M_grant_2<=1'b0;M_grant_1<=1'b0;M_grant_0<=1'b0;end
		5'b00101: begin M_grant_2<=1'b1;M_grant_3<=1'b0;M_grant_1<=1'b0;M_grant_0<=1'b0;end
		5'b00111: begin 
		        if((Ap2==low && Ap3==low)||(Ap2==med && Ap3==med)||(Ap2==high && Ap3==high)) begin
						enable=1'b1;end
						else if(Ap2==low && (Ap3==med || Ap3==high))begin
						M_grant_2<=1'b1;M_grant_3<=1'b0;M_grant_1<=1'b0;M_grant_0<=1'b0;enable=1'b0;end 
						else if(Ap3==low && (Ap2 == high || Ap2 ==med))begin
						M_grant_2<=1'b0;M_grant_3<=1'b1;M_grant_1<=1'b0;M_grant_0<=1'b0;enable=1'b0;end
						end
				
		5'b01001: begin 	M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;end
		5'b01011: begin if((Ap1==low && Ap3==low)||(Ap1==med && Ap3==med)||(Ap1==high && Ap3==high))
						begin
						enable=1'b1;
						end
						else if(Ap1==low && (Ap3==med || Ap3==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap3==low && (Ap1 == high || Ap1 ==med))begin
						  M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b1;enable=1'b0;end
						end
						
		5'b01101: begin if((Ap1==low && Ap2==low)||(Ap1==med && Ap2==med)||(Ap1==high && Ap2==high))
						begin
						enable=1'b1; end
						else if(Ap1==low && (Ap2==med || Ap2==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end 
						else if(Ap2==low && (Ap1 == high || Ap1 ==med))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b1;M_grant_3<=1'b0;enable=1'b0;end
						end
		5'b01111 : begin if((Ap1==low && Ap2==low && Ap3== low)||(Ap1==med && Ap2== med && Ap3==med)||(Ap1==high && Ap2 == high && Ap3==high))
						begin
						enable=1'b1; end
						else if(Ap1==low && (Ap2==med || Ap2==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap2==low && (Ap1==med || Ap1==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b1;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap3==low && (Ap1==med || Ap1==high) &&(Ap2==med || Ap2==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b1;end
						end
		5'b10001	: begin	M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;end	
		5'b10011	: begin if((Ap0==low && Ap3==low)||(Ap0==med && Ap3==med)||(Ap0==high && Ap3==high))
						begin
						enable=1'b1;end
						else if(Ap0==low && (Ap3==med || Ap3==high))begin
						M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end 
						else if(Ap3==low && (Ap0 == high || Ap0 ==med))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b1;enable=1'b0;end
						end
		5'b10101 : begin if((Ap0==low && Ap2==low)||(Ap0==med && Ap2==med)||(Ap0==high && Ap2==high))
						begin
						enable=1'b1; end
						else if(Ap0==low && (Ap2==med || Ap2==high))begin
						M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end 
						else if(Ap2==low && (Ap0 == high || Ap0 ==med))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b1;M_grant_3<=1'b0;enable=1'b0;end
						end
						
		5'b10111 : begin  if((Ap0==low && Ap2==low && Ap3== low)||(Ap0==med && Ap2== med && Ap3==med)||(Ap0==high && Ap2 == high && Ap3==high))
						begin
						enable=1'b1; end
						else if(Ap0==low && (Ap2==med || Ap2==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0; enable=1'b0;end
						else if(Ap2==low && (Ap0==med || Ap0==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b1;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap3==low && (Ap0==med || Ap0==high) &&(Ap2==med || Ap2==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b1;enable=1'b0;end
						end
					
		5'b11001 : begin if((Ap0==low && Ap1==low)||(Ap0==med && Ap1==med)||(Ap0==high && Ap1==high))
						begin
						enable=1'b1;end
						else if(Ap0==low && (Ap1==med || Ap1==high))begin
						M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end 
						else if(Ap1==low && (Ap0 == high || Ap0 ==med))begin
						M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						end
						
		5'b11011 : begin if((Ap0==low && Ap1==low && Ap3== low)||(Ap0==med && Ap1== med && Ap3==med)||(Ap0==high && Ap1 == high && Ap3==high))
						begin
						enable=1'b1;end
						else if(Ap0==low && (Ap1==med || Ap1==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end 
						else if(Ap1==low && (Ap0==med || Ap0==high) &&(Ap3==med || Ap3==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap3==low && (Ap0==med || Ap0==high) &&(Ap1==med || Ap1==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b1;enable=1'b0;end
						end
						
		5'b11101 : begin  if((Ap0==low && Ap1==low && Ap2== low)||(Ap0==med && Ap1== med && Ap2==med)||(Ap0==high && Ap1 == high && Ap2==high))
						begin
						enable=1'b1;end
						else if(Ap0==low && (Ap1==med || Ap1==high) &&(Ap2==med || Ap2==high))begin
					  M_grant_0<=1'b1;M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap1==low && (Ap0==med || Ap0==high) &&(Ap2==med || Ap2==high))begin
					  M_grant_0<=1'b0;M_grant_1<=1'b1;M_grant_2<=1'b0;M_grant_3<=1'b0;enable=1'b0;end
						else if(Ap2==low && (Ap0==med || Ap0==high) &&(Ap1==med || Ap1==high))begin
						M_grant_0<=1'b0;M_grant_1<=1'b0;M_grant_2<=1'b1;M_grant_3<=1'b0;enable=1'b0;end
						end
						
		5'b11111: begin  if((Ap0==low && Ap1==low && Ap2 == low && Ap3== low)||(Ap0==med && Ap1== med && Ap2 == med && Ap3==med)||(Ap0==high && Ap1 == high && Ap2== high && Ap3==high))
						begin
						enable=1'b1;end
						else if(Ap0==low && (Ap1==med || Ap1==high) &&(Ap3==med || Ap3==high)&& (Ap2==med || Ap2==high))begin
						M_grant_0 <=1'b1; M_grant_1<=1'b0;M_grant_2<=1'b0;M_grant_3<=1'b0; enable=1'b0;end
						else if(Ap1==low && (Ap0==med || Ap0==high) &&(Ap3==med || Ap3==high)&& (Ap2==med || Ap2==high))begin
						M_grant_0 <=1'b0;M_grant_1 <=1'b1;M_grant_2 <=1'b0;M_grant_3 <=1'b0;enable=1'b0;end
						else if(Ap2==low && (Ap0==med || Ap0==high) &&(Ap1==med || Ap1==high)&& (Ap3==med || Ap3==high))begin
						M_grant_0 <=1'b0;M_grant_1 <=1'b0; M_grant_2 <=1'b1; M_grant_3 <=1'b0;enable=1'b0;end
						else if(Ap3==low && (Ap0==med || Ap0==high) &&(Ap1==med || Ap1==high)&& (Ap2==med || Ap3==high))begin
					M_grant_0 <=1'b0;M_grant_1 <=1'b0;M_grant_2 <=1'b0;M_grant_3 <=1'b1;enable=1'b0;end 
										end						 	   						  
				
						
						endcase  
						   end
						   end
	 // For Master 0
	//always@(gr0,gr1,gr2,gr3,M_grant_0,M_grant_1,M_grant_2,M_grant_3)
	always@(*)
	begin
	  if(enable)
	    begin
	grant_0=  gr0;
	grant_1= gr1;
	grant_2=  gr2;
	grant_3=  gr3;
	end
	else 
	begin
	grant_0=  M_grant_0;
	grant_1= M_grant_1;
	grant_2=  M_grant_2;
	grant_3=  M_grant_3;
	end
	
	end
	
	/****--master_0 */
	
		assign acceptance_rate0=quotient(M_grant_0_count,M_req_0_count)*100;
		 
		 always @(posedge clk ,posedge rst)
         begin
			 if(rst==1'b1)
			    M_req_0_count='b0;
			else
			 if(M_req_0)
             M_req_0_count=M_req_0_count+16'd1;		 
       end
		
		  always @(acceptance_rate0)
		    begin
		  if(acceptance_rate0>=0 && acceptance_rate0<'d18)
		      Ap0=low;
		  
		  else if(acceptance_rate0>='d18 &&acceptance_rate0< 'd72)
             Ap0=med;
        else if(acceptance_rate0>72)
           Ap0=high;
			 else
           Ap0=low;			 
        end
	  
	  always @(posedge grant_0, posedge rst)
	      begin
			 if(rst)
			  M_grant_0_count<=16'd0;
			  else
			  M_grant_0_count<=M_grant_0_count+1;
			  end
	  // for master 1
	  assign acceptance_rate1=quotient(M_grant_1_count,M_req_1_count)*100;
		 
		 always @(posedge clk ,posedge rst)
         begin
			 if(rst==1'b1)
			    M_req_1_count='b0;
			else
			 begin
			 if(M_req_1)
             M_req_1_count=M_req_1_count+16'd1;		 
       end
		 end
		  always @(acceptance_rate1)
		    begin
		  if(acceptance_rate1>=0 && acceptance_rate1<'d18)
		      Ap1=low;
		  
		  else if(acceptance_rate1>='d18 && acceptance_rate1< 'd72)
             Ap1=med;
        else if(acceptance_rate1>72)
           Ap1=high;
			 else
           Ap1=low;
     end
	  
	  always @(posedge grant_1, posedge rst)
	      begin
			 if(rst)
			  M_grant_1_count<=0;
			  
			  else
			  M_grant_1_count<=M_grant_1_count+1;
			  end
	  
	  // for master 2
	  assign acceptance_rate2=quotient(M_grant_2_count,M_req_2_count)*100;
		 
		 always @(posedge clk ,posedge rst)
         begin
			 if(rst==1'b1)
			    M_req_2_count='b0;
			else
			if(M_req_2)
             M_req_2_count=M_req_2_count+16'd1;		 
       end
		 
		  always @(acceptance_rate2)
		    begin
		  if(acceptance_rate2>=0 && acceptance_rate2<'d18)
		      Ap2=low;
		  
		  else if(acceptance_rate2>='d18 && acceptance_rate2< 'd72)
             Ap2=med;
        else if(acceptance_rate2>72)
           Ap2=high;
			 else
           Ap2=low;
     end
	  always @(posedge grant_2, posedge rst)
	      begin
			 if(rst)
			  M_grant_2_count<=0;
			  
			  else
			  M_grant_2_count<=M_grant_2_count+1;
			  end
	  //for master 3
	  
	  assign acceptance_rate3=quotient(M_grant_3_count,M_req_3_count)*100;
		 
		 always @(posedge clk,posedge  rst)
         begin
			 if(rst==1'b1)
			    M_req_3_count='b0;
			else
			if(M_req_3 )
             M_req_3_count=M_req_3_count+16'd1;		 
       end
		 
		  always @(acceptance_rate3)
		    begin
		  if(acceptance_rate3>=0 && acceptance_rate3<'d18)
		      Ap3=low;
		  
		  else if(acceptance_rate3>='d18 && acceptance_rate3< 'd72)
             Ap3=med;
        else if(acceptance_rate3>72)
           Ap3=high;
			 else
           Ap3=low;
     end
	  
	  always @(posedge grant_3, posedge rst)
	      begin
			 if(rst)
			  M_grant_3_count<=0;
			  
			  else
			  M_grant_3_count<=M_grant_3_count+1;
			  end
	  
		  
	  
endmodule

