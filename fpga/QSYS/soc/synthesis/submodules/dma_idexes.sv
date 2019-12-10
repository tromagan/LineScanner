module dma_indexes
(
    input  logic        clk,                // clock.clk
    input  logic        reset,              // reset.reset
    
    // Memory mapped read/write slave interface
    input  logic        avs_s0_address,     // avs_s0.address
    input  logic        avs_s0_read,        // avs_s0.read
    // input  logic        avs_s0_write,       // avs_s0.write
    output logic [31:0] avs_s0_readdata,    // avs_s0.readdata
    // input  logic [31:0] avs_s0_writedata,   // avs_s0.writedata
    
    // The LED outputs
    // output logic [7:0]  leds
    // output logic    [28:0]    dma_indexes
    input logic    [28:0]    dma_indexes
);
// Read operations performed on the Avalon-MM Slave interface
always_comb begin
    if (avs_s0_read) begin
        case (avs_s0_address)
            1'b0    : avs_s0_readdata = {3'b0, dma_indexes};
            default : avs_s0_readdata = 'x;
        endcase
    end else begin
        avs_s0_readdata = 'x;
    end
end
// Write operations performed on the Avalon-MM Slave interface
// always_ff @ (posedge clk) begin
//     if (reset) begin
//         dma_indexes <= '0;
//     end else if (avs_s0_write) begin
//         case (avs_s0_address)
//             1'b0    : dma_indexes <= avs_s0_writedata;
//             default : dma_indexes <= dma_indexes;
//         endcase
//     end
// end
endmodule // custom_leds