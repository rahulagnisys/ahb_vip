`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:53:02 04/18/2017 
// Design Name: 
// Module Name:    top_bus 
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:51:33 04/18/2017 
// Design Name: 
// Module Name:    top_bus_1 
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
`include "ham_4m.v"
module top_bus(
         input hbusreq_3,hbusreq_2,hbusreq_1,hbusreq_0,
         input clk,hrst,
         input [31:0]  haddr_0,haddr_1,haddr_2,haddr_3,
         input [1:0]   htrans_0,htrans_1,htrans_2,htrans_3,
         input  hwrite_0,hwrite_1,hwrite_2,hwrite_3,
         input [2:0] hburst_0,hburst_1,hburst_2,hburst_3,
         output  hgrant_0,hgrant_1,hgrant_2,hgrant_3,
         input [31:0]   hwdata_0,hwdata_1,hwdata_2,hwdata_3,
         input  [2:0]   hsize_0,hsize_1, hsize_2,hsize_3, 
         input          hreadys_0,hreadys_1,hreadys_2,hreadys_3,
         output         HREADY_0,HREADY_1,HREADY_2,HREADY_3,
         output  hsel0,hsel1,hsel2,hsel3,
         output [1:0] hresp_0,hresp_1,hresp_2,hresp_3,
         output  HWRITE_S_0,HWRITE_S_1,HWRITE_S_2,HWRITE_S_3,
         output  [31:0] HRDATAS_0,HRDATAS_1,HRDATAS_2,HRDATAS_3,
         output  [33:0] HWDATAS_0,HWDATAS_1,HWDATAS_2,HWDATAS_3,
         output [1:0] HTRANS_S_0,HTRANS_S_1,HTRANS_S_2,HTRANS_S_3,
         output [2:0] HSIZE_S_0,HSIZE_S_1,HSIZE_S_2,HSIZE_S_3,
         output [2:0] HBURST_S_0,HBURST_S_1,HBURST_S_2,HBURST_S_3,
         output  [31:0] HADDRS_0,HADDRS_1,HADDRS_2,HADDRS_3,
         input [1:0] Hresps_0,Hresps_1,Hresps_2,Hresps_3,
         output [3:0]HMASTER
         );

  wire [1:0] hresp;
  wire [3:0] master;
  wire [3:0] hbusreq;
  // wire hsel;
  wire [2:0] hburst;
  wire  [1:0] htrans;
  wire [3:0] hgrants;
  wire [31:0] haddr;
  wire [31:0] hwdata_o;
  wire [31:0] HRDATAS;
  wire  hwrite;
  wire [2:0] h_size;
  wire hready;
  wire [33:0] HWDATAS;

  //wire [31:0]HADDR_0,HADDR_1,HADDR_2,HADDR_3;
  
  assign hbusreq = {hbusreq_3,hbusreq_2,hbusreq_1,hbusreq_0};
  assign hgrant_0=hgrants[0];
  assign hgrant_1=hgrants[1];
  assign hgrant_2=hgrants[2];
  assign hgrant_3=hgrants[3];

  assign HMASTER= {hgrants[0],hgrants[1],hgrants[2],hgrants[3]};

  
  
  
assign haddr=hgrants[0]?haddr_0:(hgrants[1]?haddr_1:((hgrants[2]?haddr_2:haddr_3)));  
assign hburst=hgrants[0]?hburst_0:(hgrants[1]?hburst_1:((hgrants[2]?hburst_2:hburst_3)));
assign htrans=hgrants[0]?htrans_0:(hgrants[1]?htrans_1:((hgrants[2]?htrans_2:htrans_3)));
assign hwrite=hgrants[0]?hwrite_0:(hgrants[1]?hwrite_1:((hgrants[2]?hwrite_2:hwrite_3)));
assign hwdata_o=hgrants[0]?hwdata_0:(hgrants[1]?hwdata_1:((hgrants[2]?hwdata_2:hwdata_3)));  
assign h_size=hgrants[0]?hsize_0:(hgrants[1]?hsize_1:((hgrants[2]?hsize_2:hsize_3)));

