// =============================================================================
// SAP-1 Top-Level — Boolean FPGA Board
// Architecture exactly matches the diagram:
//   BUS (8-bit shared)
//   ├── MAR          (MI)
//   ├── Program Counter (CO, CL, CE)
//   ├── RAM          (RI, RO)
//   ├── A Register   (AI, AO)
//   ├── ALU          (ALO, SUB, XRA, ANA) → Flag Register (FE)
//   ├── B Register   (BI)
//   ├── Output Register (OI) → Output Display
//   └── Instruction Register (II, IO) → Control Unit (T0-T5)
//
// Board I/O:
//   CLK  = W5  (100 MHz)
//   BTN0 = U18 (manual step)
//   BTN1 = R18 (reset, active high)
//   SW[1:0]    (clock speed: 00=1Hz 01=10Hz 10=100Hz 11=1kHz)
//   AN[7:0], SEG[6:0], DP  (7-segment display → shows output register)
//   LED[15:8]  = output register value
//   LED[7:6]   = flags {carry, zero}
//   LED[5:3]   = T-state (T0-T5)
//   LED[3:0]   = PC value
// =============================================================================
module sap1_top (
    input  wire        CLK,
    input  wire        BTN0,        // Manual step
    input  wire        BTN1,        // Reset (active high)
    input  wire [1:0]  SW,          // Clock speed

    output wire [7:0]  AN,
    output wire [6:0]  SEG,
    output wire        DP,
    output wire [15:0] LED
);

    // -----------------------------------------------------------------------
    // Global signals
    // -----------------------------------------------------------------------
    wire        rst_n   = ~BTN1;
    wire [7:0]  bus;               // The shared 8-bit bus
    wire        sap_clk;
    wire        HLT_sig;

    // -----------------------------------------------------------------------
    // Control signals (named exactly as in the diagram)
    // -----------------------------------------------------------------------
    wire MI, RO, RI, II, IO;
    wire CO, CE, CL;
    wire AI, AO;
    wire ALO;
    wire BI;
    wire OI;
    wire FE;

    // -----------------------------------------------------------------------
    // Internal data paths
    // -----------------------------------------------------------------------
    wire [3:0]  pc_val;
    wire [3:0]  mar_addr;
    wire [7:0]  a_val, b_val;
    wire [3:0]  opcode, operand;
    wire [1:0]  alu_flags;         // {carry, zero} — combinational from ALU
    wire [1:0]  latched_flags;     // From Flag Register
    wire [7:0]  alu_result;
    wire [2:0]  t_state;
    wire [7:0]  out_val;

    // -----------------------------------------------------------------------
    // Clock Module
    // -----------------------------------------------------------------------
    clock_module u_clk (
        .clk_100mhz  (CLK),
        .rst_n       (rst_n),
        .speed_sel   (SW),
        .manual_step (BTN0),
        .hlt         (HLT_sig),
        .clk_out     (sap_clk)
    );

    // -----------------------------------------------------------------------
    // Program Counter  (CO, CL, CE → diagram)
    // -----------------------------------------------------------------------
    program_counter u_pc (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .CO      (CO),
        .CL      (CL),
        .CE      (CE),
        .bus_out (bus),
        .pc_val  (pc_val)
    );

    // -----------------------------------------------------------------------
    // MAR  (MI → diagram)
    // -----------------------------------------------------------------------
    mar u_mar (
        .clk      (sap_clk),
        .rst_n    (rst_n),
        .MI       (MI),
        .bus_in   (bus),
        .addr_out (mar_addr)
    );

    // -----------------------------------------------------------------------
    // RAM  (RI, RO → diagram)
    // -----------------------------------------------------------------------
    ram u_ram (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .RI      (RI),
        .RO      (RO),
        .addr    (mar_addr),
        .bus_in  (bus),
        .bus_out (bus)
    );

    // -----------------------------------------------------------------------
    // Instruction Register  (II, IO → diagram)
    // -----------------------------------------------------------------------
    instruction_register u_ir (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .II      (II),
        .IO      (IO),
        .bus_in  (bus),
        .bus_out (bus),
        .opcode  (opcode),
        .operand (operand)
    );

    // -----------------------------------------------------------------------
    // A Register  (AI, AO → diagram)
    // -----------------------------------------------------------------------
    a_register u_a (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .AI      (AI),
        .AO      (AO),
        .bus_in  (bus),
        .bus_out (bus),
        .a_val   (a_val)
    );

    // -----------------------------------------------------------------------
    // B Register  (BI → diagram)
    // -----------------------------------------------------------------------
    b_register u_b (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .BI      (BI),
        .bus_in  (bus),
        .b_val   (b_val)
    );

    // -----------------------------------------------------------------------
    // ALU  (ALO, SUB, XRA, ANA → diagram)
    // Outputs 2-bit flags {carry, zero} to Flag Register
    // -----------------------------------------------------------------------
    alu u_alu (
        .ALO       (ALO),
        .alu_op    (opcode),     // ALU function = opcode directly (0x2-0xD)
        .a_val     (a_val),
        .b_val     (b_val),
        .bus_out   (bus),
        .flags     (alu_flags),
        .alu_result(alu_result)
    );

    // -----------------------------------------------------------------------
    // Flag Register  (FE → diagram)
    // Latches carry and zero flags from ALU
    // -----------------------------------------------------------------------
    flag_register u_flags (
        .clk       (sap_clk),
        .rst_n     (rst_n),
        .FE        (FE),
        .flags_in  (alu_flags),
        .flags_out (latched_flags)
    );

    // -----------------------------------------------------------------------
    // Output Register + Display  (OI → diagram)
    // -----------------------------------------------------------------------
    output_register u_out (
        .clk        (sap_clk),
        .clk_100mhz (CLK),
        .rst_n      (rst_n),
        .OI         (OI),
        .bus_in     (bus),
        .AN         (AN),
        .SEG        (SEG),
        .DP         (DP),
        .out_val    (out_val)
    );

    // -----------------------------------------------------------------------
    // Control Unit  (generates all control signals, T0-T5)
    // -----------------------------------------------------------------------
    control_unit u_cu (
        .clk     (sap_clk),
        .rst_n   (rst_n),
        .opcode  (opcode),
        .flags   (latched_flags),
        .MI      (MI),  .RO  (RO),  .RI  (RI),
        .II      (II),  .IO  (IO),
        .CO      (CO),  .CE  (CE),  .CL  (CL),
        .AI      (AI),  .AO  (AO),
        .ALO     (ALO),
        .BI      (BI),
        .OI      (OI),
        .FE      (FE),
        .HLT     (HLT_sig),
        .t_state (t_state)
    );

    // -----------------------------------------------------------------------
    // LED assignments
    //   LED[15:8] = Output register (result shown on 7-seg)
    //   LED[7]    = Carry flag
    //   LED[6]    = Zero flag
    //   LED[5:3]  = T-state (T0-T5)
    //   LED[2:0] / LED[3:0] = PC
    // -----------------------------------------------------------------------
    assign LED[15:8] = out_val;
    assign LED[7]    = latched_flags[1];   // Carry
    assign LED[6]    = latched_flags[0];   // Zero
    assign LED[5:3]  = t_state;
    assign LED[2:0]  = pc_val[2:0];

endmodule
