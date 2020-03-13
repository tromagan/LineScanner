`timescale 1ns/1ps


module tb_top();

bit                     CLK_50;    
wire                    CLK;

wire                    w_si;
reg     [ 11 : 0 ]      r_adc_data;
wire    [ 11 : 0 ]      w_adc_data;

reg     [  2 : 0 ]      r_encoder = 3'd0;
reg                     enc_inv = 1'b0;



initial forever #(20/2)     CLK_50 = ~CLK_50;

assign w_adc_data = r_adc_data ^ 12'h800;

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
    .CLKC           ( CLK           ),
    .DC             ( w_adc_data    ),

    .LRGB           (               ),
    .SIC            ( w_si          ),
    .SCLKC          (               ),

    .ENC_P          ( r_encoder     ),
    .ENC_N          ( ~r_encoder    ),

    .SW             ( 4'b0011       ),
    //.SW             ( 4'b0001       ),

    .LED            (               )
);

//integer pps = 750;
//integer pps = 720;
integer pps = 700;
//integer pulse_period_ms = 2;
real pulse_period_ms = 1000.0/pps;
integer pulse_period = pulse_period_ms * 2000;

initial
begin
    $display("pulse_period_ms = %f",pulse_period_ms);
    forever
    begin
        //repeat(5000) @(posedge CLK);
        //repeat(pulse_period_ms * 1000 * 2) @(posedge CLK);
        repeat(pulse_period) @(posedge CLK);

        if(enc_inv == 1'b1)
            r_encoder[1] = ~r_encoder[1];
        else
            r_encoder[0] = ~r_encoder[0];

        enc_inv = ~enc_inv;
    end
end

endmodule    