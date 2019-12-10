`timescale 1ns/1ps
//`default_nettype none

/*
adc_data_wrapper adc_data_wrapper
(
    .ADC_CLK                (),
    .ARST                   (),
    .ADC_DIN                (),
    
    .COLOR_TOGGLE_ASYNC     (),
    .COLOR_CNT_ASYNC        (),

    .DOUT                   (),
    .DOUT_DV                (),
    .FULL                   ()

);
*/

module adc_data_wrapper
(
    input   wire                ADC_CLK,
    input   wire                ARST,
    input   wire    [ 11 : 0 ]  ADC_DIN,

    input   wire                COLOR_TOGGLE_ASYNC,
    input   wire    [  1 : 0 ]  COLOR_CNT_ASYNC,

    input   wire    [  1 : 0 ]  MUX_TEST_CNT,

    output  wire    [ 31 : 0 ]  DOUT,
    output  wire                DOUT_DV,
    output  wire                FIFO_OVRF,
    input   wire                AFULL

);
wire                    w_rst;
wire                    w_color_tgl;
wire    [   1 : 0 ]     w_color_cnt;

reg                     r_color_tgl = 1'b0;
wire                    w_color_edge;       //both edges and rises

localparam              CNT_LIMIT_L = 32'd87;
localparam              CNT_LIMIT_H = CNT_LIMIT_L + 32'd2592;
reg     [  31 : 0 ]     r_samples_cnt = 32'd0;

reg                     r_adc_dv = 1'b0;

//reg                     r_red_detected = 1'b0;

reg     [   2 : 0 ]     r_adc_rgb_mux = 3'd0;
(*preserve*) reg     [  11 : 0 ]     r_rgb;
(*preserve*) reg     [   2 : 0 ]     r_rgb_dv = 3'd0;

reg_sync
#(
    .INIT       ( 1'b1  )
)
reg_sync_arst
(
    .CLK        ( ADC_CLK               ),      //in
    .DIN        ( ARST                  ),      //in
    .DOUT       ( w_rst                 )       //out
);

reg_sync
#(
    .INIT       ( 1'b0  )
)
reg_sync_color_tgl
(
    .CLK        ( ADC_CLK               ),      //in
    .DIN        ( COLOR_TOGGLE_ASYNC    ),      //in
    .DOUT       ( w_color_tgl           )       //out
);

reg_sync
#(
    .INIT       ( 1'b0                  )
)
reg_sync_color_cnt_0
(
    .CLK        ( ADC_CLK               ),      //in
    .DIN        ( COLOR_CNT_ASYNC [0]   ),      //in
    .DOUT       ( w_color_cnt     [0]   )       //out
);

reg_sync
#(
    .INIT       ( 1'b0                  )
)
reg_sync_color_cnt_1
(
    .CLK        ( ADC_CLK               ),      //in
    .DIN        ( COLOR_CNT_ASYNC [1]   ),      //in
    .DOUT       ( w_color_cnt     [1]   )       //out
);


assign w_color_edge = (~r_color_tgl & w_color_tgl) | (r_color_tgl & ~w_color_tgl);


always @(posedge ADC_CLK)
    r_color_tgl <= w_color_tgl;

reg     r_en_cnt = 1'b0;

always @(posedge ADC_CLK)
if(w_rst == 1'b1)
begin
    r_en_cnt <= 1'b0;
end
else
begin
    if(w_color_edge == 1'b1)
        r_en_cnt <= 1'b1;
    else
        if(r_samples_cnt >= CNT_LIMIT_H)
            r_en_cnt <= 1'b0;

end


always @(posedge ADC_CLK)
if((w_rst == 1'b1) || (w_color_edge == 1'b1))
    r_samples_cnt <= 32'd0;
else
    //if(r_samples_cnt <= CNT_LIMIT_H)
    if(r_en_cnt == 1'b1)
        r_samples_cnt <= r_samples_cnt + 1'b1;




always @(posedge ADC_CLK)
begin
    if( (r_samples_cnt >= CNT_LIMIT_L) && (r_samples_cnt < CNT_LIMIT_H) )
        r_adc_dv <= 1'b1;
    else
        r_adc_dv <= 1'b0;


    if(w_color_edge == 1'b1)
    begin
        case(w_color_cnt)
            2'd0    :   r_adc_rgb_mux <= 3'b100;    //RED
            2'd1    :   r_adc_rgb_mux <= 3'b010;    //GREEN
            2'd2    :   r_adc_rgb_mux <= 3'b001;    //BLUE
            default :   r_adc_rgb_mux <= r_adc_rgb_mux;
        endcase
    end

    r_rgb    <= ADC_DIN;
    r_rgb_dv <= r_adc_rgb_mux & {3{r_adc_dv}};     
    //r_rgb_dv <= r_adc_rgb_mux & {3{r_adc_dv & r_red_detected}};     //start writing data from RED
end

// always @(posedge ADC_CLK)
// if(w_rst == 1'b1)
//     r_red_detected <= 1'b0;
// else
//     if((w_color_edge == 1'b1) && (w_color_cnt == 2'd0))
//         r_red_detected <= 1'b1;


pixel_buffer pixel_buffer
(
    .CLK            ( ADC_CLK       ),     // in   , u[1],
    .RST            ( w_rst         ),     // in   , u[1],
    .DIN_R          ( r_rgb         ),     // in   , u[12],
    .DIN_R_DV       ( r_rgb_dv[2]   ),     // in   , u[1],
    .DIN_G          ( r_rgb         ),     // in   , u[12],
    .DIN_G_DV       ( r_rgb_dv[1]   ),     // in   , u[1],
    .DIN_B          ( r_rgb         ),     // in   , u[12],
    .DIN_B_DV       ( r_rgb_dv[0]   ),     // in   , u[1],

    .MUX_TEST_CNT   ( MUX_TEST_CNT  ),

    .DOUT           ( DOUT          ),     // out  , u[32],
    .DOUT_DV        ( DOUT_DV       ),     // out  , u[1],
    .FIFO_OVRF      ( FIFO_OVRF     ),     // out  , u[1],
    .AFULL          ( AFULL         )      // in   , u[1],
);

endmodule