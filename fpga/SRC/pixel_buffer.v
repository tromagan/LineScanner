`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 03:22:32 PM
// Design Name: 
// Module Name: pixel_buffer
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


/*
pixel_buffer pixel_buffer
(
    .CLK                        (   ),     // in   , u[1],
    .RST                        (   ),     // in   , u[1],
    .DIN_R                      (   ),     // in   , u[12],
    .DIN_R_DV                   (   ),     // in   , u[1],
    .DIN_G                      (   ),     // in   , u[12],
    .DIN_G_DV                   (   ),     // in   , u[1],
    .DIN_B                      (   ),     // in   , u[12],
    .DIN_B_DV                   (   )      // in   , u[1],

    .DOUT                       (   ),     // out  , u[32],
    .DOUT_DV                    (   ),     // out  , u[1],
    .AFULL                      (   )      // in   , u[1],
);
*/


module pixel_buffer
(
    input   wire                CLK,
    input   wire                RST,
    
    input   wire    [ 11 : 0 ]  DIN_R,
    input   wire                DIN_R_DV,

    input   wire    [ 11 : 0 ]  DIN_G,
    input   wire                DIN_G_DV,

    input   wire    [ 11 : 0 ]  DIN_B,
    input   wire                DIN_B_DV,

    input   wire    [  1 : 0 ]  MUX_TEST_CNT,

    output  wire    [ 31 : 0 ]  DOUT,
    output  wire                DOUT_DV,
    output  wire                FIFO_OVRF,
    input   wire                AFULL
);

wire    [  2 : 0 ]  w_din_dv;

reg     [  1 : 0 ]  r_mux_data = 2'd0;

reg     [ 15 : 0 ]  r_fifo_din_mux [ 2 : 0 ];
reg     [  2 : 0 ]  r_fifo_din_mux_dv = 3'd0;

wire    [ 15 : 0 ]  w_fifo_din  [ 2 : 0 ];
wire    [  2 : 0 ]  w_fifo_din_dv;

wire    [  2 : 0 ]  w_fifo_full;
wire    [  2 : 0 ]  w_fifo_afull;
reg     [  2 : 0 ]  r_fifo_ovr = 3'd0;
reg                 r_fifo_ovr_dout = 1'b0;

wire    [ 15 : 0 ]  w_fifo_dout [ 2 : 0 ];
reg     [  2 : 0 ]  r_fifo_rd = 3'd0;
reg     [  2 : 0 ]  r_fifo_rd_d = 3'd0;
wire    [  2 : 0 ]  w_fifo_rd;
wire    [  2 : 0 ]  w_fifo_empty;
reg     [  2 : 0 ]  r_fifo_empty = 3'd0;
wire    [  2 : 0 ]  w_fifo_aempty;

reg     [ 1 : 0 ]   r_rgb_cnt = 2'd0;

reg                 r_fifo_dv = 1'b0;

reg     [ 31 : 0 ]  r_dout;
reg                 r_dout_dv = 1'b0;

genvar              g;

reg     [ 15 : 0 ]  r_rgb_test_cnt   [ 2 : 0 ];

reg     [ 15 : 0 ]  r_rgb_test_long_cnt [ 2 : 0 ];

integer             i;


assign w_din_dv = {DIN_R_DV, DIN_G_DV, DIN_B_DV};

always @(posedge CLK)
if(RST == 1'b1)
begin
    r_rgb_test_cnt[2] <= 16'd0;
    r_rgb_test_cnt[1] <= 16'd0;
    r_rgb_test_cnt[0] <= 16'd0;

    r_rgb_test_long_cnt[2] <= 16'd0; //R
    r_rgb_test_long_cnt[1] <= 16'd1; //G
    r_rgb_test_long_cnt[0] <= 16'd2; //B

    //r_rgb_test_long_cnt[2] <= 16'd0; //R
    //r_rgb_test_long_cnt[1] <= 16'd0; //G
    //r_rgb_test_long_cnt[0] <= 16'd0; //B
    
    

    r_fifo_din_mux_dv <= 3'd0;
end
else
begin
    r_mux_data <= MUX_TEST_CNT;

    for(i = 0; i < 3; i = i + 1)
    begin
        if(w_din_dv[i] == 1'b1)
            r_rgb_test_cnt[i] <= r_rgb_test_cnt[i] + 1'b1;

        if(w_din_dv[i])
            r_rgb_test_long_cnt[i] <= r_rgb_test_long_cnt[i] + 3'd3;
    end

    // if(|w_din_dv == 1'b1)
    //     {r_rgb_test_long_cnt[0],r_rgb_test_long_cnt[1],r_rgb_test_long_cnt[2]} <= {r_rgb_test_long_cnt[0],r_rgb_test_long_cnt[1],r_rgb_test_long_cnt[2]} + 3'd1;

    case(r_mux_data)
        2'd0    :   begin
                        r_fifo_din_mux[2] <= {{4{DIN_R[11]}},DIN_R};
                        r_fifo_din_mux[1] <= {{4{DIN_G[11]}},DIN_G};
                        r_fifo_din_mux[0] <= {{4{DIN_B[11]}},DIN_B};
                        
                    end
        2'd1    :   begin
                        r_fifo_din_mux[2] <= 16'hAAAA;       //R;
                        r_fifo_din_mux[1] <= 16'h5555;       //G;
                        r_fifo_din_mux[0] <= 16'hFFFF;       //B;
                    end
        2'd2    :   begin
                        r_fifo_din_mux[2] <= r_rgb_test_cnt[2];
                        r_fifo_din_mux[1] <= r_rgb_test_cnt[1];
                        r_fifo_din_mux[0] <= r_rgb_test_cnt[0];
                    end
        2'd3    :   begin
                        r_fifo_din_mux[2] <= r_rgb_test_long_cnt[2];
                        r_fifo_din_mux[1] <= r_rgb_test_long_cnt[1];
                        r_fifo_din_mux[0] <= r_rgb_test_long_cnt[0];
                    end
    endcase

    r_fifo_din_mux_dv <= w_din_dv;
end

assign w_fifo_din   [2] = r_fifo_din_mux[2];
assign w_fifo_din   [1] = r_fifo_din_mux[1];
assign w_fifo_din   [0] = r_fifo_din_mux[0];

assign w_fifo_din_dv    = r_fifo_din_mux_dv;

generate 
    for( g = 0; g < 3; g = g + 1)
    begin : gloop_pixel_fifo
        fifo_bram_sync
        #(
            .Z                          ( 0                 ),     //   Simulation delay
            .DATA_WIDTH                 ( 16                ),     //   Data width 
            .DEPTH                      ( 12                ),     //   Words count in FIFO, 2**DEPTH 
            .AFULL_OFFSET               ( 2                 ),     //   Sets almost full threshold. How many DIN_WR for FULL flag occurrence 
            .AEMPTY_OFFSET              ( 1                 )      //   Sets the almost empty threshold
        )           
        fifo_bram_pixel         
        (           
            .CLK                        ( CLK               ),     // in , u[1],
            .RST                        ( RST               ),     // in , u[1],
            
            .DIN                        ( w_fifo_din   [g]  ),     // in , u[DATA_WIDTH],
            .DIN_WR                     ( w_fifo_din_dv[g]  ),     // in , u[1],
            .DIN_FULL                   ( w_fifo_full  [g]  ),     // out, u[1],        full flag
            .DIN_AFULL                  ( w_fifo_afull [g]  ),     // out, u[1],        almost full flag
            
            .DOUT                       ( w_fifo_dout  [g]  ),     // out, u[DATA_WIDTH],
            .DOUT_RD                    ( w_fifo_rd    [g]  ),     // in , u[1],        read enable
            .DOUT_EMPTY                 ( w_fifo_empty [g]  ),     // out, u[1],        empty flag
            .DOUT_AEMPTY                ( w_fifo_aempty[g]  )      // out, u[1],        almost empty flag
        );
    end
endgenerate


//assign w_fifo_rd = r_fifo_rd & {3{~(|w_fifo_empty)}} & {3{~AFULL}};
assign w_fifo_rd = r_fifo_rd & {3{~(w_fifo_empty)}} & {3{~AFULL}};

always @(posedge CLK)
begin
    r_fifo_rd_d     <=  w_fifo_rd;
    r_fifo_dv       <= |w_fifo_rd;

    r_fifo_ovr      <= w_fifo_full & w_fifo_din_dv;
    r_fifo_ovr_dout <= |r_fifo_ovr;

    r_fifo_empty    <= w_fifo_empty;
end

always @(posedge CLK)
//if((RST == 1'b1) || (|r_fifo_empty == 1'b1))
//if((RST == 1'b1))
if((RST == 1'b1) || (|r_fifo_empty[1:0] == 1'b1))
begin
    r_rgb_cnt <= 2'd0;
    r_fifo_rd <= 3'd0;
    r_dout_dv <= 1'b0;
end
else
begin
    if(AFULL == 1'b0)
    begin
        case(r_rgb_cnt)
            2'd0    :   begin
                            //if( w_fifo_empty[2] == 1'b0 && w_fifo_empty[1] == 1'b0)     //RG
                            if( w_fifo_aempty[2] == 1'b0 && w_fifo_aempty[1] == 1'b0)     //RG
                            begin
                                r_fifo_rd <= 3'b110;
                                r_rgb_cnt <= 2'd1;
                            end
                            else
                                r_fifo_rd <= 3'b000;
                        end

            2'd1    :   begin
                            if( w_fifo_empty[2] == 1'b0 && w_fifo_empty[0] == 1'b0)     //BR
                            begin
                                r_fifo_rd <= 3'b101;
                                r_rgb_cnt <= 2'd2;
                            end
                            else
                                r_fifo_rd <= 3'b000;
                        end

            2'd2    :   begin
                            if( w_fifo_empty[1] == 1'b0 && w_fifo_empty[0] == 1'b0)     //GB
                            begin
                                r_fifo_rd <= 3'b011;
                                r_rgb_cnt <= 2'd0;
                            end
                            else
                                r_fifo_rd <= 3'b000;
                        end

            default :   begin
                            r_fifo_rd <= r_fifo_rd;
                            r_rgb_cnt <= 2'd0;
                        end
        endcase
    end


    case(r_fifo_rd_d)
        3'b110 :    r_dout <= { w_fifo_dout[2], w_fifo_dout[1]};  //RG
        3'b101 :    r_dout <= { w_fifo_dout[0], w_fifo_dout[2]};  //BR
        3'b011 :    r_dout <= { w_fifo_dout[1], w_fifo_dout[0]};  //GB
        default:    r_dout <= r_dout;
    endcase
    r_dout_dv <= r_fifo_dv;
end


/*
always @(posedge CLK)
if(RST == 1'b1)
begin
    r_test_cnt <= 32'd0;
end
else
begin
    if(r_dout_dv == 1'b1)
        r_test_cnt <= r_test_cnt + 1'b1;
end
*/

//assign DOUT = r_test_cnt;
//assign DOUT     = r_dout;
assign DOUT     = {r_dout[15:0],r_dout[31:16]};
assign DOUT_DV  = r_dout_dv;

assign FIFO_OVRF = r_fifo_ovr_dout;

endmodule
