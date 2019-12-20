`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 12:45:33 PM
// Design Name: 
// Module Name: simple_dma
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


/*
simple_dma simple_dma
(
    .CLK                        (   ),     // in   , u[1],
    .SRST                       (   ),     // in   , u[1],

    .START_ADR                  (   ),     // in   , u[28],
    .BUF_SIZE                   (   ),     // in   , u[28],
    .START                      (   ),     // in   , u[1],
    .DONE                       (   ),     // out  , u[1],

    .FIFO_DATA                  (   ),     // in   , u[128],
    .FIFO_EMPTY                 (   ),     // in   , u[1],
    .FIFO_TREADY                (   ),     // out  , u[1],

    .SDRAM_WRITEDATA            (   ),     // out  , u[128],
    .SDRAM_ADDRESS              (   ),     // out  , u[28],
    .SDRAM_WRITE                (   ),     // out  , u[1],
    .SDRAM_WAITREQUEST          (   )      // in   , u[1],
);
*/


module simple_dma
(
    input   wire                    CLK,
    input   wire                    SRST,

    input   wire    [ 27 : 0 ]      START_ADR,
    input   wire    [ 27 : 0 ]      BUF_SIZE,
    input   wire                    START,
    output  wire    [ 15 : 0 ]      DONE_CNT,
    output  wire                    CMD_FIFO_EMPTY,
    output  wire                    CMD_FIFO_AEMPTY,

    input   wire    [127 : 0 ]      FIFO_DATA,
    input   wire                    FIFO_EMPTY,
    input   wire    [ 10 : 0 ]      FIFO_DATA_CNT,
    output  wire                    FIFO_TREADY,


    output  wire    [127 : 0 ]      SDRAM_WRITEDATA,
    output  wire    [ 27 : 0 ]      SDRAM_ADDRESS,
    output  wire                    SDRAM_WRITE,
    input   wire                    SDRAM_WAITREQUEST
);

reg                 r_start = 1'b0;
wire                w_fifo_cmd_wr;
wire                w_fifo_cmd_full, w_fifo_cmd_afull;

wire    [ 55 : 0 ]  w_fifo_cmd_data;
reg                 r_fifo_cmd_rd = 1'b0;
wire                w_fifo_cmd_empty, w_fifo_cmd_aempty;

wire    [ 27 : 0 ]  w_start_adr, w_buf_size;
reg                 r_fifo_cmd_dv = 1'b0;

reg     [ 27 : 0 ]  r_buf_adr, r_buf_size;
reg                 r_buf_params_dv = 1'b0;

reg                 r_transact_active = 1'b0;

reg     [ 27 : 0 ]  r_words_cnt; 

reg                 r_tready = 1'b0;

reg     [ 15 : 0 ]  r_done_cnt;

reg     [127 : 0 ]  r_sdram_wr_data;
reg     [ 27 : 0 ]  r_sdram_wr_adr;
reg                 r_sdram_wr;
wire                w_sdram_wr;

wire                w_sdram_transact;


assign w_fifo_cmd_wr = START & ~r_start;

fifo_bram_sync
#(
    .Z                          ( 0                     ),     //   Simulation delay
    .DATA_WIDTH                 ( 56                    ),     //   Data width 
    .DEPTH                      ( 3                     ),     //   Words count in FIFO, 2**DEPTH 
    .AFULL_OFFSET               ( 2                     ),     //   Sets almost full threshold. How many DIN_WR for FULL flag occurrence 
    .AEMPTY_OFFSET              ( 2                     )      //   Sets the almost empty threshold
)       
fifo_cmd
(       
    .CLK                        ( CLK                   ),     // in , u[1],
    .RST                        ( SRST                  ),     // in , u[1],
    
    .DIN                        ( {BUF_SIZE,START_ADR}  ),     // in , u[DATA_WIDTH],
    .DIN_WR                     ( w_fifo_cmd_wr         ),     // in , u[1],
    .DIN_FULL                   ( w_fifo_cmd_full       ),     // out, u[1],        full flag
    .DIN_AFULL                  ( w_fifo_cmd_afull      ),     // out, u[1],        almost full flag
    
    .DOUT                       ( w_fifo_cmd_data       ),     // out, u[DATA_WIDTH],
    .DOUT_RD                    ( r_fifo_cmd_rd         ),     // in , u[1],        read enable
    .DOUT_EMPTY                 ( w_fifo_cmd_empty      ),     // out, u[1],        empty flag
    .DOUT_AEMPTY                ( w_fifo_cmd_aempty     )      // out, u[1],        almost empty flag
);

assign CMD_FIFO_EMPTY  = w_fifo_cmd_empty;
assign CMD_FIFO_AEMPTY = w_fifo_cmd_aempty;

assign {w_buf_size, w_start_adr} = w_fifo_cmd_data;

always @(posedge CLK)
begin
    r_start         <= START;
    r_fifo_cmd_dv   <=#1 r_fifo_cmd_rd;

    if(r_fifo_cmd_dv == 1'b1)
    begin
        r_buf_adr   <= w_start_adr;     //in 16-bytes words
        r_buf_size  <= w_buf_size;      //in 16-bytes words
    end

    r_buf_params_dv <= r_fifo_cmd_dv;
end


always @(posedge CLK)
if(SRST == 1'b1)
begin
    r_transact_active <= 1'b0;
    r_done_cnt  <= 16'd0;
end
else
begin

    if(~w_fifo_cmd_empty & ~r_transact_active)
    begin
        r_transact_active <= 1'b1;
        r_fifo_cmd_rd <= 1'b1;
    end
    else
    begin
        r_fifo_cmd_rd <= 1'b0; 
        
        if((r_words_cnt == 28'd1) && (w_sdram_transact == 1'b1))
        begin
            r_transact_active <= 1'b0;
            r_done_cnt <= r_done_cnt + 1'b1;
        end
    end


end


assign w_sdram_wr = r_sdram_wr & ~FIFO_EMPTY;
assign w_sdram_transact = w_sdram_wr & ~SDRAM_WAITREQUEST;    

always @(posedge CLK)
if(SRST == 1'b1)
begin
    r_words_cnt <= 28'd0;
    r_tready    <= 1'b0;
    r_sdram_wr  <= 1'b0;
end
else
    if(r_buf_params_dv == 1'b1)
    begin
        r_words_cnt     <= r_buf_size;    
        r_sdram_wr_adr  <= r_buf_adr;
        r_tready        <= 1'b0;
        r_sdram_wr      <= 1'b0;
    end
    else
    begin
        if((|r_words_cnt == 1'b1) && (FIFO_EMPTY == 1'b0))
            r_sdram_wr <= 1'b1;
        else
            r_sdram_wr <= 1'b0;

        //r_tready    <= w_sdram_transact;

        if(w_sdram_transact == 1'b1)
        begin
            r_words_cnt <= r_words_cnt - 1'b1;
            r_sdram_wr_adr <= r_sdram_wr_adr + 1'b1;
        end

        //r_sdram_wr_data <= FIFO_DATA;
    end


//assign FIFO_TREADY      = r_tready;
assign FIFO_TREADY      = w_sdram_transact;

assign DONE_CNT         = r_done_cnt;

//assign SDRAM_WRITEDATA  = r_sdram_wr_data;
assign SDRAM_WRITEDATA  = FIFO_DATA;
assign SDRAM_ADDRESS    = r_sdram_wr_adr;
assign SDRAM_WRITE      = w_sdram_wr;
endmodule
