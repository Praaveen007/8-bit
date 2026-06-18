// -------------------------------------------------------
// Memory Address Register (MAR) for SAP-1
//
// The MAR holds the 4-bit address that tells the RAM
// which memory location to read from.
// It gets its value from the bus (lower 4 bits only).
//
// Control signal:
//   MI = Memory In : latch bus[3:0] into MAR on clock edge
//   rst = active HIGH reset
// -------------------------------------------------------

module mar (
    input  wire        clk,
    input  wire        rst,      // active HIGH reset
    input  wire        MI,       // Memory In - load MAR from bus
    input  wire [7:0]  bus_in,   // 8-bit bus input
    output reg  [3:0]  addr_out  // 4-bit address sent to RAM
);

    always @(posedge clk) begin
        if (rst)      addr_out <= 4'b0000;    // clear address on reset
        else if (MI)  addr_out <= bus_in[3:0]; // latch lower 4 bits from bus
    end

endmodule
