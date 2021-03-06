`timescale 1ns/1ps
//`default_nettype none

`define SIM


module top
(
    input   wire                    FPGA_CLK1_50,

    //ADC CLK   AF7
    output  wire                    CLKC_0,
    //PIN_AG6
    output  wire                    CLKC_1,
    //PIN_AG28
    output  wire                    CLKC_2,
    // AH2 AH3 AG5 AH4 AH6 AH5 T12 T8 U11 Y5 Y4 W8
    input   wire    [ 11 : 0 ]      DC_0,
    // AE12 AF11 AE11 AD12 AF10 AD11 AE9 AD10 AE8 AF9 AF6 AE7
    input   wire    [ 11 : 0 ]      DC_1,
    // AF25 AG24 AA19 AH26 AG18 AC23 AF20 AG19 AG20 AF21 AE22 AF23
    input   wire    [ 11 : 0 ]      DC_2,

    // [2:0] - RGB - AF8 Y8 AB4, active '0'
    output  wire    [  2 : 0 ]      LRGB_0,
    // [2:0] - RGB - AE4 T13 T11, active '0'
    output  wire    [  2 : 0 ]      LRGB_1,
    // [2:0] - RGB - AH27 AG26 AH24, active '0'
    output  wire    [  2 : 0 ]      LRGB_2,

    // W12
    output  wire                    SIC_0,
    // AF5
    output  wire                    SIC_1,
    // AA15
    output  wire                    SIC_2,
    // V12
    output  wire                    SCLKC_0,
    // AF4
    output  wire                    SCLKC_1,
    // Y15
    output  wire                    SCLKC_2,

    output  wire    [  7 : 0 ]      LED,

    input   wire    [  3 : 0 ]      SW,

    // {"GPIO_1[24] AE24", "GPIO_1[23] AE20", "GPIO_1[20] AE19"
    input   wire    [ 2 : 0 ]       ENC_P,      // {X, A, B}
    // {"GPIO_1[33] AE23", "GPIO_1[25] AD20", "GPIO_1[22] AD19"
    input   wire    [ 2 : 0 ]       ENC_N,      // {X,!A,!B}


    inout   wire                    HPS_CONV_USB_N,
    output  wire    [ 14 : 0 ]      HPS_DDR3_ADDR,
    output  wire    [  2 : 0 ]      HPS_DDR3_BA,
    output  wire                    HPS_DDR3_CAS_N,
    output  wire                    HPS_DDR3_CKE,
    output  wire                    HPS_DDR3_CK_N,
    output  wire                    HPS_DDR3_CK_P,
    output  wire                    HPS_DDR3_CS_N,
    output  wire    [  3 : 0 ]      HPS_DDR3_DM,
    inout   wire    [ 31 : 0 ]      HPS_DDR3_DQ,
    inout   wire    [  3 : 0 ]      HPS_DDR3_DQS_N,
    inout   wire    [  3 : 0 ]      HPS_DDR3_DQS_P,
    output  wire                    HPS_DDR3_ODT,
    output  wire                    HPS_DDR3_RAS_N,
    output  wire                    HPS_DDR3_RESET_N,
    input   wire                    HPS_DDR3_RZQ,
    output  wire                    HPS_DDR3_WE_N,
    output  wire                    HPS_ENET_GTX_CLK,
    inout   wire                    HPS_ENET_INT_N,
    output  wire                    HPS_ENET_MDC,
    inout   wire                    HPS_ENET_MDIO,
    input   wire                    HPS_ENET_RX_CLK,
    input   wire    [  3 : 0 ]      HPS_ENET_RX_DATA,
    input   wire                    HPS_ENET_RX_DV,
    output  wire    [  3 : 0 ]      HPS_ENET_TX_DATA,
    output  wire                    HPS_ENET_TX_EN,
    inout   wire                    HPS_GSENSOR_INT,
    inout   wire                    HPS_I2C0_SCLK,
    inout   wire                    HPS_I2C0_SDAT,
    inout   wire                    HPS_I2C1_SCLK,
    inout   wire                    HPS_I2C1_SDAT,
    inout   wire                    HPS_KEY,
    inout   wire                    HPS_LED,
    inout   wire                    HPS_LTC_GPIO,
    output  wire                    HPS_SD_CLK,
    inout   wire                    HPS_SD_CMD,
    inout   wire    [  3 : 0 ]      HPS_SD_DATA,
    output  wire                    HPS_SPIM_CLK,
    input   wire                    HPS_SPIM_MISO,
    output  wire                    HPS_SPIM_MOSI,
    inout   wire                    HPS_SPIM_SS,
    input   wire                    HPS_UART_RX,
    output  wire                    HPS_UART_TX,
    input   wire                    HPS_USB_CLKOUT,
    inout   wire    [  7 : 0 ]      HPS_USB_DATA,
    input   wire                    HPS_USB_DIR,
    input   wire                    HPS_USB_NXT,
    output  wire                    HPS_USB_STP
);

wire    [ 31 : 0 ]      w_ctrl_reg;
wire    [ 31 : 0 ]      w_status_reg;

wire                    w_sensor_rst, w_adc_rst;
wire                    w_clk_0,w_clk_1;

reg     [  3 : 0 ]      r_sw = 4'd0;
reg     [  1 : 0 ]      r_test_mode [ 2 : 0 ];

wire    [ 11 : 0 ]      w_adc_din  [ 2 : 0 ];

wire    [ 11 : 0 ]      w_adc_data [ 2 : 0 ];

wire    [  1 : 0 ]      w_cis_mode;
wire    [ 23 : 0 ]      w_cis_lines_delay;
wire    [ 15 : 0 ]      w_pulses_cnt_div;


wire    [  2 : 0 ]      w_lrgb;
wire                    w_si;
wire                    w_si_toggle;
wire    [  1 : 0 ]      w_si_cnt;

wire    [ 31 : 0 ]      w_pixels    [ 2 : 0 ];
wire    [  2 : 0 ]      w_pixels_dv, w_pixels_fifo_ovr, w_pixels_afull;
wire                    w_fifo_pix_ovr;

/////////////////////////////////////
//HPS signals
wire                    w_bus_clk;
wire    [ 31 : 0 ]      dma_irq;
wire                    w_dma_on;
reg                     r_dma_on = 1'b0;
wire    [ 27 : 0 ]      w_dma_start_address;
wire    [ 27 : 0 ]      w_dma_buf_size;
reg     [ 27 : 0 ]      r_dma_buf_size;
wire                    w_sensor_reset;
wire                    w_linux_reset;
wire    [ 31 : 0 ]      w_r_clk_on_off, w_g_clk_on_off, w_b_clk_on_off;
wire    [  2 : 0 ]      w_dma_cmd_fifo_empty, w_dma_cmd_fifo_aempty;
wire    [ 15 : 0 ]      w_dma_done_cnt  [ 2 : 0 ];
wire    [ 31 : 0 ]      w_timer;
wire    [ 31 : 0 ]      w_pulses_cnt;



wire    [127 : 0 ]      sdram0_writedata;
wire    [ 27 : 0 ]      sdram0_address;
wire                    sdram0_write;
wire                    sdram0_waitrequest;  

wire    [  7 : 0 ]      sdram0_burstcount;
wire    [127 : 0 ]      sdram0_readdata;
wire                    sdram0_readdatavalid;
wire                    sdram0_read;
wire    [ 15 : 0 ]      sdram0_byteenable;

(*preserve*) reg     [ 127: 0 ]      r_dbg_sdram0_writedata;
(*preserve*) reg     [ 27 : 0 ]      r_dbg_sdram0_address;
(*preserve*) reg                     r_dbg_sdram0_write;
(*preserve*) reg                     r_dbg_sdram0_waitrequest;
///////////////////////////////////////////

reg     [ 27 : 0 ]      r_dma_start_adr     [ 2 : 0 ];

wire    [127 : 0 ]      w_dma_data          [ 2 : 0 ];
wire    [ 27 : 0 ]      w_dma_adr           [ 2 : 0 ];
wire    [  2 : 0 ]      w_dma_wr, w_dma_waitreq;



(*preserve*) reg                     r_fifo_ovr;

(*preserve*) reg     [127 : 0 ]      r_dbg_fifo_data;
(*preserve*) reg                     r_dbg_read_req;
(*preserve*) reg                     r_dbg_read_empty;

genvar                  g;

wire                    w_global_dbg;

wire    [  2 : 0 ]      w_encoder;
wire                    w_encoder_pulse;
wire    [  1 : 0 ]      w_encoder_pulse_dir;

initial
begin
    r_test_mode[0] = 2'd0;
    r_test_mode[1] = 2'd0;
    r_test_mode[2] = 2'd0;
end

reg_sync
#(
    .INIT                   ( 1'b1              )
)           
reg_sync_cis_rst            
(           
    .CLK                    ( w_clk_0           ),      //in
    .DIN                    ( w_sensor_reset    ),      //in
    .DOUT                   ( w_sensor_rst      )       //out
);


ibuf_lvds   ibuf_lvds_encoder
(
    .datain                 ( ENC_P             ),
    .datain_b               ( ENC_N             ),
    .dataout                ( w_encoder         )
);

encoder_controller encoder_controller
(
    .CLK                    ( w_clk_0           ),
    .RST                    ( w_sensor_rst      ),

    .PULSES_CNT_DIV         ( w_pulses_cnt_div  ),      //limit for pulses counter. It's decimation factor for pulses
            
    .SIG_A                  ( w_encoder[1]      ),
    .SIG_B                  ( w_encoder[0]      ),

    .PULSE_DIR              ( w_encoder_pulse_dir ),    //out, u[2] - pulse direction: [0] bit - clockwise, [1] bit - counterclockwise
            
    .PULSE                  ( w_encoder_pulse   )
);


cis_controller cis_controller
(
    .CLK                    ( w_clk_0           ),
    .RST                    ( w_sensor_rst      ),

    .MODE                   ( w_cis_mode        ),
    .RGB_LINES_DELAY        ( w_cis_lines_delay ),
    .EXTERNAL_START         ( w_encoder_pulse   ),
    .EXTERNAL_START_LCNT    (                   ),

    .R_ON_CNT               ( w_r_clk_on_off    ),               
    .G_ON_CNT               ( w_g_clk_on_off    ),
    .B_ON_CNT               ( w_b_clk_on_off    ),

    .SI_TOGGLE              ( w_si_toggle       ),
    .SI_CNT                 ( w_si_cnt          ),
    .SI                     ( w_si              ),
    .LRGB                   ( w_lrgb            )
);

reg_sync
#(
    .INIT                   ( 1'b1              )
)           
reg_sync_adc_rst            
(           
    .CLK                    ( w_clk_1           ),      //in
    .DIN                    ( w_sensor_reset    ),      //in
    .DOUT                   ( w_adc_rst         )       //out
);

 


always @(posedge w_clk_1)
if(w_adc_rst == 1'b1)
    r_fifo_ovr <= 1'b0;
else
begin
    if( |w_pixels_fifo_ovr == 1'b1)
    //if( w_pixels_fifo_ovr[0] == 1'b1)
        r_fifo_ovr <= 1'b1;
end

reg_sync
#(
    .INIT                   ( 1'b0              )
)           
reg_sync_fifo_pix_ovr
(           
    .CLK                    ( w_bus_clk         ),      //in
    .DIN                    ( r_fifo_ovr        ),      //in
    .DOUT                   ( w_fifo_pix_ovr    )       //out
);


always @(posedge w_clk_1)
begin
    r_sw <= SW;

    case(r_sw[3:2])
        2'b00 :     r_test_mode[0] <= r_sw[1:0];
        2'b01 :     r_test_mode[1] <= r_sw[1:0];
        2'b10 :     r_test_mode[2] <= r_sw[1:0];
        default:    begin
                        r_test_mode[0] <= r_test_mode[0];
                        r_test_mode[1] <= r_test_mode[1];
                        r_test_mode[2] <= r_test_mode[2];
                    end
    endcase
end

always @(posedge w_bus_clk)
begin
    r_dma_start_adr[0]  <= w_dma_start_address;
    r_dma_start_adr[1]  <= w_dma_start_address +  w_dma_buf_size;
    r_dma_start_adr[2]  <= w_dma_start_address + {w_dma_buf_size,1'b0};

    r_dma_buf_size      <= w_dma_buf_size;

    r_dma_on            <= w_dma_on;
end

assign w_adc_din[0] = DC_0;
assign w_adc_din[1] = DC_1;
assign w_adc_din[2] = DC_2;

generate 
for (g = 0; g < 3; g = g + 1)
begin: gloop_datapath

    adc12010 adc12010
    (
        .ADC_CLK                        ( w_clk_1                   ),
        .ADC_DATA                       ( w_adc_din         [g]     ),
        .DOUT                           ( w_adc_data        [g]     )
    );

    adc_data_wrapper adc_data_wrapper
    (
        .ADC_CLK                        ( w_clk_1                   ),
        .ARST                           ( w_adc_rst                 ),
        .ADC_DIN                        ( w_adc_data        [g]     ),
                    
        //.MUX_TEST_CNT                   ( SW[1:0]                   ),
        .MUX_TEST_CNT                   ( r_test_mode       [g]     ),
                        
        .COLOR_TOGGLE_ASYNC             ( w_si_toggle               ),
        .COLOR_CNT_ASYNC                ( w_si_cnt                  ),
            
        .DOUT                           ( w_pixels          [g]     ),
        .DOUT_DV                        ( w_pixels_dv       [g]     ),
        .FIFO_OVRF                      ( w_pixels_fifo_ovr [g]     ),
        .AFULL                          ( w_pixels_afull    [g]     )

    );

    dma_fifo_wrapper
    #(
        `ifdef SIM
        .SIM                            ( 1                         )
        `else   
        .SIM                            ( 0                         )
        `endif
    )
    dma_fifo_wrapper
    (
        .FIFO_CLK                       ( w_clk_1                   ),     // in   , u[1],
        .FIFO_DIN                       ( w_pixels              [g] ),     // in   , u[32],
        .FIFO_DIN_DV                    ( w_pixels_dv           [g] ),     // in   , u[1],
        .AFULL                          ( w_pixels_afull        [g] ),     // out  , u[1],
            
        .DMA_CLK                        ( w_bus_clk                 ),     // in   , u[1],
        .SRST                           ( w_linux_reset             ),     // in   , u[1],
        .START_ADR                      ( r_dma_start_adr       [g] ),     // in   , u[28],     in 16-bytes words
        .BUF_SIZE                       ( r_dma_buf_size            ),     // in   , u[28],     in 16-bytes words
        .START                          ( r_dma_on                  ),     // in   , u[1],
        .DONE_CNT                       ( w_dma_done_cnt        [g] ),     // out  , u[16],
        .CMD_FIFO_EMPTY                 ( w_dma_cmd_fifo_empty  [g] ),     // out  , u[1],
        .CMD_FIFO_AEMPTY                ( w_dma_cmd_fifo_aempty [g] ),     // out  , u[1],
            
        .SDRAM_WRITEDATA                ( w_dma_data            [g] ),     // out  , u[128],
        .SDRAM_ADDRESS                  ( w_dma_adr             [g] ),     // out  , u[28],
        .SDRAM_WRITE                    ( w_dma_wr              [g] ),     // out  , u[1],
        .SDRAM_WAITREQUEST              ( w_dma_waitreq         [g] )      // in   , u[1],
    );
