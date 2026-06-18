// -------------------------------------------------------
// Instruction Register (IR) for SAP-1
//
// Holds the current instruction fetched from RAM.
// An instruction is 8 bits split into two parts:
//   IR[7:4] = OPCODE  (what operation to do)
//   IR[3:0] = OPERAND (which memory address to use)
//
// The opcode always feeds the control unit.
// The operand goes onto the bus only when IO = 1,
// so the MAR can latch it as the data address.
//
// Control signals:
//   II = Instruction In  : latch bus value into IR
//   IO = Instruction Out : put operand (lower nibble) onto bus
//   rst = active HIGH reset
// -------------------------------------------------------

module instruction_register (
    input  wire        clk,
    input  wire        rst,      // active HIGH reset
    input  wire        II,       // Instruction In - load IR from bus
    input  wire        IO,       // Instruction Out - send operand to bus
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,  // zero-extended operand onto bus
    output wire [3:0]  opcode,   // upper nibble to control unit
    output wire [3:0]  operand   // lower nibble (address field)
);

    reg [7:0] ir;

    always @(posedge clk) begin
        if (rst)      ir <= 8'b0000_0000; // clear instruction register
        else if (II)  ir <= bus_in;        // load new instruction from bus
    end

    // opcode is the top 4 bits - always visible to control unit
    assign opcode = ir[7:4];

    // operand is the bottom 4 bits - the RAM address to use
    assign operand = ir[3:0];

    // only put operand on bus when IO = 1 (tri-state otherwise)
    // zero-pad to 8 bits since the bus is 8 bits wide
    assign bus_out = IO ? {4'b0000, ir[3:0]} : 8'bz;

endmodule
