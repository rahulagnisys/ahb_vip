
`timescale 1ns/1ns 
 
`include "AHB_MASTER.v" 
`include "AHB_SLAVE.v" 
`include "top_bus.v" 
`include "ham_4m.v"

//`include "demo_amba_for_tb.v"

module test_sh; 
 reg           hclk; 
 reg          hresetn; 
  
// master 0 signals 
wire HREADY_0;
wire  [1:0]  hresp_0;
wire [31:0]  haddr_0; 
wire [1:0] htrans_0; 
wire    hwrite_0; 
wire [2:0] hsize_0; 
wire [2:0] hburst_0; 
wire [31:0] hwdata_0;
wire [31:0]   hrdata_0; 
wire hbusreq_0; 
wire hgrant_0; 
//wire			mst0_req_done_0; 
reg	      mst0_rd_req_0; 
reg			mst0_wr_req_0;
reg [31:0]  src_addr_0;
reg [2:0] block_size_0;

// master 1 signals 
wire HREADY_1;
wire  [1:0]  hresp_1;
wire [31:0]  haddr_1; 
wire [1:0] htrans_1; 
wire    hwrite_1; 
wire [2:0] hsize_1; 
wire [2:0] hburst_1; 
wire [31:0] hwdata_1;
wire [31:0]   hrdata_1; 
wire hbusreq_1; 
wire hgrant_1; 
//wire			mst1_req_done_1; 
reg	 		mst1_rd_req_1; 
reg			mst1_wr_req_1;
reg	[31:0]  src_addr_1; 
reg [2:0] block_size_1;
 
 

// master 2 signals 
wire HREADY_2;
wire  [1:0]  hresp_2;
wire [31:0]  haddr_2; 
wire [1:0] htrans_2; 
wire    hwrite_2; 
wire [2:0] hsize_2; 
wire [2:0] hburst_2; 
wire [31:0] hwdata_2;
wire [31:0]   hrdata_2; 
wire hbusreq_2; 
wire hgrant_2; 
//wire			mst2_req_done_2; 
reg	 		mst2_rd_req_2; 
reg			mst2_wr_req_2;
reg [2:0] block_size_2;
reg	[31:0]  src_addr_2;  

// master 3 signals 
wire        HREADY_3;
wire [1:0]  hresp_3;
wire [31:0] haddr_3; 
wire [1:0]  htrans_3; 
wire        hwrite_3; 
wire [2:0]  hsize_3; 
wire [2:0]  hburst_3; 
wire [31:0] hwdata_3;
wire [31:0] hrdata_3; 
wire        hbusreq_3; 
wire        hgrant_3; 
//wire			mst3_req_done_3; 
reg	 		mst3_rd_req_3; 
reg			mst3_wr_req_3;
reg [2:0]   block_size_3;
reg [31:0]  src_addr_3;


// slave 0 signals
wire hreadys_0; 
wire [1:0] Hresps_0; 
wire [31:0] HRDATAS_0;
wire [3:0] HSPLIT_0;
wire  hsel0,HWRITE_S_0;
wire HMASTLOCK;
wire [31:0] HADDRS_0;
wire [33:0] HWDATAS_0;
wire [2:0] HSIZE_S_0;
wire [2:0] HBURST_S_0;
wire [1:0] HTRANS_s_0; 
wire [3:0] HMASTER;

//slave 1 signals 
wire hreadys_1; 
wire [1:0] Hresps_1; 
wire [31:0] HRDATAS_1;
wire [3:0] HSPLIT_1;
wire  hsel1,HWRITE_S_1;
wire [31:0] HADDRS_1;
wire [33:0] HWDATAS_1;
wire [2:0] HSIZE_S_1;
wire [2:0] HBURST_S_1;
wire [1:0] HTRANS_s_1; 
 
// slave 2 signals 
wire hreadys_2; 
wire [1:0] Hresps_2; 
wire [31:0] HRDATAS_2;
wire [3:0] HSPLIT_2;
wire  hsel2,HWRITE_S_2;
wire [31:0] HADDRS_2;
wire [33:0] HWDATAS_2;
wire [2:0] HSIZE_S_2;
wire [2:0] HBURST_S_2;
wire [1:0] HTRANS_s_2; 

// slave 3 signals 
wire hreadys_3; 
wire [1:0] Hresps_3; 
wire [31:0] HRDATAS_3;
wire [3:0] HSPLIT_3;
wire  hsel3,HWRITE_S_3;
wire [31:0] HADDRS_3;
wire [33:0] HWDATAS_3;
wire [2:0] HSIZE_S_3;
wire [2:0] HBURST_S_3;
wire [1:0] HTRANS_s_3;  



// *-*-*-*instantiation of bus*-*-*_*-*-*-*-//