end
endgenerate

dma_mux dma_mux
(
    .CLK                            ( w_bus_clk                 ),     // in   , u[1],
    .RST                            ( w_linux_reset             ),     // in   , u[1],
    
    .DMA_0_DATA                     ( w_dma_data    [0]         ),     // in   , u[128],
    .DMA_0_ADR                      ( w_dma_adr     [0]         ),     // in   , u[28],
    .DMA_0_WR                       ( w_dma_wr      [0]         ),     // in   , u[1],
    .DMA_0_WAITREQ                  ( w_dma_waitreq [0]         ),     // out  , u[1],
    .DMA_1_DATA                     ( w_dma_data    [1]         ),     // in   , u[128],
    .DMA_1_ADR                      ( w_dma_adr     [1]         ),     // in   , u[28],
    .DMA_1_WR                       ( w_dma_wr      [1]         ),     // in   , u[1],
    .DMA_1_WAITREQ                  ( w_dma_waitreq [1]         ),     // out  , u[1],
    .DMA_2_DATA                     ( w_dma_data    [2]         ),     // in   , u[128],
    .DMA_2_ADR                      ( w_dma_adr     [2]         ),     // in   , u[28],
    .DMA_2_WR                       ( w_dma_wr      [2]         ),     // in   , u[1],
    .DMA_2_WAITREQ                  ( w_dma_waitreq [2]         ),     // out  , u[1],
    
    .SDRAM_WRITEDATA                ( sdram0_writedata          ),     // out  , u[128],
    .SDRAM_ADDRESS                  ( sdram0_address            ),     // out  , u[28],
    .SDRAM_WRITE                    ( sdram0_write              ),     // out  , u[1],
    .SDRAM_WAITREQUEST              ( sdram0_waitrequest        )      // in   , u[1],
);




