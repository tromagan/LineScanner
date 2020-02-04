`timescale 1ns/1ps

/*
 Check impulses on SIG_A and SIG_B. And generate pulses on output PULSE and on PULSE_DIR (with direction).
 PULSES_CNT_DIV is limit for pulses counter. It's decimation factor for pulses.
 
 If PULSES_CNT_DIV == 1 -> all pulses go to out PULSE and PULSE_DIR.
 If PULSES_CNT_DIV == 2 -> every 2'nd pulse go to out
 If PULSES_CNT_DIV == 4 -> every 4'th pulse go to out
 and so on....
*/


/*
encoder_controller encoder_controller
(
    .CLK        (),
    .RST        (),

    .SIG_A      (),
    .SIG_B      (),

    .PULSE_DIR  (),

    .PULSE      ()
);
*/

module encoder_controller
(
    input   wire                    CLK,
    input   wire                    RST,

    input   wire    [15 : 0 ]       PULSES_CNT_DIV,

    input   wire                    SIG_A,
    input   wire                    SIG_B,

    output  wire    [ 1 : 0 ]       PULSE_DIR,

    output  wire                    PULSE
);

reg     [ 1 : 0 ]   r_sig_a = 2'd0, r_sig_b = 2'd0;
reg                 r_sig_a_r = 1'b0, r_sig_b_r = 1'b0;
reg     [15 : 0 ]   r_cnt = 16'd0;
wire                w_cnt_en;
wire    [ 1 : 0 ]   w_pulse;    // 0 - clockwise : first A then B (A = 1, B = 0)
                                // 1 - counterclockwise: first B then A (B = 1, A = 0)

(*preserve*) reg     [15 : 0 ]   r_cnt_div_m0 = 16'd0;
(*preserve*) reg     [15 : 0 ]   r_cnt_div_m1 = 16'd0;
(*preserve*) reg     [15 : 0 ]   r_cnt_div    = 16'd0;
reg                  [15 : 0 ]   r_cnt_div_limit = 16'd1;

reg     [ 1 : 0 ]   r_pulse = 2'd0;
reg                 r_pulse_out = 1'b0;

always @(posedge CLK)
begin
    r_sig_a[0] <= SIG_A;
    r_sig_a[1] <= r_sig_a[0];

    r_sig_b[0] <= SIG_B;
    r_sig_b[1] <= r_sig_b[0];

    r_sig_a_r  <= r_sig_a[0] & ~r_sig_a[1];
    r_sig_b_r  <= r_sig_b[0] & ~r_sig_b[1];
end

assign w_pulse[0] = r_sig_a_r & ~r_sig_b[0];
assign w_pulse[1] = r_sig_b_r & ~r_sig_a[0];

always @(posedge CLK)
begin
    r_cnt_div_m0 <= PULSES_CNT_DIV;
    r_cnt_div_m1 <= r_cnt_div_m0;
    r_cnt_div    <= r_cnt_div_m1;
    
    if(r_cnt_div == 16'd0)
        r_cnt_div_limit <= 16'd1;
    else
        r_cnt_div_limit <= r_cnt_div;    
end

always @(posedge CLK)
if(RST == 1'b1)
    r_cnt <= 16'd0;
else
begin
    if(|w_pulse == 1'b1)
    begin
        if(r_cnt == r_cnt_div_limit - 1)
            r_cnt <= 16'd0;
        else
            r_cnt <= r_cnt + 1'b1;
    end
end
assign w_cnt_en = (r_cnt == r_cnt_div_limit - 1) ? 1'b1 : 1'b0;



always @(posedge CLK)
begin
    r_pulse <= w_pulse & {2{w_cnt_en}};
    r_pulse_out <= |r_pulse;
end

assign PULSE_DIR = r_pulse;
assign PULSE = r_pulse_out;

endmodule