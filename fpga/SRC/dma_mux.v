`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2019 03:44:46 PM
// Design Name: 
// Module Name: dma_mux
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


module dma_mux
(
    input   wire                    CLK,
    input   wire                    RST,

    input   wire    [ 127 : 0 ]     DMA_0_DATA,
    input   wire    [  27 : 0 ]     DMA_0_ADR,
    input   wire                    DMA_0_WR,
    output  wire                    DMA_0_WAITREQ,

    input   wire    [ 127 : 0 ]     DMA_1_DATA,
    input   wire    [  27 : 0 ]     DMA_1_ADR,
    input   wire                    DMA_1_WR,
    output  wire                    DMA_1_WAITREQ,

    input   wire    [ 127 : 0 ]     DMA_2_DATA,
    input   wire    [  27 : 0 ]     DMA_2_ADR,
    input   wire                    DMA_2_WR,
    output  wire                    DMA_2_WAITREQ,


    output  wire    [ 127 : 0 ]     SDRAM_WRITEDATA,
    output  wire    [  27 : 0 ]     SDRAM_ADDRESS,
    output  wire                    SDRAM_WRITE,
    input   wire                    SDRAM_WAITREQUEST
);

wire    [ 127 : 0 ] w_dma_data  [ 2 : 0 ];
wire    [  27 : 0 ] w_dma_adr   [ 2 : 0 ];
wire    [   2 : 0 ] w_dma_wr, w_dma_waitreq;

reg     [   2 : 0 ] r_dma_waitreq = 3'd0;

reg     [ 1 : 0 ]   r_mux_cnt = 2'd0;

reg     [ 127 : 0 ] r_sdram_data;
reg     [  27 : 0 ] r_sdram_adr;
reg                 r_sdram_wr = 1'b0;

assign w_dma_data   [0] = DMA_0_DATA;
assign w_dma_adr    [0] = DMA_0_ADR;
assign w_dma_wr     [0] = DMA_0_WR;
assign DMA_0_WAITREQ    = w_dma_waitreq[0];

assign w_dma_data   [1] = DMA_1_DATA;
assign w_dma_adr    [1] = DMA_1_ADR;
assign w_dma_wr     [1] = DMA_1_WR;
assign DMA_1_WAITREQ    = w_dma_waitreq[1];

assign w_dma_data   [2] = DMA_2_DATA;
assign w_dma_adr    [2] = DMA_2_ADR;
assign w_dma_wr     [2] = DMA_2_WR;
assign DMA_2_WAITREQ    = w_dma_waitreq[2];



assign w_dma_waitreq[0] = r_dma_waitreq[0];
assign w_dma_waitreq[1] = r_dma_waitreq[1];
assign w_dma_waitreq[2] = r_dma_waitreq[2];



always @(posedge CLK)
if(SDRAM_WAITREQUEST == 1'b0)
    case(r_mux_cnt)
        2'd0 :  begin
                    r_sdram_data <= w_dma_data[0];
                    r_sdram_adr  <= w_dma_adr [0];
                    r_dma_waitreq[2] <= 1'b1;
                    
                    if(w_dma_wr[0] == 1'b1)
                    begin
                        r_sdram_wr   <= 1'b1;
                        r_dma_waitreq[0] <= 1'b0;
                    end
                    else
                    begin
                        r_sdram_wr       <= 1'b0;
                        r_dma_waitreq[0] <= 1'b1;
                        
                    end
                    r_mux_cnt        <= 2'd1;
                end
        2'd1 :  begin
                    r_sdram_data <= w_dma_data[1];
                    r_sdram_adr  <= w_dma_adr [1];
                    r_dma_waitreq[0] <= 1'b1;
                    
                    if(w_dma_wr[1] == 1'b1)
                    begin
                        r_sdram_wr   <= 1'b1;
                        r_dma_waitreq[1] <= 1'b0;
                    end
                    else
                    begin
                        r_sdram_wr       <= 1'b0;
                        r_dma_waitreq[1] <= 1'b1;
                        
                    end
                    r_mux_cnt        <= 2'd2;
                end
        2'd2 :  begin
                    r_sdram_data <= w_dma_data[2];
                    r_sdram_adr  <= w_dma_adr [2];
                    r_dma_waitreq[1] <= 1'b1;
                    
                    if(w_dma_wr[2] == 1'b1)
                    begin
                        r_sdram_wr   <= 1'b1;
                        r_dma_waitreq[2] <= 1'b0;
                    end
                    else
                    begin
                        r_sdram_wr       <= 1'b0;
                        r_dma_waitreq[2] <= 1'b1;
                        
                    end
                    r_mux_cnt        <= 2'd0;
                end
        default:begin
                    r_mux_cnt        <= 2'd0;
                    r_sdram_wr       <= 1'b0;
                end
    endcase
else
    r_dma_waitreq <= 3'b111;

assign SDRAM_WRITEDATA = r_sdram_data;
assign SDRAM_ADDRESS   = r_sdram_adr;
assign SDRAM_WRITE     = r_sdram_wr;

endmodule
