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

    input   wire    [ 23 : 0 ]  DUTY_CYCL_R,
    input   wire    [ 23 : 0 ]  DUTY_CYCL_G,
    input   wire    [ 23 : 0 ]  DUTY_CYCL_B,

    input   wire                START,
    input   wire                END,
    input   wire    [  2 : 0 ]  RGB,

    output  wire    [  2 : 0 ]  LRGB

);

reg     [ 23 : 0 ]  r_duty_cycl_mux = 24'd0;
reg                 r_start = 1'b0, r_en = 1'b0;
wire                w_en;
reg     [ 23 : 0 ]  r_clk_cnt = 24'd0;
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

assign w_en = (START | r_en) & (~END);

always @(posedge CLK)
if(RST == 1'b1)
begin
    r_lrgb_iob <= 3'b111;
    r_clk_cnt  <= 24'd1;
end
else
begin
    if((START & ~r_start) == 1'b1)
        r_clk_cnt  <= 24'd1;
    else
        r_clk_cnt <= r_clk_cnt + 1'b1;

    if(w_en == 1'b1)
    begin
        if(r_clk_cnt <= r_duty_cycl_mux)
            r_lrgb_iob <= ~RGB;
        else
            r_lrgb_iob <= 3'b111;;
    end
    else
        r_lrgb_iob <= 3'b111;
end



assign LRGB = r_lrgb_iob;

endmodule
