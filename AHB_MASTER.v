`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:33:04 02/15/2016 
// Design Name: 
// Module Name:    AHB_MASTER 
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
module AHB_MASTER 
   ( 
     // AHB Master Interface 
     hclk, 
     hreset, 
 
     hready_i, 
     hresp_i, 
     hgrant_i, 
 
     hbusreq_o, 
     htrans_o, 
     hwrite_o, 
     hsize_o, 
     hburst_o, 
 
     haddr_o, 
     hwdata_o, 
	  hrdata_i, 
	 wr_req,
	 rd_req,
	 src_addr,
    block_size
  ); 
 
// AHB Interface 
 
input           hclk;                // This clock times all bus transfers 
input           hreset;             // AHB reset signal 
input           hready_i;           // when active indicates that 
                                    // a transfer has finished on the bus 
input   [1:0]   hresp_i;            // transfer response from AHB Slave 
                                    // (OKAY,ERROR,RETRY,SPLIT) 
input           hgrant_i;           // bus grant from AHB Arbiter 
 
output          hbusreq_o;          // bus request to AHB Arbiter 
output reg [1:0]htrans_o;           // type of current transfer 
output          hwrite_o;           // type of current transfer 
                                    // (NONSEQ,SEQ,IDLE,BUSY) 
output  [2:0]   hsize_o;            // size of current transfer 
output  [2:0]   hburst_o;           // Burst type 
output  [31:0]  haddr_o;            // Address out onto AHB for Rd/Wr 
input   [31:0]  src_addr;
output  [31:0]  hwdata_o;           // Write data out to AHB for Rx  
input   [31:0]  hrdata_i;           // Read data from AHB for Tx 

input [2:0] block_size;
	// State Machine Interface 
input	 		rd_req; 
input			wr_req;   

reg [7:0] memory[65535:0];       

wire              hbusreq_o; 
reg               hwrite_o; 
wire   [2:0]      hsize_o; 
reg    [2:0]      hburst_o; 
reg  [31:0]      haddr_o; 
reg   [31:0]      hwdata_o; 
 
wire			req_done; 
wire		[2:0]	word_count; 
wire	[31:0]  dataout;			
reg wait_busy;
// Internal register declarations 
reg    [3:0]      ahb_master_state;     // AHB Master I/F S/M State bits 
reg    [3:0]      state_prev_clk;       // AHB Master I/F S/M State bits 
                                      // delayed by 1-clock 
 
reg         [3:0] burst_count;
wire              lastbrstrd;           // Last Burst Read 
wire              lastbrstwr;           // Last Burst write
reg				   burstwrflag_last_n; 
reg    [29:0]      haddr_reg;            // upper 30-bits of HADDR 
wire   [29:0]      nextaddr;             // upper 30-bits of HADDR 
reg    [29:0]      haddr_prev;           // lower address bits of the previous 
                                        // transfer.  Used to restore address 
                                        // in case of RETRY/SPLIT 
reg               ahm_busreq_reg;       // AHB registered request signal 
                                        // used with busreq_comb to generate 
                                        // ahm_busreq O/P to AHB arbiter 
reg               busreq_prev;          // AHB access request signal delayed 

integer i ; // for testting the bus and intialise the memory;
 
// ****************************************************** 
// AHB Master Interface State Machine Encoding 
// ****************************************************** 
parameter         AHM_IDLE       =  4'b0000; 
parameter         AHM_BREQ       =  4'b0001; 
parameter         AHM_NSEQWR     =  4'b0010; 
parameter         AHM_SEQWR      =  4'b0011; 
parameter         AHM_WRWAIT     =  4'b0101; 
parameter         AHM_RETRY      =  4'b0110; 
parameter         AHM_LASTWR     =  4'b0111; 
//parameter         AHM_GOIDLE     =  4'b1000; 
parameter         AHM_NSEQRD     =  4'b1001; 
parameter         AHM_SEQRD      =  4'b1010; 
parameter         AHM_RDWAIT     =  4'b1011; 
parameter         AHM_LASTRD     =  4'b1101; 

 
// ****************************************************** 
// Parameter Definition for AHB Transfer Type(HTRANS) 
// ****************************************************** 
parameter         IDLE                = 2'b00; 
parameter         BUSY                = 2'b01; 
parameter         NONSEQ              = 2'b10; 
parameter         SEQ                 = 2'b11; 
   
// ****************************************************** 
// Parameter Definition for AHB Transfer Type(HBURST) 
// ****************************************************** 
parameter         SINGLE              = 3'b000; 
parameter         INCR                = 3'b001; 
parameter         INCR4               = 3'b011; 
parameter         INCR8               = 3'b101; 
parameter         INCR16              = 3'b111; 
   
// ****************************************************** 
// Parameter Definition for AHB Transfer SIZE(HSIZE) 
// ****************************************************** 
parameter         BYTE                = 3'b000; 
parameter         HALFWORD            = 3'b001; 
parameter         WORD                = 3'b010; 
   
// ****************************************************** 
// Parameter Definition for AHB Response Type(hresp_i) 
// ****************************************************** 
parameter         OKAY                = 2'b00; 
parameter         ERROR               = 2'b01; 
parameter         RETRY               = 2'b10; 
parameter         SPLIT               = 2'b11; 
   
// ****************************************************** 
// Parameter Definition for AHB Write/Read Command (HWRITE) 
// ****************************************************** 
parameter         READ                = 1'b0; 
parameter         WRITE               = 1'b1; 
 
// ********************************************************** 
 
//assign #2 dataout[31:0] = hrdata_i; 
 
// ********************************************************** 
// AHB Master I/F State Machine 
// ********************************************************** 
 
 
assign hsize_o = WORD;		   // Always WORD Transfer 
assign  hbusreq_o=ahm_busreq_reg;
assign word_count=block_size;
 
always @(negedge hclk or negedge hreset) 
begin 
 
   if(!hreset) begin 
 
      ahm_busreq_reg    <= 1'b0; 
      hwrite_o          <= READ; 
      hburst_o          <= SINGLE; 
      ahb_master_state  <= AHM_IDLE; 
      burst_count <= 0;
		wait_busy<=0;
		for (i=0;i<65536;i=i+1)
		  memory[i]=i+2;
   end 
 
   // error does not exist or previously generated abort is cleared 
   else 
	begin 
      case(ahb_master_state)   // synopsys full_case parallel_case 
         AHM_IDLE:  begin 
               if(rd_req || wr_req) begin			// DMA Read Cycle 
                 ahm_busreq_reg    <= 1'b1; 
                 ahb_master_state<=AHM_BREQ;
               end 
             else begin
               ahm_busreq_reg    <= 1'b0; 
               htrans_o <= IDLE;end
         end 
         // wait until bus is granted 
         AHM_BREQ:  begin 
               if(ahm_busreq_reg && hgrant_i ) begin 
                     if(wr_req) begin 
                       hwrite_o <= WRITE; 
                       ahb_master_state <=AHM_NSEQWR; 
                       htrans_o <= NONSEQ;
                       haddr_o <= src_addr;
							  hwdata_o<={memory[src_addr],memory[src_addr+1],memory[src_addr+2],memory[src_addr+3]};
                      
                     if(wr_req && (word_count == 3'b000)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o <= SINGLE; 
                       end 
                     
                     else if(wr_req && (word_count == 3'b011)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR4; 
                       end
                       else if(wr_req && (word_count == 3'b101)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR8; 
                       end
                       else if(wr_req && (word_count == 3'b111)) begin 
                         ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR16; 
                       end
                       else if (word_count == 5'b001)
							  begin 
                          hburst_o       <= INCR; 
								    ahm_busreq_reg <= 1'b1;
                       end 
                    end
                    // read transfer 
                    else  if(rd_req)
                     begin 
                         hwrite_o          <= READ; 
                        ahb_master_state    <= AHM_NSEQRD; 
                         htrans_o <= NONSEQ;
                         haddr_o <= src_addr;
                       // read request is single 
                       if (rd_req && (word_count == 3'b000)) begin 
                          hburst_o          <= SINGLE; 
                          ahm_busreq_reg    <= 1'b0; 
                       end 
                    else if(rd_req && (word_count == 3'b011)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR4; 
                       end
                       else if(rd_req && (word_count == 3'b101)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR8; 
                       end
                       else if(rd_req && (word_count == 3'b111)) begin 
                          ahm_busreq_reg <= 1'b0; 
                          hburst_o       <= INCR16; 
                       end
                       else if (word_count == 3'b000) begin
                          hburst_o       <= INCR; 
								  ahm_busreq_reg <= 1'b1;
                       end  
                    end 
                 end 
             else
                htrans_o <= IDLE;
         end 
         
// -x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx- AHM read oparation start -x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-
         
         AHM_NSEQRD:  begin 
               if(hgrant_i && hready_i) begin 
                     ahb_master_state <= AHM_RDWAIT; 
							haddr_o <= haddr_o+ 5'd4;
                     htrans_o <= BUSY;
                   end
                 else
                   htrans_o <= BUSY;
                 end
                 
        
  
         AHM_RDWAIT: begin
                 if(hgrant_i && hready_i)
                    begin
                      {memory[haddr_o],memory[haddr_o+1],memory[haddr_o+2],memory[haddr_o+3]}=hrdata_i;
                      if(rd_req && (word_count != 3'b000)) begin
                         ahb_master_state <= AHM_SEQRD;
                         htrans_o <= SEQ;
								 
                       end
                    else begin
                      ahb_master_state <= AHM_IDLE;
                      htrans_o <= IDLE;
                    end
                  end
            end
           
         // consecutive transfers of burst read 
         AHM_SEQRD:  begin 
               // target is ready to provide data 
               if(hgrant_i && hready_i)
                  begin
                     if(rd_req && (word_count == 3'b011)) begin 
                          if(burst_count==2)
                            begin
                              ahb_master_state<=AHM_LASTRD;
                            end
                          else begin
                            {memory[haddr_o],memory[haddr_o+1],memory[haddr_o+2],memory[haddr_o+3]}=hrdata_i;
                             burst_count <= burst_count+1;
									  haddr_o <= haddr_o+ 5'd4;
                             
                             end
                         end  
                       else if(rd_req && (word_count == 3'b101)) begin 
                          if(burst_count==6)
                            begin
                              ahb_master_state <= AHM_LASTRD;
                            end
                          else begin
                            {memory[haddr_o],memory[haddr_o+1],memory[haddr_o+2],memory[haddr_o+3]}=hrdata_i;
                             burst_count <= burst_count+1;
									  haddr_o <= haddr_o+ 5'd4;
                             end
                      end
                       else if(rd_req && (word_count == 3'b111)) begin 
                          if(burst_count==14)
                            begin
                              ahb_master_state<=AHM_LASTRD;
                            end
                          else begin
                            {memory[haddr_o],memory[haddr_o+1],memory[haddr_o+2],memory[haddr_o+3]}=hrdata_i;
                             burst_count <= burst_count+1;
									  haddr_o <= haddr_o+ 5'd4;
                             end
                       end   
                     end
                   end
          AHM_LASTRD: begin
			      if (hready_i) begin
                 burst_count <= 5'd0;
                 htrans_o <= IDLE;
                 {memory[haddr_o],memory[haddr_o+1],memory[haddr_o+1],memory[haddr_o+1]}=hrdata_i;
                 ahb_master_state <= AHM_IDLE;
               end end
					
					
// -x-x--x-x-x-x-x--x-xx--x-x-x--x-x-x-x-x- Write Operation starts -x-x-x-x-x-x-x-x-x-x-x-x-x

     AHM_NSEQWR:  begin 
               if(hgrant_i && hready_i) begin 
                     ahb_master_state    <= AHM_WRWAIT; 
                     htrans_o=BUSY;
							haddr_o <= haddr_o+ 5'd4;
                   end
                 else
                   htrans_o=BUSY;
                 end
    AHM_SEQWR:begin 
               if(hgrant_i && hready_i)
                  begin
                     if(wr_req && (word_count == 5'b011)) begin 
                          if(burst_count==2)
                            begin
                              ahb_master_state<=AHM_LASTWR;
                            end
                          else begin
								  hwdata_o<={memory[haddr_o+4],memory[haddr_o+5],memory[haddr_o+6],memory[haddr_o+7]};
                          haddr_o <= haddr_o+ 5'd4;
                             burst_count <= burst_count+1;
                             end
                         end  
                       else if(wr_req && (word_count == 3'b101)) begin 
                          if(burst_count==6)
                            begin
                              ahb_master_state <= AHM_LASTWR;
                            end
                          else begin
								  hwdata_o<={memory[haddr_o+4],memory[haddr_o+5],memory[haddr_o+6],memory[haddr_o+7]};
                            haddr_o<=haddr_o+ 5'd4;
                             burst_count <= burst_count+1;
                             end
                       end
                       else if(wr_req && (word_count == 3'b111)) begin 
                          if(burst_count==14)
                            begin
                              ahb_master_state<=AHM_LASTWR;
                            end
                          else begin
								  hwdata_o<={memory[haddr_o+4],memory[haddr_o+5],memory[haddr_o+6],memory[haddr_o+7]};
                             haddr_o <= haddr_o+ 5'd4;
                             burst_count <= burst_count+1;
                             end
                       end  
                       
                     end
                   end
    AHM_WRWAIT:begin
                 if(hgrant_i && hready_i)
                    begin
                      if(wr_req && (word_count != 3'b000)) begin
                         ahb_master_state <= AHM_SEQWR;
                         htrans_o <= SEQ;
						hwdata_o<={memory[haddr_o],memory[haddr_o+1],memory[haddr_o+2],memory[haddr_o+3]};
                       end
                    else begin
                      ahb_master_state <= AHM_IDLE;
                      htrans_o <= IDLE;
                    end
                  end
            end
    AHM_LASTWR:begin
                 burst_count <= 5'd0;
                 htrans_o <= IDLE;
                 ahb_master_state <= AHM_IDLE;
               end
         endcase
         end    
               
   end
   
   
 endmodule



