
/*
reg_sync
#(
    .INIT       ( 1'b0  )
)
reg_sync
(
    .CLK        (       ),      //in
    .DIN        (       ),      //in
    .DOUT       (       )       //out
);
*/

module reg_sync
#(
    parameter INIT = 1'b0
)
(
    input   wire    CLK,
    input   wire    DIN,
    output  wire    DOUT
);

reg     r_din_0 = INIT;
reg     r_din_1 = INIT;

always @(posedge CLK)
begin
    r_din_0 <= DIN;
    r_din_1 <= r_din_0;
end

assign DOUT = r_din_1;

endmodule