`timescale 1ns/1ps

import testbench_package::*; 

module tb_top();

bit CLK_50;    
bit CLK_80;

wire                    CLK;

reg                     clk_0 = 0, clk_1 = 0;

reg                     r_startup_rst = 1'b1;

wire                    w_si;
reg     [ 11 : 0 ]      r_adc_data;
wire    [ 11 : 0 ]      w_adc_data;

reg                     r_encoder_event = 1'b0;

wire                    w_sys_clk   = top.w_clk_1;
wire    [ 31 : 0 ]      w_pixels    = top.w_pixels;
wire                    w_pixels_dv = top.w_pixels_dv;
wire                    w_pixels_full;

wire    [ 12 : 0 ]      wr_data_count;
wire                    wr_rst_busy;


wire                    w_fifo_rd_en;
wire    [ 127 : 0 ]     w_fifo_data;
wire                    w_fifo_empty;
wire    [  10 : 0 ]     rd_data_count;
wire                    rd_rst_busy;

wire                    w_fifo_dv;



wire    [ 27 : 0 ]      sdram0_address;
wire    [  7 : 0 ]      sdram0_burstcount;
wire                    sdram0_waitrequest;  
wire    [127 : 0 ]      sdram0_readdata;
wire                    sdram0_readdatavalid;
wire                    sdram0_read;
wire    [127 : 0 ]      sdram0_writedata;
wire    [ 15 : 0 ]      sdram0_byteenable;
wire                    sdram0_write;

wire    [127 : 0 ]      sdram_data_swapped;

reg                     r_sdram0_waitrequest = 1'b0;

reg                     linux_reset = 1'b0;
reg                     dma_on = 1'b0;
reg                     enable_sensor = 1'b0;
reg     [ 28 : 0 ]      mode_n_indexs;
reg     [ 27 : 0 ]      dma_start_address;
reg     [ 27 : 0 ]      dma_buf_size;
reg                     mode_cyclic;

wire    [ 15 : 0 ]      w_dma_done_cnt;



localparam              size_dma_alloc = 32*1024*1024;
localparam              size_dma_alloc_words = size_dma_alloc >> 2;

localparam              line_bytes_size = 2592 * 6;

initial
begin
    repeat(50)   @(posedge CLK_50);
    r_startup_rst <= 1'b0;
end

initial forever #(20/2)     CLK_50 = ~CLK_50;
initial forever #(6.25)   CLK_80 = ~CLK_80;
//initial forever #(3.90625)   CLK_80 = ~CLK_80;
//initial forever #(125/2)    clk_0 = ~clk_0;
initial forever #(62.5)    clk_0 = ~clk_0;

initial
begin
    #(125/2);
forever #(125/2)    clk_1 = ~clk_1;
end


assign w_adc_data = r_adc_data ^ 12'h800;

assign top.w_bus_clk = CLK_80;
assign top.w_clk_0 = clk_0;
assign top.w_clk_1 = clk_1;
assign top.w_linux_reset = linux_reset;
assign top.w_encoder_event = r_encoder_event;

initial
begin
    // force top.w_r_clk_on_off = 24'd2592;
    // force top.w_g_clk_on_off = 24'd2592;
    // force top.w_b_clk_on_off = 24'd2592;

    force top.w_r_clk_on_off = 24'd0;
    force top.w_g_clk_on_off = 24'd2592;
    force top.w_b_clk_on_off = 24'd100;

    //force top.w_cis_lines_delay = 24'd222;
    force top.w_cis_mode = 2'd0;
    force top.w_cis_lines_delay = 24'd10000;

    force top.w_sensor_reset = 1'b1;

    repeat(10)  @(posedge clk_0);
    force top.w_sensor_reset = 1'b0;

    repeat(10) @(posedge CLK_80);
    linux_reset <= 1'b1;
    repeat(20) @(posedge CLK_80);
    linux_reset <= 1'b0;
end



initial
begin

    forever 
    begin
        @(posedge w_si);
        r_adc_data <= 12'd1;
        repeat(89)  @(posedge CLK);

        repeat(2592) 
        begin
            @(posedge CLK)
            r_adc_data <= r_adc_data + 1'b1;
        end

        r_adc_data <= 12'd0;

    end
end

top top
(
    .FPGA_CLK1_50   ( CLK_50        ),
    .FPGA_CLK2_50   ( CLK_50        ),
    
    .CLKC           ( CLK           ),
    .DC             ( w_adc_data    ),

    .LRGB           (               ),
    .SIC            ( w_si          ),
    .SCLKC          (               ),

    .SW             ( 4'b0011       ),
    //.SW             ( 4'b0001       ),

    .LED            (               )
);

//assign wr_data_count = 13'd0;



initial
begin
    forever
    begin
        repeat(10000)    @(posedge clk_1);
        //repeat(1000)    @(posedge clk_1);
        r_encoder_event <= ~r_encoder_event;
    end
end

/*
CUniversalRand          v1;
//assign top.w_wr_afull = (wr_data_count >= 13'd4080) ? 1'b1 : 1'b0;
assign top.w_wr_afull = (wr_data_count >= 13'd1080) ? 1'b1 : 1'b0;

fifo_generator_0 fifo_generator_0 
(
    .rst            ( r_startup_rst         ),                      // input wire rst
    .wr_clk         ( w_sys_clk             ),                // input wire wr_clk
    .din            ( w_pixels              ),                      // input wire [31 : 0] din
    .wr_en          ( w_pixels_dv           ),                  // input wire wr_en
    .full           ( w_pixels_full         ),                    // output wire full
    .wr_data_count  ( wr_data_count         ),  // output wire [12 : 0] wr_data_count
    .wr_rst_busy    ( wr_rst_busy           ),      // output wire wr_rst_busy

    .rd_clk         ( CLK_80                ),                // input wire rd_clk
    .rd_en          ( w_fifo_rd_en          ),                  // input wire rd_en
    .dout           ( w_fifo_data           ),                    // output wire [127 : 0] dout
    .empty          ( w_fifo_empty          ),                  // output wire empty
    .rd_data_count  ( rd_data_count         ),  // output wire [10 : 0] rd_data_count
    .rd_rst_busy    ( rd_rst_busy           )      // output wire rd_rst_busy
);







simple_dma dma_ctrl
(
    .CLK                            ( CLK_80                    ),     // in   , u[1],
    .SRST                           ( linux_reset               ),     // in   , u[1],
    
    .START_ADR                      ( dma_start_address         ),     // in   , u[28],
    .BUF_SIZE                       ( dma_buf_size              ),     // in   , u[28],
    .START                          ( dma_on                    ),     // in   , u[1],
    .DONE_CNT                       ( w_dma_done_cnt            ),     // out  , u[16],
    
    .FIFO_DATA                      ( w_fifo_data               ),     // in   , u[128],
    .FIFO_EMPTY                     ( w_fifo_empty              ),     // in   , u[1],
    .FIFO_TREADY                    ( w_fifo_rd_en              ),     // out  , u[1],
    .FIFO_DATA_CNT                  ( rd_data_count             ),  
    
    .SDRAM_WRITEDATA                ( sdram0_writedata          ),     // out  , u[128],
    .SDRAM_ADDRESS                  ( sdram0_address            ),     // out  , u[28],
    .SDRAM_WRITE                    ( sdram0_write              ),     // out  , u[1],
    .SDRAM_WAITREQUEST              ( sdram0_waitrequest        )      // in   , u[1],
);

assign sdram0_waitrequest = r_sdram0_waitrequest;

assign sdram_data_swapped[ 31 :  0 ] = {sdram0_writedata[ 15:  0],sdram0_writedata[ 31 : 16]};
assign sdram_data_swapped[ 63 : 32 ] = {sdram0_writedata[ 47: 32],sdram0_writedata[ 63 : 48]};
assign sdram_data_swapped[ 95 : 64 ] = {sdram0_writedata[ 79: 64],sdram0_writedata[ 95 : 80]};
assign sdram_data_swapped[127 : 96 ] = {sdram0_writedata[111: 96],sdram0_writedata[127 :112]};






initial
begin

    repeat(10) @(posedge CLK_80);
    linux_reset <= 1'b1;
    repeat(20) @(posedge CLK_80);
    linux_reset <= 1'b0;

    repeat(20) @(posedge CLK_80);
    mode_cyclic     <= 1'b0;
    enable_sensor   <= 1'b1;


    //simple_dma_process(32'h00000000, line_bytes_size*4);
    simple_dma_process(32'h00000000, line_bytes_size*32);

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



always @(posedge CLK_80)
if(sdram0_write & ~sdram0_waitrequest)
    check_cnt16(65535);
    //check_cnt32();





initial
begin
    //v1 = new(10,200);
    v1 = new(10,150);

    @(posedge dma_on);

    forever 
    begin
        @(posedge sdram0_write);
        @(posedge CLK_80);

        r_sdram0_waitrequest = 1'b1;
        v1.randomize();
        repeat(v1.randval) @(posedge  CLK_80);

        r_sdram0_waitrequest = 1'b0;
    end
end


task automatic start_dma(input int buf_adr, input int buf_size);
begin
    dma_on              <= 1'b1;
    dma_start_address   <= buf_adr;
    dma_buf_size        <= buf_size;
    @(posedge CLK_80);
    dma_on              <= 1'b0;
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
        idx_in_dma_alloc++;

        written_cmds++;
    end

    buffers_cnt = w_dma_done_cnt;



    released_buffers_cnt = buffers_cnt - buffers_cnt_prev;
    buffers_cnt_prev = buffers_cnt;

    if(released_buffers_cnt)
    begin

        if(buffers_cnt % 128 == 0)
            $display("done %d buffers\n", buffers_cnt);

        //printf("released_buffers_cnt=%d\n", released_buffers_cnt);
        //msync(dma_alloc,size_dma_alloc, MS_SYNC);
        fifo_slots_free += released_buffers_cnt;

        read_idx += (released_buffers_cnt * buf_size_words);
        read_idx &= (size_dma_alloc_words - 1);
        
    end

    //repeat(20000) @(posedge CLK_80);

    //$display("start wait %t",$time());
    //#800000;
    //#400000;
    
    //#100000;
    
    //#1000;
    //$display("end wait %t",$time());
  end
  $display("done %d buffers\n", w_dma_done_cnt);
end
endtask



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


task automatic check_cnt16(input int max);
static int ref_cnt = 0;
begin
    for(int i = 7; i >= 0; i--)
    begin
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

        //if((ref_cnt % 2591) == 0)
        //    $display("%m: received pixel block at %t", $time());
    end
end
endtask
*/

endmodule    