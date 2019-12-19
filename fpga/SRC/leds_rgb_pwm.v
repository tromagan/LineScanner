`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2019 11:31:29 AM
// Design Name: 
// Module Name: leds_rgb_pwm
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
module leds_rgb_pwm
(
    input   wire                CLK,
    input   wire                RST,

    input   wire    [ 31 : 0 ]  DUTY_CYCL_R,
    input   wire    [ 31 : 0 ]  DUTY_CYCL_G,
    input   wire    [ 31 : 0 ]  DUTY_CYCL_B,

    input   wire                START,
    input   wire                END,
    input   wire    [  2 : 0 ]  RGB,

    output  wire    [  2 : 0 ]  LRGB

);

reg     [ 31 : 0 ]  r_duty_cycl_mux = 32'd0;
wire    [ 15 : 0 ]  w_duty_high_cnt, w_duty_low_cnt;

reg                 r_start = 1'b0, r_en = 1'b0;
wire                w_en;

reg                 r_cnt_sel = 1'b0;
reg     [ 15 : 0 ]  r_cnt_high, r_cnt_low;
reg     [  2 : 0 ]  r_lrgb_iob;

always @(posedge CLK)
begin
    r_start <= START;

    if(RST == 1'b1)
        r_en <= 1'b0;
    else
        if(START == 1'b1)
            r_en <= 1'b1;
        else
            if(END == 1'b1)
                r_en <= 1'b0;

    case(RGB)
        3'b100  :   r_duty_cycl_mux <= DUTY_CYCL_R;
        3'b010  :   r_duty_cycl_mux <= DUTY_CYCL_G;
        3'b001  :   r_duty_cycl_mux <= DUTY_CYCL_B;
        default :   r_duty_cycl_mux <= r_duty_cycl_mux;
    endcase
end

assign w_duty_high_cnt = r_duty_cycl_mux[ 15 :  0 ];
assign w_duty_low_cnt  = r_duty_cycl_mux[ 31 : 16 ];

assign w_en = (START | r_en) & (~END);

always @(posedge CLK)
if((RST == 1'b1) || (w_en == 1'b0))
begin
    r_lrgb_iob <= 3'b111;
    r_cnt_sel  <= 1'b0;
    r_cnt_high <= 16'd1;
    r_cnt_low  <= 16'd1;
end
else
begin
    if(r_cnt_sel == 1'b0 && |w_duty_high_cnt == 1'b1)   //leds ON 
    begin
        r_lrgb_iob <= ~RGB;

        if(w_duty_high_cnt > r_cnt_high)
        begin
            r_cnt_high <= r_cnt_high + 1'b1;
        end
        else
        begin
            r_cnt_high <= 16'd1;
            
            if(|w_duty_low_cnt == 1'b1)
                r_cnt_sel  <= 1'b1;
            else
                r_cnt_sel  <= 1'b0;
        end
    end
    else                    //leds OFF
    begin
        r_lrgb_iob <= 3'b111;

        if(w_duty_low_cnt > r_cnt_low)
            r_cnt_low <= r_cnt_low + 1'b1;
        else
        begin
            r_cnt_low <= 16'd1;

            if(|w_duty_high_cnt == 1'b1)
                r_cnt_sel  <= 1'b0;
            else
                r_cnt_sel  <= 1'b1;
        end
    end
end

assign LRGB = r_lrgb_iob;

endmodule
