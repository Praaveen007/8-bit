// -------------------------------------------------------
// Control Unit for SAP-1
//
// This is the brain of the computer. It steps through
// 6 T-states (T0 to T5) and generates all control signals
// that tell every other module what to do each clock cycle.
//
// T0, T1, T2 = FETCH  (same for every instruction)
// T3, T4, T5 = EXECUTE (different for each opcode)
//
// Control signals generated (all active HIGH):
//   MI  = Memory Address Register In
//   RO  = RAM Out
//   RI  = RAM In  (write, not used in run mode)
//   II  = Instruction Register In
//   IO  = Instruction Register Out (sends operand to bus)
//   CO  = Program Counter Out
//   CE  = Program Counter Count Enable (increment)
//   CL  = Program Counter Clear
//   AI  = A Register In
//   AO  = A Register Out
//   ALO = ALU Out
//   BI  = B Register In
//   OI  = Output Register In
//   FE  = Flag Register Enable
//   HLT = Halt (stop clock)
//
// Opcode table (IR[7:4]) - all 16 opcodes:
//   0000 = NOP   do nothing
//   0001 = LDA   A = RAM[addr]
//   0010 = ADD   A = A + RAM[addr]
//   0011 = SUB   A = A - RAM[addr]
//   0100 = ANA   A = A AND RAM[addr]
//   0101 = XRA   A = A XOR RAM[addr]
//   0110 = ORA   A = A OR  RAM[addr]
//   0111 = CMA   A = NOT A          (no operand needed)
//   1000 = INR   A = A + 1          (no operand needed)
//   1001 = DCR   A = A - 1          (no operand needed)
//   1010 = SHL   A = A shift left   (no operand needed)
//   1011 = SHR   A = A shift right  (no operand needed)
//   1100 = NAND  A = NOT(A AND RAM[addr])
//   1101 = NOR   A = NOT(A OR  RAM[addr])
//   1110 = OUT   output register = A
//   1111 = HLT   stop the clock
// -------------------------------------------------------

module control_unit (
    input  wire        clk,
    input  wire        rst,       // active HIGH reset
    input  wire [3:0]  opcode,    // from IR[7:4]
    input  wire [1:0]  flags,     // {carry, zero} from flag register

    // all control signal outputs
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

    output wire [2:0]  t_state    // current T-state for debug LEDs
);

    // opcode parameters using binary values
    parameter OP_NOP  = 4'b0000;
    parameter OP_LDA  = 4'b0001;
    parameter OP_ADD  = 4'b0010;
    parameter OP_SUB  = 4'b0011;
    parameter OP_ANA  = 4'b0100;
    parameter OP_XRA  = 4'b0101;
    parameter OP_ORA  = 4'b0110;
    parameter OP_CMA  = 4'b0111;
    parameter OP_INR  = 4'b1000;
    parameter OP_DCR  = 4'b1001;
    parameter OP_SHL  = 4'b1010;
    parameter OP_SHR  = 4'b1011;
    parameter OP_NAND = 4'b1100;
    parameter OP_NOR  = 4'b1101;
    parameter OP_OUT  = 4'b1110;
    parameter OP_HLT  = 4'b1111;

    // helper wires to group opcode types
    // binary ops: need to fetch a second operand from RAM into B
    wire is_alu_op    = (opcode >= OP_ADD) && (opcode <= OP_NOR);
    // unary ops: only use A, no RAM fetch needed
    wire is_unary_alu = (opcode >= OP_CMA) && (opcode <= OP_SHR);
    // needs_operand: LDA + all binary ALU ops
    wire needs_operand = (opcode == OP_LDA) || (is_alu_op && !is_unary_alu);

    // T-state counter: counts 0,1,2,3,4,5,0,1,2,...
    reg [2:0] T;
    assign t_state = T;

    always @(posedge clk) begin
        if (rst)           T <= 3'b000;  // reset to T0
        else if (T == 3'b101) T <= 3'b000;  // wrap back to T0 after T5
        else               T <= T + 1'b1;
    end

    // microinstruction decode
    // set control signals based on T-state and opcode
    always @(*) begin
        // default: all signals off
        {MI, RO, RI, II, IO, CO, CE, CL, AI, AO, ALO, BI, OI, FE, HLT} = 15'b000_0000_0000_0000_0;

        case (T)

            // ==========================
            // T0: put PC on bus, load MAR
            // ==========================
            3'b000 : begin
                CO = 1'b1;  // PC value goes onto bus
                MI = 1'b1;  // MAR latches the address from bus
            end

            // ==========================
            // T1: increment PC
            // ==========================
            3'b001 : begin
                CE = 1'b1;  // PC = PC + 1
            end

            // ==========================
            // T2: read RAM, load IR
            // ==========================
            3'b010 : begin
                RO = 1'b1;  // RAM puts instruction on bus
                II = 1'b1;  // IR latches instruction from bus
            end

            // ==========================
            // T3: first execute step
            // ==========================
            3'b011 : begin
                if (needs_operand) begin
                    IO = 1'b1;  // operand address from IR goes to bus
                    MI = 1'b1;  // MAR latches operand address
                end
                else if (opcode == OP_OUT) begin
                    AO = 1'b1;  // A value goes onto bus
                    OI = 1'b1;  // output register latches from bus
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1; // stop the clock
                end
                // NOP and unary ALU ops do nothing here
            end

            // ==========================
            // T4: second execute step
            // ==========================
            3'b100 : begin
                if (opcode == OP_LDA) begin
                    RO = 1'b1;  // RAM puts data on bus
                    AI = 1'b1;  // A latches from bus
                end
                else if (is_alu_op && !is_unary_alu) begin
                    RO = 1'b1;  // RAM puts data on bus
                    BI = 1'b1;  // B latches from bus
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1;
                end
                // OUT already done, unary ALU ops idle here
            end

            // ==========================
            // T5: third execute step
            // ==========================
            3'b101 : begin
                if (is_alu_op) begin
                    ALO = 1'b1; // ALU result goes onto bus
                    AI  = 1'b1; // A latches the ALU result
                    FE  = 1'b1; // flag register latches carry and zero
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1;
                end
                // NOP, LDA, OUT already completed - idle
            end

        endcase
    end

endmodule
