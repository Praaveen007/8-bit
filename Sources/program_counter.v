// =============================================================================
// SAP-1 Program Counter
// Matches diagram signals exactly:
//   CO  = Count Out  → drives 4-bit value onto bus
//   CL  = Clear      → synchronous reset to 0000
//   CE  = Count Enable → increment on clock edge
// 4-bit counter, zero-extended to 8-bit on bus
// =============================================================================
module program_counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        CO,       // Count Out  — enable PC value onto bus
    input  wire        CL,       // Clear      — reset PC to 0000
    input  wire        CE,       // Count Enable — increment PC
    output wire [7:0]  bus_out,  // 8-bit bus (upper nibble = 0000)
    output wire [3:0]  pc_val    // Internal PC value (for debug LEDs)
);

    reg [3:0] pc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)   pc <= 4'b0000;
        else if (CL)  pc <= 4'b0000;
        else if (CE)  pc <= pc + 1'b1;
    end

    // Tri-state: only drive bus when CO=1
    assign bus_out = CO ? {4'b0000, pc} : 8'bz;
    assign pc_val  = pc;

endmodule
