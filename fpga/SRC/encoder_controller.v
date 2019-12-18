`timescale 1ns/1ps

/*
encoder_controller encoder_controller
(
    .CLK        (),
    .RST        (),

    .SIG_A      (),
    .SIG_B      (),

    .PULSE      ()
);
*/

module encoder_controller
(
    input   wire                    CLK,
    input   wire                    RST,

    input   wire                    SIG_A,
    input   wire                    SIG_B,

    output  wire                    TMP,
    output  wire                    PULSE
);

reg     [ 1 : 0 ]   r_sig_a = 2'd0, r_sig_b = 2'd0;
reg                 r_sig_a_r = 1'b0, r_sig_b_r = 1'b0;
wire    [ 1 : 0 ]   w_pulse;    // 0 - clockwise : first A then B (A = 1, B = 0)
                                // 1 - counterclockwise: first B then A (B = 1, A = 0)

reg     [ 1 : 0 ]   r_pulse = 2'd0;

reg     [ 15 : 0 ]  r_pulses_cnt = 16'd0;

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
if(RST == 1'b1)
begin
    r_pulses_cnt <= 16'd0;
end
else
begin
    if(w_pulse[0] == 1'b1)
        r_pulses_cnt <= r_pulses_cnt + 1'b1;
    else
        if(w_pulse[1] == 1'b1)
            r_pulses_cnt <= r_pulses_cnt - 1'b1;
end

always @(posedge CLK)
begin
    r_pulse <= w_pulse;
    r_pulse_out <= |r_pulse;
end

assign PULSE = r_pulse_out;
assign TMP = |r_pulses_cnt;

endmodule