assign hready=hsel0?hreadys_0:(hsel1?hreadys_1:((hsel2?hreadys_2:hreadys_3)));

//assign hwrite_o=hgrants[0]?hwrite_0:(hgrants[1]?hwrite_1:((hgrants[2]?hwrite_2:hwrite_3)));

//assign hsel=haddr[00]?hsel0:(haddr[01]?hsel1:((haddr[10]?hsel2:hsel3)));

assign hresp=hsel0?Hresps_0:(hsel1?Hresps_1:((hsel2?Hresps_2:Hresps_3)));



assign HWRITE_S_0=hsel0?hwrite:'bz;
assign HWRITE_S_1=hsel1?hwrite:'bz;
assign HWRITE_S_2=hsel2?hwrite:'bz;
assign HWRITE_S_3=hsel3?hwrite:'bz;

assign HREADY_0=hgrants[0]?hready:'bz;
assign HREADY_1=hgrants[1]?hready:'bz;
assign HREADY_2=hgrants[2]?hready:'bz;
assign HREADY_3=hgrants[3]?hready:'bz;

assign hresp_0=hgrants[0]?hresp:'bz;
assign hresp_1 =hgrants[1]?hresp:'bz;
assign hresp_2=hgrants[2]?hresp:'bz;
assign hresp_3=hgrants[3]?hresp:'bz;

assign hrdata_i=hsel0?HRDATAS_0:(hsel1?HRDATAS_1:((hsel2?HRDATAS_2:HRDATAS_3)));  

assign HADDRS_0=hsel0?haddr:'bz;
assign HADDRS_1=hsel1?haddr:'bz;
assign HADDRS_2=hsel2?haddr:'bz;
assign HADDRS_3=hsel3?haddr:'bz;

//assign hresp=hsel0?Hresps_0:(hsel1?Hresp_1:((hsel2?hresp_2:hresp_3)));

 assign HWDATAS_0=hsel0?HWDATAS:'bz;
 assign HWDATAS_1=hsel1?HWDATAS:'bz;
 assign HWDATAS_2=hsel2?HWDATAS:'bz;
 assign HWDATAS_3=hsel3?HWDATAS:'bz;
 
 assign HBURST_S_0=hsel0?hburst:'bz;
 assign HBURST_S_1=hsel1?hburst:'bz;
 assign HBURST_S_2=hsel2?hburst:'bz;
 assign HBURST_S_3=hsel3?hburst:'bz;
 
 assign HTRANS_S_0=hsel0?htrans:'bz;
 assign HTRANS_S_1=hsel1?htrans:'bz;
 assign HTRANS_S_2=hsel2?htrans:'bz;
 assign HTRANS_S_3=hsel3?htrans:'bz;

assign HSIZE_S_0=hsel0?h_size:'bz;
assign HSIZE_S_1=hsel1?h_size:'bz;
assign HSIZE_S_2=hsel2?h_size:'bz;
assign HSIZE_S_3=hsel3?h_size:'bz;
 

 ahbarb  A1(
	.hclk(clk),
	.hresetn(hrst),
	.hbusreqs(hbusreq),
	.haddr(haddr),
	.htrans(htrans),
	.hburst(hburst),
	.hresp(hresp),
	.hready(hready),
	.hgrants(hgrants),
	.hmaster(master)
);
  
decoder d1( hsel0,hsel1,hsel2,hsel3,
            haddr[1:0] 
				);

ham enc(.data_in(hwdata_o),
				 .data_out(HWDATAS),
				 .clk(clk),
				 .resetn(hrst)
				 );
 
endmodule

/*
module test_bus();
         reg hbusreq_3,hbusreq_2,hbusreq_1,hbusreq_0;
          reg clk,hrst;
          reg [31:0] haddr,hwdata_o;
         reg [2:0] hburst;
         reg [1:0] htrans;
         reg hwrite_o;
          wire  hgrant_0,hgrant_1,hgrant_2,hgrant_3;
         wire[1:0] hrsp;
         wire [31:0] data_i;
         wire hready;
         wire [31:0]HADDR;

initial
clk=1'b0;
initial
forever
#5 clk=~clk;


     endmodule */  