`define IDLE        3'b000
`define ACTIVE      3'b001
`define AGAIN       3'b010
`define LITTLE      3'b011
`define WRITE_BURST 3'b100
`define READ_BURST  3'b101
 
 
`define NON_SEQ     2'd0
`define SEQ    2'd1
`define BUSY    2'd2
`define IDLE_TRANS  2'd3
 
`define OKAY  2'b00
`define ERROR 2'b01
`define RETRY 2'b10
`define SPLIT 2'b11

module AHB_Slave( HREADY,
HRESP,
HRDATA,
HSPLITx,
HSELx,
HADDR_d,
HWRITE,
HTRANS,
HSIZE,
HBURST,
HWDATA,
HRESETn,
HCLK,
HMASTER
);




parameter Invert = 2'b00;
parameter Swap = 2'b01;
parameter Invert_even_line = 2'b10;
parameter Invert_odd_line = 2'b11;



 
output  HREADY;
output [1:0] HRESP;
output [31:0] HRDATA;
output [3:0] HSPLITx;
 
 
input HSELx,HWRITE,HRESETn,HCLK;
input [31:0] HADDR_d;     //trying to creat delay
input [33:0] HWDATA;
input  [2:0] HSIZE;
input [2:0] HBURST;
input [3:0] HMASTER;
input [1:0] HTRANS;

///////////////////////////////////////////// Regiter declaration
reg [31:0] HADDR;

reg [31:0] HRDATA;
reg        HREADY;
reg  [1:0] HRESP;
reg  [3:0] HSPLITx;
reg  [4:0] local_addr;
reg  [3:0] SPLIT_RESP;
reg  [7:0] memory_slave[4095:0];
reg  [2:0] ps_slave1,ns_slave1;
reg [31:0] temp; 

reg [31:0] HWDATA_DEC;
reg  [1:0] m_state; 

integer count;

//reg [31:0]HWDATA_DEC_temp;
//always @(posedge HCLK)
//begin
 //HWDATA_DEC<=temp;
//end 
always @(negedge HCLK)
begin
temp<=HADDR_d;
HADDR<=temp;
end

always@(HWDATA) 
m_state<=HWDATA[1:0];

always @(*)
 begin
 case (m_state)
 
 Invert: HWDATA_DEC <= ~HWDATA[33:2];
 
 Swap  :HWDATA_DEC<= {HWDATA[32],HWDATA[33],HWDATA[30],HWDATA[31],HWDATA[28],HWDATA[29],HWDATA[26],HWDATA[27],
                HWDATA[24],HWDATA[25],HWDATA[22],HWDATA[23],HWDATA[20],HWDATA[21],HWDATA[18],HWDATA[19],
					 HWDATA[16],HWDATA[17],HWDATA[14],HWDATA[15],HWDATA[12],HWDATA[13],HWDATA[10],HWDATA[11],
					 HWDATA[8],HWDATA[9],HWDATA[6],HWDATA[7],HWDATA[4],HWDATA[5],HWDATA[2],HWDATA[3]};
 
 Invert_even_line: HWDATA_DEC<= {HWDATA[33],~HWDATA[32],HWDATA[31],~HWDATA[30],HWDATA[29],~HWDATA[28],
                           HWDATA[27],~HWDATA[26],HWDATA[25],~HWDATA[24],HWDATA[23],~HWDATA[22],
									HWDATA[21],~HWDATA[20],HWDATA[19],~HWDATA[18],HWDATA[17],~HWDATA[16],
									HWDATA[15],~HWDATA[14],HWDATA[13],~HWDATA[12],HWDATA[11],~HWDATA[10],
									HWDATA[9],~HWDATA[8],HWDATA[7],~HWDATA[6],HWDATA[5],~HWDATA[4],
                           HWDATA[3],~HWDATA[2]};
 
 Invert_odd_line: HWDATA_DEC<= {~HWDATA[33],HWDATA[32],~HWDATA[31],HWDATA[30],~HWDATA[29],HWDATA[28],
                          ~HWDATA[27],HWDATA[26],~HWDATA[25],HWDATA[24],~HWDATA[23],HWDATA[22],~HWDATA[21],HWDATA[20],
                          ~HWDATA[19],HWDATA[18],~HWDATA[17],HWDATA[16],~HWDATA[15],HWDATA[14],~HWDATA[13],HWDATA[12],
                          ~HWDATA[11],HWDATA[10],~HWDATA[9],HWDATA[8],~HWDATA[7],HWDATA[6],~HWDATA[5],HWDATA[4],
                          ~HWDATA[3],HWDATA[2]};
		 
 default :HWDATA_DEC<= ~HWDATA[33:2];

endcase
end



 
always @ (ps_slave1 or HRESETn or HSELx or HWDATA_DEC or HWRITE  or HADDR)
 
begin
case (ps_slave1)
 
