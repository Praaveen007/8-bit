// -------------------------------------------------------
// Program Counter (PC) for SAP-1
//
// This is a 4-bit counter. It holds the address of the
// next instruction to be fetched from RAM.
//
// Control signals:
//   CO = Count Out  : puts PC value onto the 8-bit bus
//   CE = Count Enable : increments PC by 1 on clock edge
//   CL = Clear      : resets PC back to 0000
//   rst = active HIGH system reset
// -------------------------------------------------------

module program_counter (
    input  wire        clk,
    input  wire        rst,     // active HIGH reset
    input  wire        CO,      // Count Out - enable PC onto bus
    input  wire        CE,      // Count Enable - increment PC
    input  wire        CL,      // Clear - reset PC to 0
    output wire [7:0]  bus_out, // upper 4 bits are 0, lower 4 = PC
    output wire [3:0]  pc_val   // direct PC value for LEDs
);

    reg [3:0] pc;

    always @(posedge clk) begin
        if (rst)       pc <= 4'b0000;  // reset PC to zero
        else if (CL)   pc <= 4'b0000;  // clear PC to zero
        else if (CE)   pc <= pc + 1'b1; // increment PC
        // if none of the above, PC holds its value
    end

    // PC only drives the bus when CO = 1 (tri-state otherwise)
    // upper nibble is always 0000 since PC is only 4 bits
    assign bus_out = CO ? {4'b0000, pc} : 8'bz;

    // always show PC value on debug output
    assign pc_val = pc;

endmodule
