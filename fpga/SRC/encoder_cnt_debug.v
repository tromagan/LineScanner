`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2020 13:58:00
// Design Name: 
// Module Name: encoder_cnt_debug
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


module encoder_cnt_debug
(
    input       wire                CLK,
    input       wire                RST,
    input       wire    [ 1 : 0 ]   ENC_PULSES_DIR,
    output      wire    [31 : 0 ]   CNT
);

reg     [ 1 : 0 ]   r_pulses_m0 = 2'd0, r_pulses_m1 = 2'd0, r_pulses = 2'd0, r_pulses_d = 2'd0;
reg                 r_pulse_inc = 1'b0, r_pulse_dec = 1'b0;
reg     [ 15 : 0 ]  r_pulses_cnt = 16'd0;


always @(posedge CLK)
begin
    r_pulses_m0 <= ENC_PULSES_DIR;
    r_pulses_m1 <= r_pulses_m0;
    r_pulses    <= r_pulses_m1;
    r_pulses_d  <= r_pulses;

    r_pulse_inc <=  r_pulses[0] & ~r_pulses_d[0];
    r_pulse_dec <=  r_pulses[1] & ~r_pulses_d[1];
end

always @(posedge CLK)
if(RST == 1'b1)
begin
    r_pulses_cnt <= 16'd0;
end
else
begin
    if(r_pulse_inc == 1'b1)
        r_pulses_cnt <= r_pulses_cnt + 1'b1;
    else
        if(r_pulse_dec == 1'b1)
            r_pulses_cnt <= r_pulses_cnt - 1'b1;
end

assign CNT = {16'd0, r_pulses_cnt};

endmodule
