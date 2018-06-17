module ahbarb(
	hclk,
	hresetn,
	hbusreqs,
	haddr,
	htrans,
	hburst,
	hresp,
	hready,
	hgrants,
	hmaster
);

parameter HIGH =    1'b1; 
parameter LOW =     1'b0; 
 
//Transfer type from AHB Master 
parameter  IDLE      =    2'h0; 
parameter  BUSY      =    2'h1; 
parameter  NONSEQ    =    2'h2; 
parameter  SEQ       =    2'h3; 
 
// Read or write type 
parameter READ = 1'b0; 
parameter WRITE = 1'b1; 
 
// Type of the burst transfer 
parameter  SINGLE    =    3'h0; 
parameter  INCR      =    3'h1; 
parameter  INCR4     =    3'h3; 
parameter  INCR8     =    3'h5; 
parameter  INCR16    =    3'h7; 
 
// Slave Responses 
parameter  OKAY      =    2'h0; 
parameter  ERROR     =    2'h1; 
parameter  RETRY     =    2'h2; 
parameter  SPLIT     =    2'h3; 
 
// Transfer Size 
parameter  BUS_8     =    3'h0; 
parameter  BUS_16    =    3'h1; 
parameter  BUS_32    =    3'h2; 
parameter  BUS_64    =    3'h3; 
parameter  BUS_128   =    3'h4; 
parameter  BUS_256   =    3'h5; 
parameter  BUS_512   =    3'h6; 
parameter  BUS_1024  =    3'h7; 
 
// clocks and resets
input hclk;          	// ahb clock input
input hresetn;          // ahb poweron reset (active low)


// requests
input [3:0] hbusreqs;   // bus requests

// address and control signals
input [31:0] haddr;	  // address
input [1:0] htrans;	  // transfer type
input [2:0] hburst;	  // burst information
input [1:0] hresp;	  // transfer response
input       hready;	  // slave ready response
reg         enable;    //controlls the grant

// grant outputs
output [3:0] hgrants;            // grant for master 0
output  reg [3:0] hmaster;       // current granted master

// arb state assignments
parameter     BUS_PARK = 1'b0;
parameter     BUS_CYC  = 1'b1;

// local declarations
reg        arb_state;      // state vector for arbitration s/m
wire [3:0] hbusreq_in;		// request bus contains all hbusreq_in
reg  [3:0] bsize;	         // burst length counter
reg  [1:0] htrans_d;	      // latched version of htrans
wire       gated_clk;
reg  [6:0] count=6'b000000; 

//wire  [3:0] hgrant_w;
reg        time_out;
wire   [3:0]  hgrant ;
//assign gated_clk=hclk&&enable;
assign hgrants= {hgrant[3],hgrant[2],hgrant[1],hgrant[0]};

   fuzzy_arbiter_him  fuzzy(
                .M_req_0(hbusreqs[0]),
                .M_req_1(hbusreqs[1]),
                .M_req_2(hbusreqs[2]),
                .M_req_3(hbusreqs[3]),
	            .rst(rst),
	            .clk(hclk),
					.enable_u(enable),
               .grant_0(hgrant[0]),
	            .grant_1(hgrant[1]),
	            .grant_2(hgrant[2]),
	            .grant_3(hgrant[3])
    ); 

always @(hgrant[0],hgrant[1],hgrant[2],hgrant[3])
 begin
 hmaster={hgrant[0],hgrant[1],hgrant[2],hgrant[3]};
 end
 
always@(hgrant[0],hgrant[1],hgrant[2],hgrant[3],hresetn,hresp,time_out)
     begin
		  if(!hresetn || hresp==SPLIT||hresp==ERROR || time_out )
		    enable =1'b1;
		  else if((hgrant[0]==1)||(hgrant[1]==1)||(hgrant[2]==1)||(hgrant[3]==1))
		    enable=1'b0;
		  else 
		    enable=enable; 
     end
	
		     always @(negedge hclk,negedge hresetn)
            begin
             if (!hresetn)
              count<=7'b000000;
             else begin	
			     if(((hgrant[0]==1)||(hgrant[1]==1)||(hgrant[2]==1)||(hgrant[3]==1)) && hready==1'b1) 
			      begin
			      time_out<=1'b0;
			      if((htrans==BUSY)&&(hburst==SINGLE))
			       time_out<=1'b1;
			      else if ((htrans==BUSY) &&(hburst==INCR4||hburst==INCR8 ||hburst==INCR16||hburst==INCR))
                begin
                count<=count+1;
					 time_out<=1'b0;
					 end
               else if ((htrans==SEQ)&&(hburst==INCR4))
                begin
                 count<=count+1;
					  if(count==3) 
					   begin
					   time_out<=1'b1;
					   count<=7'b0000000;
					   end
					 end
			      else if ((htrans==SEQ)&&(hburst==INCR8))
                begin
                 count<=count+1;
					  if(count==7) 
					   begin
					   time_out<=1'b1;
					   count<=7'b0000000;
					   end
					 end
			      else if ((htrans==SEQ)&&(hburst==INCR16))
                begin
                 count<=count+1;
					  if(count==15)
					   begin
 					   time_out<=1'b1;
					   count<=7'b0000000;
					   end
					 end					
			      else if ((htrans==SEQ)&&(hburst==INCR))
                begin
                 count<=count+1;
					  if(count==128)  // 128 *8 = 1KB boundary
					   begin
					   time_out<=1'b1;
					   count<=7'b0000000;
					   end
					 end					
			     end	
            end			
	        end

endmodule
					 
