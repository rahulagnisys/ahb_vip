`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:54:52 03/02/2017 
// Design Name: 
// Module Name:    ham_4m 
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
module ham(data_in, data_out,clk,resetn);
input [31:0] data_in;
input clk,resetn;
reg [33:0] temp; 
output reg [33:0] data_out;

reg [33:0] invert,swap,i_e_l,i_o_l;
reg [33:0] invert_xor,swap_xor,i_e_l_xor,i_o_l_xor;

wire [5:0] hd_invert,hd_swap,hd_i_e_l,hd_i_o_l;

reg [5:0] hd_sel_i_s,hd_sel_el_ol;

reg [5:0] hd_sel1;

parameter Invert = 2'b00;
parameter Swap = 2'b01;
parameter Invert_even_line = 2'b10;
parameter Invert_odd_line = 2'b11;



always @(negedge clk,negedge resetn)
begin
if(!resetn)
 data_out<=0;
 else 
 data_out<=temp;
end 

always @(*)
 begin
 invert={~(data_in),Invert};
 swap ={data_in[31],data_in[28],data_in[29],data_in[26],data_in[27],data_in[24],data_in[25],data_in[22],
       data_in[23],data_in[20],data_in[21],data_in[18],data_in[19],data_in[16],data_in[17],data_in[14],
       data_in[15],data_in[12],data_in[13],data_in[10],data_in[11],data_in[8],data_in[9],data_in[6],
       data_in[7],data_in[4],data_in[5],data_in[2],data_in[3],data_in[0],data_in[1],Swap};
 
 i_e_l={data_in[31],~data_in[30],data_in[29],~data_in[28],
       data_in[27],~data_in[26],data_in[25],~data_in[24],data_in[23],~data_in[22],data_in[21],~data_in[20],
       data_in[19],~data_in[18],data_in[17],~data_in[16],data_in[15],~data_in[14],data_in[13],~data_in[12],
       data_in[11],~data_in[10],data_in[9],~data_in[8],data_in[7],~data_in[6],data_in[5],~data_in[4],
       data_in[3],~data_in[2],data_in[1],~data_in[0],Invert_even_line};
 
 i_o_l={~data_in[31],data_in[30],~data_in[29],data_in[28],
       ~data_in[27],data_in[26],~data_in[25],data_in[24],~data_in[23],data_in[22],~data_in[21],data_in[20],
       ~data_in[19],data_in[18],~data_in[17],data_in[16],~data_in[15],data_in[14],~data_in[13],data_in[12],
       ~data_in[11],data_in[10],~data_in[9],data_in[8],~data_in[7],data_in[6],~data_in[5],data_in[4],
       ~data_in[3],data_in[2],~data_in[1],data_in[0],Invert_odd_line};


invert_xor= invert^data_out;
 swap_xor = swap^data_out;
 i_e_l_xor= i_e_l^data_out;
 i_o_l_xor= i_o_l^data_out;
end

 hd_calcu_4m h1(invert_xor, hd_invert);
 hd_calcu_4m h2(swap_xor, hd_swap);
 hd_calcu_4m h3(i_e_l_xor, hd_i_e_l);
 hd_calcu_4m h4(i_o_l_xor, hd_i_o_l); 


always @(*)
 begin
   if(hd_invert<hd_swap)
      hd_sel_i_s=hd_invert;
   else if(hd_invert>hd_swap)
      hd_sel_i_s=hd_swap;
	else
	hd_sel_i_s=hd_invert;
	
	
	if(hd_i_e_l<hd_i_o_l)
      hd_sel_el_ol=hd_i_e_l;
   else if(hd_i_e_l>hd_i_o_l)
      hd_sel_el_ol=hd_i_o_l;
	else
	hd_sel_el_ol=hd_i_e_l;
end





always @(*)
	begin
		if(hd_sel_i_s<hd_sel_el_ol)
		      hd_sel1=hd_sel_i_s;
		else if (hd_sel_i_s>hd_sel_el_ol)
		      hd_sel1=hd_sel_el_ol;
		else
		hd_sel1=hd_sel_el_ol;
		end
	
	
	
	always@(*)		
			begin
			case(hd_sel1)
			
			 hd_invert:temp<=invert;
			 hd_swap:temp<=swap;
			 hd_i_e_l:temp<=i_e_l;
          hd_i_o_l:temp<=i_o_l;		
          default: temp<=~invert;
	
			
			 endcase
			
		end
		endmodule

  