assign w_linux_reset        = w_ctrl_reg[0];
assign w_sensor_reset       = w_ctrl_reg[1];
assign w_dma_on             = w_ctrl_reg[2];
    
assign w_cis_mode           = w_ctrl_reg[5:4];
    
assign w_status_reg [0]     = w_fifo_pix_ovr;
assign w_status_reg [1]     = w_dma_cmd_fifo_empty[0];
assign w_status_reg [2]     = w_dma_cmd_fifo_aempty[0];
assign w_status_reg [31:3]  = 29'd0;




`ifdef SIM
hps_sim hps_sim
(
    .CLK_50                                     ( FPGA_CLK1_50              ),     // in   , u[1],
            
    .BUS_CLK_CLK                                ( w_bus_clk                 ),     // out  , u[1],
    .OUTCLK_0_CLK                               ( w_clk_0                   ),     // out  , u[1],
    .OUTCLK_1_CLK                               ( w_clk_1                   ),     // out  , u[1],
            
    .LED_CLK_ON_RED_EXPORT                      ( w_r_clk_on_off            ),     // out  , u[32],
    .LED_CLK_ON_GREEN_EXPORT                    ( w_g_clk_on_off            ),     // out  , u[32],
    .LED_CLK_ON_BLUE_EXPORT                     ( w_b_clk_on_off            ),     // out  , u[32],
    .LINES_DELAY_EXPORT                         ( w_cis_lines_delay         ),     // out  , u[32],
    .LINES_CNT_ENCODER_EXPORT                   ( w_pulses_cnt_div          ),     // out  , u[32],
                
    .TIMER_CNT_EXPORT                           ( w_timer                   ),     // in   , u[32],
                    
    .CTRL_REG_OUT_PORT                          ( w_ctrl_reg                ),     // out  , u[32],
    .CTRL_REG_IN_PORT                           ( w_ctrl_reg                ),     // in   , u[32],
                    
    .STATUS_REG_EXPORT                          ( w_status_reg              ),     // in   , u[32],
                    
    .DMA_BUF_SIZE_EXPORT                        ( w_dma_buf_size            ),     // out  , u[32],
    .DMA_ADR_EXPORT                             ( w_dma_start_address       ),     // out  , u[32],
    .DMA_STATUS_EXPORT                          ( {16'd0,w_dma_done_cnt[0]} ),     // in   , u[32],
            
    .SDRAM0_WRITEDATA                           ( sdram0_writedata          ),     // in   , u[128],
    .SDRAM0_ADDRESS                             ( sdram0_address            ),     // in   , u[28],
    .SDRAM0_WRITE                               ( sdram0_write              ),     // in   , u[1],
    .SDRAM0_WAITREQUEST                         ( sdram0_waitrequest        )      // out  , u[1],
);

`else

