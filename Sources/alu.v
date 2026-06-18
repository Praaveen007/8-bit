// =============================================================================
// SAP-1 ALU — 8-bit, 12 operations
// Matches diagram signal:
//   ALO = ALU Out — drive result onto bus
//
// alu_op is wired directly to the instruction's opcode (IR[7:4]). Opcodes
// 0x2-0xD select a distinct ALU function (see table below); any other
// opcode falls through to the default case, which is harmless because the
// control unit never asserts ALO for those opcodes.
//
//   0x2 ADD   A + B            0x8 INR   A + 1
//   0x3 SUB   A - B            0x9 DCR   A - 1
//   0x4 ANA   A & B            0xA SHL   A << 1
//   0x5 XRA   A ^ B            0xB SHR   A >> 1
//   0x6 ORA   A | B            0xC NAND  ~(A & B)
//   0x7 CMA   ~A               0xD NOR   ~(A | B)
//
// Outputs 2-bit flag word to Flag Register:
//   flag[1] = Carry (C) — bit that fell out of the 8-bit result
//   flag[0] = Zero  (Z) — set when result == 0
//
// ALU is combinational — result always available, only gated onto the
// bus when ALO = 1.
// =============================================================================
module alu (
    input  wire        ALO,       // ALU Out — enable to bus
    input  wire [3:0]  alu_op,    // = opcode (IR[7:4]); selects the operation
    input  wire [7:0]  a_val,
    input  wire [7:0]  b_val,
    output wire [7:0]  bus_out,
    output wire [1:0]  flags,     // {carry, zero} to Flag Register
    output wire [7:0]  alu_result // Always-on result (for debug)
);

    reg [8:0] result;   // 9-bit to capture carry / shifted-out bit

    always @(*) begin
        case (alu_op)
            4'h2: result = {1'b0, a_val} + {1'b0, b_val};           // ADD
            4'h3: result = {1'b0, a_val} + {1'b0, ~b_val} + 9'd1;   // SUB (2's complement)
            4'h4: result = {1'b0, a_val & b_val};                   // ANA
            4'h5: result = {1'b0, a_val ^ b_val};                   // XRA
            4'h6: result = {1'b0, a_val | b_val};                   // ORA
            4'h7: result = {1'b0, ~a_val};                          // CMA
            4'h8: result = {1'b0, a_val} + 9'd1;                    // INR
            4'h9: result = {1'b0, a_val} + 9'h1FF;                  // DCR (A + (-1))
            4'hA: result = {1'b0, a_val} << 1;                      // SHL, carry = old bit7
            4'hB: result = {a_val[0], 1'b0, a_val[7:1]};            // SHR, carry = old bit0
            4'hC: result = {1'b0, ~(a_val & b_val)};                // NAND
            4'hD: result = {1'b0, ~(a_val | b_val)};                // NOR
            default: result = {1'b0, a_val} + {1'b0, b_val};        // unused opcodes: harmless fallback
        endcase
    end

    assign alu_result = result[7:0];
    assign flags[1]   = result[8];              // Carry / shift-out flag
    assign flags[0]   = (result[7:0] == 8'h00); // Zero flag

    assign bus_out = ALO ? result[7:0] : 8'bz;

endmodule
