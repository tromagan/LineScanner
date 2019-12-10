module timer
#(
	parameter 	CLK_CNT = 32'd25000000 	//1sec for 50 MHZ
)	
(
	input		wire clk,
	input		wire reset,
	output 		wire led,
	output		wire [31:0] tim
);

// localparam r_led = 29;

reg [31:0] tim_county 	= 0;
reg [31:0] timer			= 0;
reg led_tim_sec			= 0;	

always@(posedge clk)// 8 mhz
if(reset == 1'b1) 
begin
	tim_county 	<= 0;
	timer			<= 0;
	led_tim_sec <= 0;
end 
else 
begin
	tim_county	<= tim_county + 1;
	if(tim_county == CLK_CNT-1) begin
		tim_county	<= 0;
		timer			<= timer + 1;
		led_tim_sec <= ~led_tim_sec;
	end
end

assign tim = timer;
assign led = led_tim_sec;

endmodule