soc u0 
(
    .hps_io_hps_io_emac1_inst_TX_CLK            ( HPS_ENET_GTX_CLK          ),              //                           hps_io.hps_io_emac1_inst_TX_CLK
	.hps_io_hps_io_emac1_inst_TXD0              ( HPS_ENET_TX_DATA[0]       ),          //                                 .hps_io_emac1_inst_TXD0
	.hps_io_hps_io_emac1_inst_TXD1              ( HPS_ENET_TX_DATA[1]       ),          //                                 .hps_io_emac1_inst_TXD1
	.hps_io_hps_io_emac1_inst_TXD2              ( HPS_ENET_TX_DATA[2]       ),          //                                 .hps_io_emac1_inst_TXD2
	.hps_io_hps_io_emac1_inst_TXD3              ( HPS_ENET_TX_DATA[3]       ),          //                                 .hps_io_emac1_inst_TXD3
	.hps_io_hps_io_emac1_inst_RXD0              ( HPS_ENET_RX_DATA[0]       ),          //                                 .hps_io_emac1_inst_RXD0
	.hps_io_hps_io_emac1_inst_MDIO              ( HPS_ENET_MDIO             ),                //                                 .hps_io_emac1_inst_MDIO
	.hps_io_hps_io_emac1_inst_MDC               ( HPS_ENET_MDC              ),                //                                 .hps_io_emac1_inst_MDC
	.hps_io_hps_io_emac1_inst_RX_CTL            ( HPS_ENET_RX_DV            ),                //                                 .hps_io_emac1_inst_RX_CTL
	.hps_io_hps_io_emac1_inst_TX_CTL            ( HPS_ENET_TX_EN            ),                //                                 .hps_io_emac1_inst_TX_CTL
	.hps_io_hps_io_emac1_inst_RX_CLK            ( HPS_ENET_RX_CLK           ),               //                                 .hps_io_emac1_inst_RX_CLK
	.hps_io_hps_io_emac1_inst_RXD1              ( HPS_ENET_RX_DATA[1]       ),          //                                 .hps_io_emac1_inst_RXD1
	.hps_io_hps_io_emac1_inst_RXD2              ( HPS_ENET_RX_DATA[2]       ),          //                                 .hps_io_emac1_inst_RXD2
	.hps_io_hps_io_emac1_inst_RXD3              ( HPS_ENET_RX_DATA[3]       ),          //                                 .hps_io_emac1_inst_RXD3

	.hps_io_hps_io_sdio_inst_CMD                ( HPS_SD_CMD                ),                    //                                 .hps_io_sdio_inst_CMD
	.hps_io_hps_io_sdio_inst_D0                 ( HPS_SD_DATA[0]            ),               //                                 .hps_io_sdio_inst_D0
	.hps_io_hps_io_sdio_inst_D1                 ( HPS_SD_DATA[1]            ),               //                                 .hps_io_sdio_inst_D1
	.hps_io_hps_io_sdio_inst_CLK                ( HPS_SD_CLK                ),                     //                                 .hps_io_sdio_inst_CLK
	.hps_io_hps_io_sdio_inst_D2                 ( HPS_SD_DATA[2]            ),               //                                 .hps_io_sdio_inst_D2
	.hps_io_hps_io_sdio_inst_D3                 ( HPS_SD_DATA[3]            ),               //                                 .hps_io_sdio_inst_D3
     
	.hps_io_hps_io_usb1_inst_D0                 ( HPS_USB_DATA[0]           ),               //                                 .hps_io_usb1_inst_D0
	.hps_io_hps_io_usb1_inst_D1                 ( HPS_USB_DATA[1]           ),               //                                 .hps_io_usb1_inst_D1
	.hps_io_hps_io_usb1_inst_D2                 ( HPS_USB_DATA[2]           ),               //                                 .hps_io_usb1_inst_D2
	.hps_io_hps_io_usb1_inst_D3                 ( HPS_USB_DATA[3]           ),               //                                 .hps_io_usb1_inst_D3
	.hps_io_hps_io_usb1_inst_D4                 ( HPS_USB_DATA[4]           ),               //                                 .hps_io_usb1_inst_D4
	.hps_io_hps_io_usb1_inst_D5                 ( HPS_USB_DATA[5]           ),               //                                 .hps_io_usb1_inst_D5
	.hps_io_hps_io_usb1_inst_D6                 ( HPS_USB_DATA[6]           ),               //                                 .hps_io_usb1_inst_D6
	.hps_io_hps_io_usb1_inst_D7                 ( HPS_USB_DATA[7]           ),               //                                 .hps_io_usb1_inst_D7
	.hps_io_hps_io_usb1_inst_CLK                ( HPS_USB_CLKOUT            ),                //                                 .hps_io_usb1_inst_CLK
	.hps_io_hps_io_usb1_inst_STP                ( HPS_USB_STP               ),                   //                                 .hps_io_usb1_inst_STP
	.hps_io_hps_io_usb1_inst_DIR                ( HPS_USB_DIR               ),                   //                                 .hps_io_usb1_inst_DIR
	.hps_io_hps_io_usb1_inst_NXT                ( HPS_USB_NXT               ),                   //                                 .hps_io_usb1_inst_NXT
	     
    .hps_io_hps_io_spim1_inst_CLK               ( HPS_SPIM_CLK              ),             //                                 .hps_io_spim1_inst_CLK
	.hps_io_hps_io_spim1_inst_MOSI              ( HPS_SPIM_MOSI             ),             //                                 .hps_io_spim1_inst_MOSI
	.hps_io_hps_io_spim1_inst_MISO              ( HPS_SPIM_MISO             ),             //                                 .hps_io_spim1_inst_MISO
	.hps_io_hps_io_spim1_inst_SS0               ( HPS_SPIM_SS               ),             //                                 .hps_io_spim1_inst_SS0
	     
    .hps_io_hps_io_uart0_inst_RX                ( HPS_UART_RX               ),               //                                 .hps_io_uart0_inst_RX
	.hps_io_hps_io_uart0_inst_TX                ( HPS_UART_TX               ),               //                                 .hps_io_uart0_inst_TX
     
	.hps_io_hps_io_i2c0_inst_SDA                ( HPS_I2C0_SDAT             ),               //                                 .hps_io_i2c0_inst_SDA
	.hps_io_hps_io_i2c0_inst_SCL                ( HPS_I2C0_SCLK             ),               //                                 .hps_io_i2c0_inst_SCL
     
	.hps_io_hps_io_i2c1_inst_SDA                ( HPS_I2C1_SDAT             ),               //                                 .hps_io_i2c1_inst_SDA
	.hps_io_hps_io_i2c1_inst_SCL                ( HPS_I2C1_SCLK             ),               //                                 .hps_io_i2c1_inst_SCL
     
    .hps_io_hps_io_gpio_inst_GPIO09             ( HPS_CONV_USB_N            ),            //                                 .hps_io_gpio_inst_GPIO09
    .hps_io_hps_io_gpio_inst_GPIO35             ( HPS_ENET_INT_N            ),            //                                 .hps_io_gpio_inst_GPIO35
    .hps_io_hps_io_gpio_inst_GPIO40             ( HPS_LTC_GPIO              ),            //                                 .hps_io_gpio_inst_GPIO40
    .hps_io_hps_io_gpio_inst_GPIO53             ( HPS_LED                   ),  //             //                                 .hps_io_gpio_inst_GPIO53
    .hps_io_hps_io_gpio_inst_GPIO54             ( HPS_KEY                   ),  //             //                                 .hps_io_gpio_inst_GPIO54
    .hps_io_hps_io_gpio_inst_GPIO61             ( HPS_GSENSOR_INT           ),           //                                 .hps_io_gpio_inst_GPIO61

	.memory_mem_a                               ( HPS_DDR3_ADDR             ),                           //                           memory.mem_a
	.memory_mem_ba                              ( HPS_DDR3_BA               ),                             //                                 .mem_ba
	.memory_mem_ck                              ( HPS_DDR3_CK_P             ),                           //                                 .mem_ck
	.memory_mem_ck_n                            ( HPS_DDR3_CK_N             ),                           //                                 .mem_ck_n
	.memory_mem_cke                             ( HPS_DDR3_CKE              ),                            //                                 .mem_cke
	.memory_mem_cs_n                            ( HPS_DDR3_CS_N             ),                           //                                 .mem_cs_n
	.memory_mem_ras_n                           ( HPS_DDR3_RAS_N            ),                          //                                 .mem_ras_n
	.memory_mem_cas_n                           ( HPS_DDR3_CAS_N            ),                          //                                 .mem_cas_n
	.memory_mem_we_n                            ( HPS_DDR3_WE_N             ),                           //                                 .mem_we_n
	.memory_mem_reset_n                         ( HPS_DDR3_RESET_N          ),                        //                                 .mem_reset_n
	.memory_mem_dq                              ( HPS_DDR3_DQ               ),                             //                                 .mem_dq
	.memory_mem_dqs                             ( HPS_DDR3_DQS_P            ),                          //                                 .mem_dqs
	.memory_mem_dqs_n                           ( HPS_DDR3_DQS_N            ),                          //                                 .mem_dqs_n
	.memory_mem_odt                             ( HPS_DDR3_ODT              ),                            //                                 .mem_odt
	.memory_mem_dm                              ( HPS_DDR3_DM               ),                             //                                 .mem_dm
	.memory_oct_rzqin                           ( HPS_DDR3_RZQ              ),                            //                                 .oct_rzqin

	.sdram0_address                             ( sdram0_address            ),                            //                           sdram0.address
	.sdram0_burstcount                          ( sdram0_burstcount         ),                         //                                 .burstcount
	.sdram0_waitrequest                         ( sdram0_waitrequest        ),                        //                                 .waitrequest
	.sdram0_readdata                            ( sdram0_readdata           ),                           //                                 .readdata
	.sdram0_readdatavalid                       ( sdram0_readdatavalid      ),                      //                                 .readdatavalid
	.sdram0_read                                ( sdram0_read               ),                               //                                 .read
	.sdram0_writedata                           ( sdram0_writedata          ),                          //                                 .writedata
	.sdram0_byteenable                          ( sdram0_byteenable         ),                         //                                 .byteenable
	.sdram0_write                               ( sdram0_write              ),                              //                                 .write
     
    .bus_clk_clk                                ( w_bus_clk                 ),
    .outclk_0_clk                               ( w_clk_0                   ),
    .outclk_1_clk                               ( w_clk_1                   ),
	.irq0_irq                                   ( dma_irq                   ),                                  //                             irq0.irq
	.i_pll_0_refclk_50mhz_clk                   ( FPGA_CLK1_50              ),                  //             i_pll_0_refclk_50mhz.clk
	.led_clk_on_red_export                      ( w_r_clk_on_off            ),                     //                     r_led_on_off.readdata
	.led_clk_on_green_export                    ( w_g_clk_on_off            ),                     //                     g_led_on_off.readdata
	.led_clk_on_blue_export                     ( w_b_clk_on_off            ),                     //                     b_led_on_off.readdata
    .lines_delay_export                         ( w_cis_lines_delay         ),
    .lines_cnt_encoder_export                   ( w_pulses_cnt_div          ),
	.timer_cnt_export                           ( w_timer                   ),                        //                        timer_reg.readdata
    .encoder_cnt_export                         ( w_pulses_cnt              ),

    .ctrl_reg_out_port                          ( w_ctrl_reg                ),          //out
    .ctrl_reg_in_port                           ( w_ctrl_reg                ),          //in

    .status_reg_export                          ( w_status_reg              ),          //in

    .dma_buf_size_export                        ( w_dma_buf_size            ), 
    .dma_adr_export                             ( w_dma_start_address       ),
    .dma_status_export                          ( {16'd0,w_dma_done_cnt[0]} )
);

assign sdram0_byteenable = 16'hffff;
assign sdram0_burstcount = 8'd1;

always @(posedge w_bus_clk)
begin
    //r_dbg_fifo_data          <= w_fifo_data;
    //r_dbg_read_req           <= w_fifo_rd_ack;
    //r_dbg_read_empty         <= w_fifo_empty;

    r_dbg_sdram0_writedata   <= sdram0_writedata;  
    r_dbg_sdram0_address     <= sdram0_address;    
    r_dbg_sdram0_write       <= sdram0_write;      
    r_dbg_sdram0_waitrequest <= sdram0_waitrequest;
end

assign w_global_dbg = ^r_dbg_fifo_data | r_dbg_read_req | r_dbg_read_empty | ^r_dbg_sdram0_writedata | ^r_dbg_sdram0_address | r_dbg_sdram0_write | r_dbg_sdram0_waitrequest;



altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_clkc_0 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( CLKC_0    )
);

altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_clkc_1 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( CLKC_1    )
);

altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_clkc_2 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( CLKC_2    )
);


altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_sclkc_0 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( SCLKC_0   )
);

altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_sclkc_1 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( SCLKC_1   )
);

altddio_out 
#(
    .width                  (1),
    .intended_device_family ("Cyclone V")
) 
ddio_out_sclkc_2 
(
    .datain_h   ( 1'b1      ),
    .datain_l   ( 1'b0      ),
    .outclock   ( w_clk_0   ),
    .oe         ( 1'b1      ),
    .outclocken ( 1'b1      ),
    
    .aset       ( 1'b0      ),
    .aclr       ( 1'b0      ),
    
    .sset       ( 1'b0      ),
    .sclr       ( 1'b0      ),
    
    .oe_out     (           ),
    .dataout    ( SCLKC_2   )
);

`endif



timer 
#(
        .CLK_CNT                                ( 32'd40000000 )
)
timer
(
    .clk                                        ( w_bus_clk     ),
    .reset                                      ( w_linux_reset ),
    .led                                        ( LED[7]        ),
    .tim                                        ( w_timer       )
);


encoder_cnt_debug encoder_cnt_debug
(
    .CLK                                        ( w_bus_clk             ),
    .RST                                        ( w_linux_reset         ),
    .ENC_PULSES_DIR                             ( w_encoder_pulse_dir   ),
    .CNT                                        ( w_pulses_cnt          )
);


`ifdef SIM
assign CLKC_0  = w_clk_0;
assign CLKC_1  = w_clk_0;
assign CLKC_2  = w_clk_0;
assign SCLKC_0 = w_clk_0;
assign SCLKC_1 = w_clk_0;
assign SCLKC_2 = w_clk_0;
`endif

assign LRGB_0 = w_lrgb;
assign LRGB_1 = w_lrgb;
assign LRGB_2 = w_lrgb;
assign SIC_0  = w_si;
assign SIC_1  = w_si;
assign SIC_2  = w_si;

assign LED[6] = r_fifo_ovr;
assign LED[5] = 1'b0;
assign LED[4] = 1'b0;
assign LED[3] = 1'b0;
assign LED[2] = 1'b0;
assign LED[1] = 1'b0;

assign LED[0] = w_global_dbg;

endmodule