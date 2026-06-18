// -------------------------------------------------------
// SAP-1 Top Level Module
// Boolean FPGA Board (Artix-7 xc7a35t-cpg236-1)
//
// This connects all SAP-1 modules together and maps them
// to the Boolean board buttons, switches, LEDs, and
// 7-segment display.
//
// Board connections:
//   CLK      = 100 MHz crystal oscillator (pin W5)
//   BTN0     = manual single step (pin U18)
//   BTN1     = reset active HIGH (pin R18)
//   SW[1:0]  = clock speed select
//              00 = 1 Hz, 01 = 10 Hz, 10 = 100 Hz, 11 = 1 kHz
//   AN[7:0]  = 7-segment anode (active LOW)
//   SEG[6:0] = 7-segment cathodes
//   LED[15:8] = output register value
//   LED[7]    = carry flag
//   LED[6]    = zero flag
//   LED[5:3]  = T-state (0 to 5)
//   LED[2:0]  = program counter value
// -------------------------------------------------------

module sap1_top (
    input  wire        CLK,    // 100 MHz board clock
    input  wire        BTN0,   // manual single step
    input  wire        BTN1,   // reset (active HIGH)
    input  wire [1:0]  SW,     // clock speed select

    output wire [7:0]  AN,     // 7-segment anodes
    output wire [6:0]  SEG,    // 7-segment cathodes
    output wire        DP,     // decimal point
    output wire [15:0] LED     // debug LEDs
);

    // -------------------------------------------------------
    // Internal wires
    // -------------------------------------------------------
    wire        rst;        // active HIGH reset = BTN1
    wire [7:0]  bus;        // shared 8-bit bus (tri-state)
    wire        sap_clk;    // divided SAP system clock
    wire        HLT_sig;    // halt signal from control unit

    assign rst = BTN1;      // BTN1 is active HIGH on Boolean board

    // -------------------------------------------------------
    // Control signals from control unit to all modules
    // -------------------------------------------------------
    wire MI, RO, RI, II, IO;
    wire CO, CE, CL;
    wire AI, AO;
    wire ALO;
    wire BI;
    wire OI;
    wire FE;

    // -------------------------------------------------------
    // Internal data connections
    // -------------------------------------------------------
    wire [3:0]  pc_val;         // program counter value for LEDs
    wire [3:0]  mar_addr;       // address from MAR to RAM
    wire [7:0]  a_val;          // A register to ALU
    wire [7:0]  b_val;          // B register to ALU
    wire [3:0]  opcode;         // opcode from IR to control unit
    wire [3:0]  operand;        // operand from IR (lower nibble)
    wire [1:0]  alu_flags;      // carry and zero from ALU (live)
    wire [1:0]  latched_flags;  // carry and zero from flag register (stable)
    wire [7:0]  alu_result;     // ALU result for debug
    wire [2:0]  t_state;        // T-state from control unit for LEDs
    wire [7:0]  out_val;        // output register value for LEDs

    // -------------------------------------------------------
    // Clock Module
    // -------------------------------------------------------
    clock_module u_clk (
        .clk_100mhz  (CLK),
        .rst         (rst),
        .speed_sel   (SW),
        .manual_step (BTN0),
        .hlt         (HLT_sig),
        .clk_out     (sap_clk)
    );

    // -------------------------------------------------------
    // Program Counter
    // -------------------------------------------------------
    program_counter u_pc (
        .clk     (sap_clk),
        .rst     (rst),
        .CO      (CO),
        .CE      (CE),
        .CL      (CL),
        .bus_out (bus),
        .pc_val  (pc_val)
    );

    // -------------------------------------------------------
    // Memory Address Register
    // -------------------------------------------------------
    mar u_mar (
        .clk      (sap_clk),
        .rst      (rst),
        .MI       (MI),
        .bus_in   (bus),
        .addr_out (mar_addr)
    );

    // -------------------------------------------------------
    // RAM
    // -------------------------------------------------------
    ram u_ram (
        .clk     (sap_clk),
        .rst     (rst),
        .RI      (RI),
        .RO      (RO),
        .addr    (mar_addr),
        .bus_in  (bus),
        .bus_out (bus)
    );

    // -------------------------------------------------------
    // Instruction Register
    // -------------------------------------------------------
    instruction_register u_ir (
        .clk     (sap_clk),
        .rst     (rst),
        .II      (II),
        .IO      (IO),
        .bus_in  (bus),
        .bus_out (bus),
        .opcode  (opcode),
        .operand (operand)
    );

    // -------------------------------------------------------
    // A Register (Accumulator)
    // -------------------------------------------------------
    a_register u_a (
        .clk     (sap_clk),
        .rst     (rst),
        .AI      (AI),
        .AO      (AO),
        .bus_in  (bus),
        .bus_out (bus),
        .a_val   (a_val)
    );

    // -------------------------------------------------------
    // B Register
    // -------------------------------------------------------
    b_register u_b (
        .clk     (sap_clk),
        .rst     (rst),
        .BI      (BI),
        .bus_in  (bus),
        .b_val   (b_val)
    );

    // -------------------------------------------------------
    // ALU
    // opcode is passed directly as alu_op so the ALU
    // automatically selects the right operation
    // -------------------------------------------------------
    alu u_alu (
        .ALO        (ALO),
        .alu_op     (opcode),
        .a_val      (a_val),
        .b_val      (b_val),
        .bus_out    (bus),
        .flags      (alu_flags),
        .alu_result (alu_result)
    );

    // -------------------------------------------------------
    // Flag Register
    // -------------------------------------------------------
    flag_register u_flags (
        .clk       (sap_clk),
        .rst       (rst),
        .FE        (FE),
        .flags_in  (alu_flags),
        .flags_out (latched_flags)
    );

    // -------------------------------------------------------
    // Output Register and 7-Segment Display
    // -------------------------------------------------------
    output_register u_out (
        .clk        (sap_clk),
        .clk_100mhz (CLK),
        .rst        (rst),
        .OI         (OI),
        .bus_in     (bus),
        .AN         (AN),
        .SEG        (SEG),
        .DP         (DP),
        .out_val    (out_val)
    );

    // -------------------------------------------------------
    // Control Unit
    // -------------------------------------------------------
    control_unit u_cu (
        .clk     (sap_clk),
        .rst     (rst),
        .opcode  (opcode),
        .flags   (latched_flags),
        .MI      (MI),
        .RO      (RO),
        .RI      (RI),
        .II      (II),
        .IO      (IO),
        .CO      (CO),
        .CE      (CE),
        .CL      (CL),
        .AI      (AI),
        .AO      (AO),
        .ALO     (ALO),
        .BI      (BI),
        .OI      (OI),
        .FE      (FE),
        .HLT     (HLT_sig),
        .t_state (t_state)
    );

    // -------------------------------------------------------
    // LED debug assignments
    // -------------------------------------------------------
    assign LED[15:8] = out_val;              // output register value
    assign LED[7]    = latched_flags[1];     // carry flag
    assign LED[6]    = latched_flags[0];     // zero flag
    assign LED[5:3]  = t_state;              // current T-state
    assign LED[2:0]  = pc_val[2:0];          // program counter

endmodule
