module r_change_on_off
(
    input  logic        clk,                // clock.clk
    input  logic        reset,              // reset.reset
    
    // Memory mapped read/write slave interface
    input  logic        avs_s0_address,     // avs_s0.address
    input  logic        avs_s0_read,        // avs_s0.read
    input  logic        avs_s0_write,       // avs_s0.write
    output logic [31:0] avs_s0_readdata,    // avs_s0.readdata
    input  logic [31:0] avs_s0_writedata,   // avs_s0.writedata
    
    // The LED outputs
    // output logic [7:0]  leds
    output logic   [25:0]     r_change_on_off
);
// Read operations performed on the Avalon-MM Slave interface
always_comb begin
    if (avs_s0_read) begin
        case (avs_s0_address)
            1'b0    : avs_s0_readdata = {6'b0, r_change_on_off};
            default : avs_s0_readdata = 'x;
        endcase
    end else begin
        avs_s0_readdata = 'x;
    end
end
// Write operations performed on the Avalon-MM Slave interface
always_ff @ (posedge clk) begin
    if (reset) begin
        r_change_on_off <= '0;
    end else if (avs_s0_write) begin
        case (avs_s0_address)
            1'b0    : r_change_on_off <= avs_s0_writedata;
            default : r_change_on_off <= r_change_on_off;
        endcase
    end
end
endmodule // custom_leds