// =============================================================================
// SAP-1 Instruction Register (IR)
// Matches diagram signals:
//   II = Instruction In  — latch full byte from bus
//   IO = Instruction Out — drive lower 4-bit operand (zero-extended) to bus
//
// IR[7:4] = OPCODE  → 4 bits to Control Unit (always visible)
// IR[3:0] = OPERAND → 4 bits via IO onto bus (used to load MAR with data addr)
// =============================================================================
module instruction_register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        II,        // Instruction In
    input  wire        IO,        // Instruction Out (operand to bus)
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,   // Zero-extended operand onto bus
    output wire [3:0]  opcode,    // → Control Unit
    output wire [3:0]  operand    // → Control Unit (for reference)
);

    reg [7:0] ir;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  ir <= 8'h00;
        else if (II) ir <= bus_in;
    end

    assign opcode  = ir[7:4];
    assign operand = ir[3:0];

    // Only lower nibble goes onto bus (zero-padded to 8 bits)
    assign bus_out = IO ? {4'b0000, ir[3:0]} : 8'bz;

endmodule
