`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/23/2019 02:53:02 PM
// Design Name: 
// Module Name: hps_sim
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


import testbench_package::*; 

module hps_sim
(
    input   wire                    CLK_50,


    output  wire                    BUS_CLK_CLK,                 
    output  wire                    OUTCLK_0_CLK,                
    output  wire                    OUTCLK_1_CLK,                

    output  wire    [  31 : 0 ]     LED_CLK_ON_RED_EXPORT,       
    output  wire    [  31 : 0 ]     LED_CLK_ON_GREEN_EXPORT,     
    output  wire    [  31 : 0 ]     LED_CLK_ON_BLUE_EXPORT,      

    output  wire    [  31 : 0 ]     LINES_DELAY_EXPORT,          
    output  wire    [  31 : 0 ]     LINES_CNT_ENCODER_EXPORT,    
    
    input   wire    [  31 : 0 ]     TIMER_CNT_EXPORT,            

    output  wire    [  31 : 0 ]     CTRL_REG_OUT_PORT,           
    input   wire    [  31 : 0 ]     CTRL_REG_IN_PORT,            

    input   wire    [  31 : 0 ]     STATUS_REG_EXPORT,           

    output  wire    [  31 : 0 ]     DMA_BUF_SIZE_EXPORT,         
    output  wire    [  31 : 0 ]     DMA_ADR_EXPORT,              
    input   wire    [  31 : 0 ]     DMA_STATUS_EXPORT,           

    
    input   wire    [ 127 : 0 ]     SDRAM0_WRITEDATA,
    input   wire    [  27 : 0 ]     SDRAM0_ADDRESS,
    input   wire                    SDRAM0_WRITE,        
    output  wire                    SDRAM0_WAITREQUEST

);

bit                     CLK_80, clk_0, clk_1;

reg                     r_sdram0_waitrequest = 1'b0;
wire    [127 : 0 ]      sdram_data_swapped;

wire    [ 31 : 0 ]      w_ctrl_reg;


reg                     r_linux_reset = 1'b0;
reg                     r_sensor_reset = 1'b0;
reg                     r_dma_on = 1'b0;
reg     [  1 : 0 ]      r_cis_mode = 2'd0;

reg     [ 27 : 0 ]      r_dma_start_address, r_dma_buf_size;

CUniversalRand          v1;







localparam              size_dma_alloc = 32*1024*1024;
localparam              size_dma_alloc_words = size_dma_alloc >> 2;

localparam              line_bytes_size = 2592 * 6;
localparam              start_buf_adr = 32'h00000000;





initial forever #(6.25)   CLK_80 = ~CLK_80;
initial forever #(62.5)    clk_0 = ~clk_0;

initial
begin
    #(125/2);
forever #(125/2)    clk_1 = ~clk_1;
end


assign BUS_CLK_CLK          = CLK_80;
assign OUTCLK_0_CLK         = clk_0;
assign OUTCLK_1_CLK         = clk_1;
assign CTRL_REG_OUT_PORT    = w_ctrl_reg;
assign SDRAM0_WAITREQUEST   = r_sdram0_waitrequest;
assign DMA_BUF_SIZE_EXPORT  = r_dma_buf_size;
assign DMA_ADR_EXPORT       = r_dma_start_address;

assign sdram_data_swapped[ 31 :  0 ] = {SDRAM0_WRITEDATA[ 15:  0],SDRAM0_WRITEDATA[ 31 : 16]};
assign sdram_data_swapped[ 63 : 32 ] = {SDRAM0_WRITEDATA[ 47: 32],SDRAM0_WRITEDATA[ 63 : 48]};
assign sdram_data_swapped[ 95 : 64 ] = {SDRAM0_WRITEDATA[ 79: 64],SDRAM0_WRITEDATA[ 95 : 80]};
assign sdram_data_swapped[127 : 96 ] = {SDRAM0_WRITEDATA[111: 96],SDRAM0_WRITEDATA[127 :112]};




assign w_ctrl_reg[ 0 ]      = r_linux_reset;
assign w_ctrl_reg[ 1 ]      = r_sensor_reset;
assign w_ctrl_reg[ 2 ]      = r_dma_on;
assign w_ctrl_reg[ 3 ]      = 1'b0;
assign w_ctrl_reg[ 5 : 4 ]  = r_cis_mode;
assign w_ctrl_reg[31 : 6 ]  = 0;

initial
begin
    force LED_CLK_ON_RED_EXPORT     = ((200 << 16) | 10);
    force LED_CLK_ON_GREEN_EXPORT   = ((0 << 16) | 0);
    force LED_CLK_ON_BLUE_EXPORT    = ((1 << 16) | 0);

    r_cis_mode = 2'd0;
    force LINES_DELAY_EXPORT = 24'd10000;
    force LINES_CNT_ENCODER_EXPORT = 16'd3;

    r_sensor_reset = 1'b1;
    repeat(10)  @(posedge clk_0);
    r_sensor_reset = 1'b0;

    repeat(10) @(posedge CLK_80);
    r_linux_reset <= 1'b1;
    repeat(20) @(posedge CLK_80);
    r_linux_reset <= 1'b0;
end




initial
begin
    repeat(500) @(posedge CLK_80);

    simple_dma_process(start_buf_adr, line_bytes_size*32);

    // repeat(2500) @(posedge CLK_80);

    // repeat(10) @(posedge CLK_80);
    // linux_reset <= 1'b1;
    // repeat(20) @(posedge CLK_80);
    // linux_reset <= 1'b0;

    // simple_dma_process(32'h00000000, line_bytes_size*6);

    forever 
    begin
        @(posedge CLK_80);
    end
end



initial
begin
    
    v1 = new(10,150);
    //v1 = new(0,0);

    @(posedge r_dma_on);

    forever 
    begin
        @(posedge SDRAM0_WRITE);
        @(posedge CLK_80);

        r_sdram0_waitrequest = 1'b1;
        v1.randomize();
        repeat(v1.randval) @(posedge  CLK_80);

        r_sdram0_waitrequest = 1'b0;
    end
end




task automatic start_dma(input int buf_adr, input int buf_size);
begin
    r_dma_on            <= 1'b1;
    r_dma_start_address <= buf_adr;
    r_dma_buf_size      <= buf_size;
    @(posedge CLK_80);
    r_dma_on            <= 1'b0;
    @(posedge CLK_80);
end
endtask



task automatic simple_dma_process(input int adr, input int bytes_size);
int CMD_FIFO_SIZE = 1;
//const uint32_t buf_size_bytes = 16384;

//one line = 2592 samples * 6 bytes ((12+4)*3)

int buf_size_bytes = line_bytes_size;    
int buf_size_words = buf_size_bytes >> 2; 
int buf_size_dma   = buf_size_bytes >> 4;
int buf_adr_dma = adr;
int read_idx = 0;
int fifo_slots_free = CMD_FIFO_SIZE;
int buffers_cnt = 0, buffers_cnt_prev = 0, released_buffers_cnt = 0;

int i;
int idx_in_dma_alloc = 0;
//int test_buffers_cnt = 2048;
int test_buffers_cnt = bytes_size / buf_size_bytes;
int written_cmds = 0;

begin

  while(buffers_cnt < test_buffers_cnt)
  begin
    @(posedge CLK_80);

    while((fifo_slots_free > 0) && (written_cmds < test_buffers_cnt))
    begin
        @(posedge CLK_80);
      buf_adr_dma = adr + idx_in_dma_alloc * buf_size_dma;
      //printf("***%d\n", idx_in_dma_alloc * buf_size_dma);
      start_dma(buf_adr_dma, buf_size_dma);
      
      fifo_slots_free--;

      if(((idx_in_dma_alloc + 1) * buf_size_dma) >= (size_dma_alloc >> 4))
        idx_in_dma_alloc = 0;
      else
        //idx_in_dma_alloc++;
        idx_in_dma_alloc = idx_in_dma_alloc + 3;

        written_cmds++;
    end

    buffers_cnt = DMA_STATUS_EXPORT[15:0];



    released_buffers_cnt = buffers_cnt - buffers_cnt_prev;
    buffers_cnt_prev = buffers_cnt;

    if(released_buffers_cnt)
    begin

        if(buffers_cnt % 8 == 0)
            $display("done %d buffers\n", buffers_cnt);

        //printf("released_buffers_cnt=%d\n", released_buffers_cnt);
        //msync(dma_alloc,size_dma_alloc, MS_SYNC);
        fifo_slots_free += released_buffers_cnt;

        read_idx += (released_buffers_cnt * buf_size_words);
        read_idx &= (size_dma_alloc_words - 1);
        
    end

    repeat(500) @(posedge CLK_80);

    //$display("start wait %t",$time());
    //#800000;
    //#400000;
    
    //#100000;
    
    //#1000;
    //$display("end wait %t",$time());
  end
  $display("done %d buffers\n", DMA_STATUS_EXPORT[15:0]);
end
endtask


always @(posedge CLK_80)
begin
    if( ((SDRAM0_WRITE & ~SDRAM0_WAITREQUEST) == 1'b1) && (SDRAM0_ADDRESS >= r_dma_start_address)                      && (SDRAM0_ADDRESS < (r_dma_start_address +   r_dma_buf_size)))
        check_cnt16_0(65535);
    
    if( ((SDRAM0_WRITE & ~SDRAM0_WAITREQUEST) == 1'b1) && (SDRAM0_ADDRESS >= (r_dma_start_address +   r_dma_buf_size)) && (SDRAM0_ADDRESS < (r_dma_start_address + 2*r_dma_buf_size)))
        check_cnt16_1(65535);

    if( ((SDRAM0_WRITE & ~SDRAM0_WAITREQUEST) == 1'b1) && (SDRAM0_ADDRESS >= (r_dma_start_address + 2*r_dma_buf_size)) && (SDRAM0_ADDRESS < (r_dma_start_address + 3*r_dma_buf_size)))
        check_cnt16_2(65535);
end


int display_ref_cnt = 16384;

task automatic check_cnt16_0(input int max);
static int ref_cnt = 0;
begin
    for(int i = 7; i >= 0; i--)
    begin
        if(ref_cnt % display_ref_cnt == 0)
            $display("%m: ref_cnt = %X",ref_cnt);

        if(ref_cnt != sdram_data_swapped[i*16+:16])
        begin
            $display("%m: ref_cnt = %x, w_cnt = %x, time=%t",ref_cnt,sdram_data_swapped[i*16+:16],$time());
            ref_cnt = sdram_data_swapped[i*16+:16];

            @(posedge  CLK_80);
            $stop();
        end

        if(ref_cnt == max)
            ref_cnt = 0;
        else
            ref_cnt++;
    end
end
endtask

task automatic check_cnt16_1(input int max);
static int ref_cnt = 0;
begin
    for(int i = 7; i >= 0; i--)
    begin
        if(ref_cnt % display_ref_cnt == 0)
            $display("%m: ref_cnt = %X",ref_cnt);

        if(ref_cnt != sdram_data_swapped[i*16+:16])
        begin
            $display("%m: ref_cnt = %x, w_cnt = %x, time=%t",ref_cnt,sdram_data_swapped[i*16+:16],$time());
            ref_cnt = sdram_data_swapped[i*16+:16];

            @(posedge  CLK_80);
            $stop();
        end

        if(ref_cnt == max)
            ref_cnt = 0;
        else
            ref_cnt++;
    end
end
endtask

task automatic check_cnt16_2(input int max);
static int ref_cnt = 0;
begin
    for(int i = 7; i >= 0; i--)
    begin
        if(ref_cnt % display_ref_cnt == 0)
            $display("%m: ref_cnt = %X",ref_cnt);

        if(ref_cnt != sdram_data_swapped[i*16+:16])
        begin
            $display("%m: ref_cnt = %x, w_cnt = %x, time=%t",ref_cnt,sdram_data_swapped[i*16+:16],$time());
            ref_cnt = sdram_data_swapped[i*16+:16];

            @(posedge  CLK_80);
            $stop();
        end

        if(ref_cnt == max)
            ref_cnt = 0;
        else
            ref_cnt++;
    end
end
endtask




/*
task automatic check_cnt32();
static int ref_cnt = 0;
begin
    //for(int i = 0; i < 4; i++)
    for(int i = 3; i >= 0; i--)
    begin
        if(ref_cnt != w_fifo_data[i*32+:32])
        begin
            $display("%m: ref_cnt = %x, w_cnt = %x",ref_cnt,w_fifo_data[i*32+:32]);
            @(posedge  CLK_80);
            $stop();
        end

        $display("%m: done %d",ref_cnt);

        ref_cnt++;


        if((ref_cnt % 2591) == 0)
            $display("%m: received pixel block at %t", $time());
    end
end
endtask
*/

endmodule