top_bus bus( hbusreq_3,hbusreq_2,hbusreq_1,hbusreq_0,hclk,hresetn,
          haddr_0,haddr_1,haddr_2,haddr_3,
          htrans_0,htrans_1,htrans_2,htrans_3,
          hwrite_0,hwrite_1,hwrite_2,hwrite_3,
          hburst_0,hburst_1,hburst_2,hburst_3,
          hgrant_0,hgrant_1,hgrant_2,hgrant_3,
          hwdata_0,hwdata_1,hwdata_2,hwdata_3,
          hsize_0,hsize_1, hsize_2,hsize_3, 
          hreadys_0,hreadys_1,hreadys_2,hreadys_3,
          HREADY_0,HREADY_1,HREADY_2,HREADY_3,
          hsel0,hsel1,hsel2,hsel3,
          hresp_0,hresp_1,hresp_2,hresp_3,
          HWRITE_S_0,HWRITE_S_1,HWRITE_S_2,HWRITE_S_3,
          HRDATAS_0,HRDATAS_1,HRDATAS_2,HRDATAS_3,
			 HWDATAS_0,HWDATAS_1,HWDATAS_2,HWDATAS_3,
          HTRANS_s_0,HTRANS_s_1,HTRANS_s_2,HTRANS_s_3,
          HSIZE_S_0,HSIZE_S_1,HSIZE_S_2,HSIZE_S_3,
          HBURST_S_0,HBURST_S_1,HBURST_S_2,HBURST_S_3,
          HADDRS_0,HADDRS_1,HADDRS_2,HADDRS_3,
          Hresps_0,Hresps_1,Hresps_2,Hresps_3,
          HMASTER
  );


//*************instantiation of encoder and decoder***********//


 
 AHB_MASTER m0( hclk, hresetn,HREADY_0,hresp_0, 
     hgrant_0,hbusreq_0,htrans_0,hwrite_0, 
     hsize_0, hburst_0, haddr_0, hwdata_0, 
	  hrdata_0,mst0_wr_req_0, mst0_rd_req_0,           
     src_addr_0,block_size_0); 

 AHB_MASTER m1( hclk, hresetn,HREADY_1,hresp_1, 
     hgrant_1,hbusreq_1,htrans_1,hwrite_1, 
     hsize_1, hburst_1, haddr_1, hwdata_1, 
	  hrdata_1,mst1_wr_req_1, mst1_rd_req_1,           
     src_addr_1,block_size_1); 

 AHB_MASTER m2( hclk, hresetn,HREADY_2,hresp_2, 
     hgrant_2,hbusreq_2,htrans_2,hwrite_2, 
     hsize_2, hburst_2, haddr_2, hwdata_2, 
	  hrdata_2,mst2_wr_req_2, mst2_rd_req_2,            
     src_addr_2,block_size_2); 

 AHB_MASTER m3( hclk, hresetn,HREADY_3,hresp_3, 
     hgrant_3,hbusreq_3,htrans_3,hwrite_3, 
     hsize_3, hburst_3, haddr_3, hwdata_3, 
	 hrdata_3,  mst3_wr_req_3, mst3_rd_req_3,          
     src_addr_3,block_size_3); 


AHB_Slave s0(hreadys_0,Hresps_0,HRDATAS_0,HSPLIT_0,
          hsel0,HADDRS_0,HWRITE_S_0,HTRANS_s_0,HSIZE_S_0,
          HBURST_S_0,HWDATAS_0,hresetn,hclk,HMASTER);
 

AHB_Slave s1(hreadys_1,Hresps_1,HRDATAS_1,HSPLIT_1,
          hsel1,HADDRS_1,HWRITE_S_1,HTRANS_s_1,HSIZE_S_1,
          HBURST_S_1,HWDATAS_1,hresetn,hclk,HMASTER);
 

AHB_Slave s2(hreadys_2,Hresps_2,HRDATAS_2,HSPLIT_2,
          hsel2,HADDRS_2,HWRITE_S_2,HTRANS_s_2,HSIZE_S_2,
          HBURST_S_2,HWDATAS_2,hresetn,hclk,HMASTER);
 

AHB_Slave s3(hreadys_3,Hresps_3,HRDATAS_3,HSPLIT_3,
          hsel3,HADDRS_3,HWRITE_S_3,HTRANS_s_3,HSIZE_S_3,
          HBURST_S_3,HWDATAS_3,hresetn,hclk,HMASTER);
 

initial
hclk=1'b0;
initial
forever
#5 hclk=~hclk;

initial
begin
 #1hresetn=1;
  #1hresetn=0;
   #10hresetn=1;
   #1 mst0_rd_req_0=0;
     mst0_wr_req_0=1;
     src_addr_0=32'd0;
     block_size_0=3'b011;
	  
 // #280
  //mst1_wr_req_1=1;
  //src_addr_1=32'd0;
  //block_size_1=3'b011;
 
 
 
 end
 

 


endmodule


