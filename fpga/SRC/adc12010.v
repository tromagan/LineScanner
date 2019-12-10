/*
adc12010 adc12010
(
    .ADC_CLK    (),
    .ADC_DATA   (),

    .DOUT       (),
); 
*/

module adc12010
(
    input   wire                ADC_CLK,
    input   wire    [ 11 : 0 ]  ADC_DATA,

    output  wire    [ 11 : 0 ]  DOUT
);


reg     [ 11 : 0 ]  r_iob_adc;
reg     [ 11 : 0 ]  r_adc_data;


always @(posedge ADC_CLK)
begin
    r_iob_adc  <= ADC_DATA;
    r_adc_data <= r_iob_adc ^ 12'h800;
end

assign DOUT     = r_adc_data;

endmodule