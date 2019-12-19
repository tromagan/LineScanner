`timescale 1ns/1ps

module cis_controller
(
    input   wire                CLK,
    input   wire                RST,

    input   wire    [ 1 : 0 ]   MODE,
    input   wire    [23 : 0 ]   RGB_LINES_DELAY,
    input   wire                EXTERNAL_START,
    input   wire    [15 : 0 ]   EXTERNAL_START_LCNT,

    input   wire    [31 : 0 ]   R_ON_CNT,
    input   wire    [31 : 0 ]   G_ON_CNT,
    input   wire    [31 : 0 ]   B_ON_CNT,

    output  wire                SI_TOGGLE,
    output  wire    [ 1 : 0 ]   SI_CNT,

    output  wire                SI,
    output  wire    [ 2 : 0 ]   LRGB
);

localparam      CNT_WIDTH               = 24;
localparam      LINE_TIME_MIN           = 24'd2688;         //336 us (336/0.125)
localparam      LEDS_CNT                = 24'd2592;         //led sensors count
localparam      CNT_STATE_LEDS_ON       = 24'd60;

reg     [ 23 : 0 ]      r_rgb_lines_delay_cnt = 0;  //counter for delay between RGB lines:   R,G,B -----delay----- R,G,B -----delay----- ...

reg     [ CNT_WIDTH-1 : 0 ]      r_clk_cnt = 0;

reg                     r_lrgb_start = 1'b0, r_lrgb_end = 1'b0;

reg                     r_ext_start = 1'b0, r_ext_start_rise = 1'b0;
reg                     r_ext_start_in_progress = 1'b0;
reg     [ 15 : 0 ]      r_external_start_lines_cnt = 16'd0, r_ext_start_lines_cnt = 16'd0;

reg                     r_si = 1'b0;
reg                     r_si_toggle_en = 1'b0,r_si_toggle = 1'b0;
reg     [  1 : 0 ]      r_si_cnt = 2'd0;
reg     [  2 : 0 ]      r_lrgb = 3'b100;

reg                     r_rgb_line_done = 1'b0, r_rgb_line_done_d = 1'b0;
wire                    w_rgb_line_done_rise;
reg     [  1 : 0 ]      r_mode = 2'd0;

always @(posedge CLK)
begin
    if(RGB_LINES_DELAY < LINE_TIME_MIN)
        r_rgb_lines_delay_cnt <= LINE_TIME_MIN;
    else
        r_rgb_lines_delay_cnt <= RGB_LINES_DELAY;

    if(EXTERNAL_START_LCNT == 0)
        r_external_start_lines_cnt <= 16'd1;
    else
        r_external_start_lines_cnt <= EXTERNAL_START_LCNT;

    r_mode <= MODE;

    r_ext_start <= EXTERNAL_START;
    r_ext_start_rise <= EXTERNAL_START & ~r_ext_start;
end


always @(posedge CLK)
if(RST == 1'b1)
begin
    r_clk_cnt <= {CNT_WIDTH{1'b1}};     // all 1'b1 - to prevent r_si setup to 1
    r_ext_start_lines_cnt <= 16'd0;
    r_ext_start_in_progress <= 1'b0;
end
else
begin
    if(r_mode == 2'd0)     //Continuous mode: starts from internal generator without delays
    begin
        if(r_clk_cnt == LINE_TIME_MIN-1)
            r_clk_cnt <= {CNT_WIDTH{1'b0}};
        else
            r_clk_cnt <= r_clk_cnt + 1'b1;
    end
    else
        if(r_mode == 2'd1)  //Burst mode: starts from internal generator with RGB_LINES_DELAY delay (minimum LINE_TIME_MIN)
        begin
            if( ((r_rgb_line_done == 1'b1) && (r_clk_cnt == (LINE_TIME_MIN-1 + r_rgb_lines_delay_cnt))) || ((r_rgb_line_done == 1'b0) && (r_clk_cnt == LINE_TIME_MIN-1)) )
                r_clk_cnt <= {CNT_WIDTH{1'b0}};
            else
                r_clk_cnt <= r_clk_cnt + 1'b1;
        end
        else
            if(r_mode == 2'd2)  //Event mode: starts from external source. 
            begin
                if((r_ext_start_rise == 1'b1) && (r_ext_start_in_progress == 1'b0))
                begin
                    r_ext_start_in_progress <= 1'b1;
                end
                    if( ((r_rgb_line_done == 1'b1) && (r_clk_cnt == (LINE_TIME_MIN-1 + LINE_TIME_MIN-1))) && (r_ext_start_lines_cnt == r_external_start_lines_cnt) )
                        r_ext_start_in_progress <= 1'b0;

                if(r_ext_start_in_progress == 1'b1)
                begin
                    if( ((r_rgb_line_done == 1'b1) && (r_clk_cnt == (LINE_TIME_MIN-1 + LINE_TIME_MIN))) || ((r_rgb_line_done == 1'b0) && (r_clk_cnt == LINE_TIME_MIN-1)) )
                        r_clk_cnt <= {CNT_WIDTH{1'b0}};
                    else
                        r_clk_cnt <= r_clk_cnt + 1'b1;


                    if(w_rgb_line_done_rise == 1'b1)
                        r_ext_start_lines_cnt <= r_ext_start_lines_cnt + 1'b1;
                end
                else
                begin
                    r_clk_cnt <= {CNT_WIDTH{1'b1}};
                    r_ext_start_lines_cnt <= 16'd0;
                end
            end
end

always @(posedge CLK)
if(RST == 1'b1)
begin
    r_si_toggle_en  <= 1'b0;
    r_si_toggle     <= 1'b0;
    r_si_cnt        <= 2'd2;        //first color will be RED = 0
end
else
begin
    if(r_clk_cnt == LINE_TIME_MIN-1)
        r_si_toggle_en <= 1'b1;
    else
        r_si_toggle_en <= 1'b0;

    if(r_si_toggle_en == 1'b1)
        r_si_toggle <= ~r_si_toggle;

    if(r_si_toggle_en == 1'b1)
    begin
        if(r_si_cnt == 2'd2)
            r_si_cnt <= 2'd0;
        else
            r_si_cnt <= r_si_cnt + 1'b1; 
    end
end

always @(posedge CLK)
if(RST == 1'b1)
begin
    r_lrgb <= 3'b100;
    r_rgb_line_done <= 1'b0;
end
else
begin
    if(r_clk_cnt == 24'd0)
        r_si <= 1'b1;
    else
        if(r_clk_cnt == 24'd4)
            r_si <= 1'b0;
        else
            if((|r_mode == 1'b1) && (r_rgb_line_done == 1'b1) && (r_clk_cnt == LINE_TIME_MIN))   //fake start
                r_si <= 1'b1;
            else
                if((|r_mode == 1'b1) && (r_rgb_line_done == 1'b1) && (r_clk_cnt == LINE_TIME_MIN+3))     //fake start
                    r_si <= 1'b0;

    if(r_clk_cnt == CNT_STATE_LEDS_ON - 2)
        r_lrgb_start <= 1'b1;
    else
        r_lrgb_start <= 1'b0;

    if(r_clk_cnt == (CNT_STATE_LEDS_ON + LEDS_CNT - 2))
        r_lrgb_end <= 1'b1;
    else
        r_lrgb_end <= 1'b0;

    
    if(r_clk_cnt == 24'd2660)
        r_lrgb <= {r_lrgb[0],r_lrgb[2:1]};

    
    if(r_clk_cnt == 24'd0)
        r_rgb_line_done <= 1'b0;
    else
        if((r_clk_cnt == 24'd2660) && (r_lrgb == 3'b001))
            r_rgb_line_done <= 1'b1;

    r_rgb_line_done_d <= r_rgb_line_done;
end

leds_rgb_pwm leds_rgb_pwm
(
    .CLK            ( CLK           ),     // in   , u[1],
    .RST            ( RST           ),     // in   , u[1],
    
    .START          ( r_lrgb_start  ),     // in   , u[1],
    .END            ( r_lrgb_end    ),     // in   , u[1],
    .RGB            ( r_lrgb        ),     // in   , u[3],

    .DUTY_CYCL_R    ( R_ON_CNT      ),     // in   , u[],
    .DUTY_CYCL_G    ( G_ON_CNT      ),     // in   , u[],
    .DUTY_CYCL_B    ( B_ON_CNT      ),     // in   , u[],

    .LRGB           ( LRGB          )      // out  , u[3],
);

assign w_rgb_line_done_rise = r_rgb_line_done & ~r_rgb_line_done_d;


assign SI        = r_si;
assign SI_TOGGLE = r_si_toggle;
assign SI_CNT    = r_si_cnt;

endmodule