`IDLE  :begin
         HREADY=1'b0;
         if(!HRESETn) begin
         ns_slave1=`IDLE;
		 HREADY=1'b0;
		 count=0;
		 end
         else if(HSELx==1'b1)
         begin
           HREADY=1'b1;
		   if(HWRITE)
		   ns_slave1=`WRITE_BURST;
		   else
		   ns_slave1=`READ_BURST;    
           end
		 else begin
		   HREADY=1'b0;
		   ns_slave1=`IDLE;
		 end
         end
          
`WRITE_BURST  : begin
         if (HRESETn && HSELx && HWRITE && HREADY)
         case(HBURST)
         3'b000 : begin
		             if(HADDR<=1048572) begin // because it can have access on to address location 2**32
                     {memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]}= HWDATA_DEC;
                     HREADY=1'b1; HRESP= `OKAY;
                     ns_slave1=`IDLE;
					 end
					 else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end
						  end
						  
 
			3'b001 : begin    // incrememting Burst unspecified Length
			        if(HADDR<=1048572) begin
						{memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]}=HWDATA_DEC;
						//HADDR=HADDR+4;
						HREADY=1'b1;
						HRESP= `OKAY;
						if(count<32)
						ns_slave1=`WRITE_BURST;
						else if(count==32)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
					end
				
						else if(HADDR>1048572 && HADDR<=2097148) 
						begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else
                    begin
						  HREADY=1'b0;
					     HRESP = `RETRY;
					     ns_slave1 =`IDLE;
						  end
					end
 
             3'b011 : begin///4 beat Incrementing Burst
			      if(HADDR<=1048572) begin // 
                     {memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]}=HWDATA_DEC;
                      //HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<4)
						ns_slave1=`WRITE_BURST;
						else if(count==4)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end
					  end
 

           3'b101 : begin  ///8 beat Incrementing Burst
                     if(HADDR<=1048572) begin // 
                     {memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]}=HWDATA_DEC;
                     // HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<8)
						ns_slave1=`WRITE_BURST;
						else if(count==8)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end
					  end
 
         3'b111 : begin
              if(HADDR<=1048572) begin // 
                     {memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]}=HWDATA_DEC;
                      //HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<16)
						ns_slave1=`WRITE_BURST;
						else if(count==16)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end
					  end
                  
 
          default : begin
                           HREADY=1'b0;HRESP= `ERROR;
                           ns_slave1=`IDLE;
                          end
        endcase//for WRITE operation
          else
           HRESP= `ERROR;
      end//if(WRIte operation)
 
`READ_BURST :
//READ Operation Starts Here
begin
              if(HRESETn && HSELx && !HWRITE)
 case(HBURST)
 
     3'b000 : begin
	 if(HADDR<=1048572) begin
HRDATA={memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]};
                        HREADY=1'b1; 
ns_slave1=`IDLE;HRESP= `OKAY;
 end//000--Single transfer
 end
3'b001 : begin 
if(HADDR<=1048572) begin // incrememting Burst unspecified Length
 HRDATA={memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]};
                    // HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<4)
						ns_slave1=`READ_BURST;
						else if(count==4)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						 else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end
                      end//001

 
3'b011 : begin
if(HADDR<=1048575) begin///4 beat Incrementing Burst
HRDATA={memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]};
//HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<4)
						ns_slave1=`READ_BURST;
						else if(count==4)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end  
					  end//011
 
3'b101 : begin 
if(HADDR<=1048575) begin ///8 beat Incrementing Burst
HRDATA={memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]};
//HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<4)
						ns_slave1=`READ_BURST;
						else if(count==4)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end 
 end//101
 

 
3'b111 : begin
if(HADDR<=1048575) begin
HRDATA={memory_slave[HADDR],memory_slave[HADDR+1],memory_slave[HADDR+2],memory_slave[HADDR+3]};
//HADDR=HADDR+4;
                      count=count+1;
					  HREADY=1'b1;
					   HRESP= `OKAY;
                      if(count<4)
						ns_slave1=`READ_BURST;
						else if(count==4)
						 begin
						 ns_slave1=`IDLE;
						 count=0;
						 end
						else begin
						count=count+1;
						end
						end
						else if(HADDR>1048572 && HADDR<=2097148) begin
					     HREADY=1'b0;
					     HRESP= `SPLIT;
					     ns_slave1=`SPLIT;
					  end
                   else begin
						  HREADY=1'b0;
					     HRESP= `RETRY;
					     ns_slave1=`IDLE;
						  end             
 end//111
 
default :  begin
                            HREADY=1'b0;HRESP= `ERROR;
                            ns_slave1=`IDLE;
                            end
 
endcase //for Read Operation   
         else
           HRESP= `ERROR;
         end
`SPLIT : begin
        HSPLITx=HMASTER;
		  ns_slave1= `IDLE;
        end
		 
endcase
 
end
 
always@(negedge HCLK,negedge HRESETn)
begin
  if(!HRESETn)
    ps_slave1=`IDLE;
  else
ps_slave1=ns_slave1;
end         
endmodule



