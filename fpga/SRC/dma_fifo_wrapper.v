`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2019 04:59:56 PM
// Design Name: 
// Module Name: dma_fifo_wrapper
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


module dma_fifo_wrapper
(
    input   wire                    FIFO_CLK,
    input   wire    [ 31 : 0 ]      FIFO_DIN,
    input   wire                    FIFO_DIN_DV,
    output  wire    [ 11 : 0 ]      WR_CNT,

    input   wire                    DMA_CLK,
    input   wire                    SRST,
    input   wire    [ 27 : 0 ]      START_ADR,
    input   wire    [ 27 : 0 ]      BUF_SIZE,
    input   wire                    START,
    output  wire    [ 15 : 0 ]      DONE_CNT,
    output  wire                    CMD_FIFO_EMPTY,
    output  wire                    CMD_FIFO_AEMPTY,

    output  wire    [127 : 0 ]      SDRAM_WRITEDATA,
    output  wire    [ 27 : 0 ]      SDRAM_ADDRESS,
    output  wire                    SDRAM_WRITE,
    input   wire                    SDRAM_WAITREQUEST
);

wire                    w_fifo_rd_en;
wire    [ 127 : 0 ]     w_fifo_data;
wire                    w_fifo_empty;
wire    [  10 : 0 ]     rd_data_count;

fifo_generator_0 fifo_generator_0 
(
    .rst                            ( SRST                  ),                      // input wire rst
    .wr_clk                         ( FIFO_CLK              ),                // input wire wr_clk
    .din                            ( FIFO_DIN              ),                      // input wire [31 : 0] din
    .wr_en                          ( FIFO_DIN_DV           ),                  // input wire wr_en
    .full                           (                       ),                    // output wire full
    .wr_data_count                  ( WR_CNT                ),  // output wire [12 : 0] wr_data_count
    .wr_rst_busy                    (                       ),      // output wire wr_rst_busy
                
    .rd_clk                         ( DMA_CLK               ),                // input wire rd_clk
    .rd_en                          ( w_fifo_rd_en          ),                  // input wire rd_en
    .dout                           ( w_fifo_data           ),                    // output wire [127 : 0] dout
    .empty                          ( w_fifo_empty          ),                  // output wire empty
    .rd_data_count                  ( rd_data_count         ),  // output wire [10 : 0] rd_data_count
    .rd_rst_busy                    (                       )      // output wire rd_rst_busy
);


simple_dma dma_ctrl
(
    .CLK                            ( DMA_CLK               ),     // in   , u[1],
    .SRST                           ( SRST                  ),     // in   , u[1],
    
    .START_ADR                      ( START_ADR             ),     // in   , u[28],
    .BUF_SIZE                       ( BUF_SIZE              ),     // in   , u[28],
    .START                          ( START                 ),     // in   , u[1],
    .DONE_CNT                       ( DONE_CNT              ),     // out  , u[16],
    
    .FIFO_DATA                      ( w_fifo_data           ),     // in   , u[128],
    .FIFO_EMPTY                     ( w_fifo_empty          ),     // in   , u[1],
    .FIFO_TREADY                    ( w_fifo_rd_en          ),     // out  , u[1],
    .FIFO_DATA_CNT                  ( rd_data_count         ),  
    
    .SDRAM_WRITEDATA                ( SDRAM_WRITEDATA       ),     // out  , u[128],
    .SDRAM_ADDRESS                  ( SDRAM_ADDRESS         ),     // out  , u[28],
    .SDRAM_WRITE                    ( SDRAM_WRITE           ),     // out  , u[1],
    .SDRAM_WAITREQUEST              ( SDRAM_WAITREQUEST     )      // in   , u[1],
);


endmodule
