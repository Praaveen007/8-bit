// =============================================================================
// SAP-1 Control Unit
// Matches diagram exactly:
//   T0, T1, T2 = FETCH  (same for every instruction)
//   T3, T4, T5 = EXECUTE (depends on opcode)
//
// Control signals (all active-high):
//   MI  = Memory Address Register In
//   RO  = RAM Out
//   RI  = RAM In  (write — not used in run mode)
//   II  = Instruction Register In
//   IO  = Instruction Register Out (operand)
//   CO  = Program Counter Out
//   CE  = Program Counter Count Enable (increment)
//   CL  = Program Counter Clear
//   AI  = A Register In
//   AO  = A Register Out
//   ALO = ALU Out
//   BI  = B Register In
//   OI  = Output Register In
//   FE  = Flag Register Enable (latch ALU flags)
//   HLT = Halt clock
//
// Opcode map (IR[7:4]) — 0x2-0xD are ALU operations, decoded generically.
// The ALU itself receives the opcode directly (see sap1_top.v) and picks
// its own function — the control unit only needs to know THREE things
// about an opcode: does it need a second operand fetched from RAM into B
// (needs_operand), is it an ALU op at all (is_alu_op), and the two fixed
// special cases OUT / HLT.
//
//   0x0 NOP                    0x8 INR   A = A + 1
//   0x1 LDA <addr>  A = RAM[addr]   0x9 DCR   A = A - 1
//   0x2 ADD <addr>  A = A + RAM[addr]  0xA SHL   A = A << 1
//   0x3 SUB <addr>  A = A - RAM[addr]  0xB SHR   A = A >> 1
//   0x4 ANA <addr>  A = A & RAM[addr]  0xC NAND <addr>  A = ~(A & RAM[addr])
//   0x5 XRA <addr>  A = A ^ RAM[addr]  0xD NOR  <addr>  A = ~(A | RAM[addr])
//   0x6 ORA <addr>  A = A | RAM[addr]  0xE OUT   Output = A
//   0x7 CMA   A = ~A                   0xF HLT   Stop
//
// 0x7-0xB (CMA, INR, DCR, SHL, SHR) are unary: they don't touch RAM/B at
// all, so T3 and T4 are simply idle for them, same as they are for NOP.
// =============================================================================
module control_unit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,       // From IR[7:4]
    input  wire [1:0]  flags,        // From Flag Register {carry, zero} (reserved for future conditional jumps)

    // All control outputs
    output reg         MI,
    output reg         RO,
    output reg         RI,
    output reg         II,
    output reg         IO,
    output reg         CO,
    output reg         CE,
    output reg         CL,
    output reg         AI,
    output reg         AO,
    output reg         ALO,
    output reg         BI,
    output reg         OI,
    output reg         FE,
    output reg         HLT,

    output wire [2:0]  t_state       // Current T-state (0–5) for debug
);

    // --- Opcode definitions ---
    localparam OP_NOP  = 4'h0;
    localparam OP_LDA  = 4'h1;
    localparam OP_ADD  = 4'h2;
    localparam OP_SUB  = 4'h3;
    localparam OP_ANA  = 4'h4;
    localparam OP_XRA  = 4'h5;
    localparam OP_ORA  = 4'h6;
    localparam OP_CMA  = 4'h7;
    localparam OP_INR  = 4'h8;
    localparam OP_DCR  = 4'h9;
    localparam OP_SHL  = 4'hA;
    localparam OP_SHR  = 4'hB;
    localparam OP_NAND = 4'hC;
    localparam OP_NOR  = 4'hD;
    localparam OP_OUT  = 4'hE;
    localparam OP_HLT  = 4'hF;

    // Any opcode in [ADD..NOR] (0x2-0xD) is an ALU op.
    // [CMA..SHR] (0x7-0xB) are the unary ones — no RAM operand needed.
    wire is_alu_op     = (opcode >= OP_ADD) && (opcode <= OP_NOR);
    wire is_unary_alu  = (opcode >= OP_CMA) && (opcode <= OP_SHR);
    wire needs_operand = (opcode == OP_LDA) || (is_alu_op && !is_unary_alu);

    // --- T-state counter (0–5) ---
    reg [2:0] T;
    assign t_state = T;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)          T <= 3'd0;
        else if (T == 3'd5)  T <= 3'd0;
        else                 T <= T + 1'b1;
    end

    // --- Microinstruction decode ---
    always @(*) begin
        // Default: all signals inactive
        {MI,RO,RI,II,IO,CO,CE,CL,AI,AO,ALO,BI,OI,FE,HLT} = 15'b0;

        case (T)
            // ============================
            // FETCH — T0, T1, T2
            // ============================
            3'd0: begin
                CO = 1;   // PC → bus
                MI = 1;   // MAR ← bus (PC value)
            end

            3'd1: begin
                CE = 1;   // PC++ (increment)
            end

            3'd2: begin
                RO = 1;   // RAM[MAR] → bus
                II = 1;   // IR ← bus (load instruction)
            end

            // ============================
            // EXECUTE — T3, T4, T5
            // ============================
            3'd3: begin
                if (needs_operand) begin
                    IO = 1;   // IR operand → bus
                    MI = 1;   // MAR ← operand (data address)
                end else if (opcode == OP_OUT) begin
                    AO = 1;   // A → bus
                    OI = 1;   // Output register ← bus
                end else if (opcode == OP_HLT) begin
                    HLT = 1;
                end
                // NOP and the unary ALU ops (CMA/INR/DCR/SHL/SHR) idle here
            end

            3'd4: begin
                if (opcode == OP_LDA) begin
                    RO = 1;   // RAM[MAR] → bus
                    AI = 1;   // A ← bus
                end else if (is_alu_op && !is_unary_alu) begin
                    RO = 1;   // RAM[MAR] → bus
                    BI = 1;   // B ← bus
                end else if (opcode == OP_HLT) begin
                    HLT = 1;
                end
                // NOP, OUT (already done), unary ALU ops idle here
            end

            3'd5: begin
                if (is_alu_op) begin
                    ALO = 1;  // ALU result → bus (alu_op = opcode, set in top-level)
                    AI  = 1;  // A ← ALU result
                    FE  = 1;  // Latch carry/zero flags
                end else if (opcode == OP_HLT) begin
                    HLT = 1;
                end
                // NOP, LDA, OUT already finished — idle here
            end
        endcase
    end

endmodule
