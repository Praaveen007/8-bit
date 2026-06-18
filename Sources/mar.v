// =============================================================================
// SAP-1 Memory Address Register (MAR)
// Matches diagram signal:
//   MI = Memory In — latch lower 4 bits from bus into MAR
// Output is 4-bit address to RAM (not back to bus)
// =============================================================================
module mar (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        MI,        // Memory In — load MAR from bus
    input  wire [7:0]  bus_in,
    output reg  [3:0]  addr_out   // 4-bit address to RAM
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  addr_out <= 4'b0000;
        else if (MI) addr_out <= bus_in[3:0];
    end

endmodule
