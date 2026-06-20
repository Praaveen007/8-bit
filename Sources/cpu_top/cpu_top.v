module cpu_top (
    input  wire        CLK,
    input  wire        BTN0,
    input  wire        BTN1,
    input  wire        BTN3,
    input  wire [15:0] SW,

    // External memory bus
    output wire [3:0]  MEM_ADDR,
    output wire        MEM_RD,
    output wire        MEM_WR,
    output wire [7:0]  MEM_DOUT,
    input  wire [7:0]  MEM_DIN,

    output wire        SAP_CLK,
    input  wire        WRITE_DONE,

    output wire [3:0]  D0_AN,
    output wire [7:0]  D0_SEG,
    output wire [3:0]  D1_AN,
    output wire [7:0]  D1_SEG,
    output wire [15:0] LED
);

    wire [7:0]  sw_data   = SW[7:0];
    wire [3:0]  sw_addr   = SW[11:8];
    wire [1:0]  clk_speed = SW[13:12];
    wire        prog_mode = SW[14];
    wire        rst       = BTN1;

    // =========================================================================
    // Internal signals
    // =========================================================================
    wire        sap_clk;
    wire        HLT_sig;

    wire [3:0]  pc_val;
    wire [3:0]  mar_addr;
    wire [7:0]  a_val;
    wire [7:0]  b_val;
    wire [7:0]  out_val;
    wire [3:0]  opcode, operand;
    wire [1:0]  alu_flags;
    wire [1:0]  latched_flags;
    wire [7:0]  alu_result;
    wire [2:0]  t_state;
    wire [7:0]  ir;

    // Control signals
    wire MI, RO, RI, II, IO;
    wire CO, CE, CL;
    wire AI, AO, ALO, BI, OI, FE;

   
    reg [7:0] bus_reg;

    always @(*) begin
        if      (CO)  bus_reg = {4'b0000, pc_val};   // PC â†’ bus
        else if (RO)  bus_reg = MEM_DIN;              // RAM â†’ bus
        else if (IO)  bus_reg = {4'b0000, operand};   // IR operand â†’ bus
        else if (AO)  bus_reg = a_val;                // A â†’ bus
        else if (ALO) bus_reg = alu_result;            // ALU â†’ bus
        else          bus_reg = 8'h00;                 // idle
    end

    // =========================================================================
    // External memory bus
    // =========================================================================
    assign SAP_CLK  = sap_clk;
    assign MEM_ADDR = mar_addr;
    assign MEM_RD   = RO;
    assign MEM_WR   = RI;
    assign MEM_DOUT = a_val;

    // =========================================================================
    // Submodules â€” all receive bus_reg as input, never drive tristate
    // =========================================================================

    clock_module u_clk (
        .clk_100mhz  (CLK),
        .rst         (rst),
        .speed_sel   (clk_speed),
        .manual_step (BTN0),
        .hlt         (HLT_sig),
        .prog_mode   (prog_mode),
        .clk_out     (sap_clk)
    );

    program_counter u_pc (
        .clk     (sap_clk),
        .rst     (rst),
        .CO      (CO),
        .CL      (CL),
        .CE      (CE),
        .bus_out (bus_reg),   // output onto bus (via mux above)
        .pc_val  (pc_val)
    );

    mar u_mar (
        .clk      (sap_clk),
        .rst      (rst),
        .MI       (MI),
        .bus_in   (bus_reg),
        .addr_out (mar_addr)
    );

    instruction_register u_ir (
        .clk     (sap_clk),
        .rst     (rst),
        .II      (II),
        .IO      (IO),
        .bus_in  (bus_reg),
        .opcode  (opcode),
        .operand (operand),
        .ir_out  (ir)
    );

    a_register u_a (
        .clk     (sap_clk),
        .rst     (rst),
        .AI      (AI),
        .AO      (AO),
        .bus_in  (bus_reg),
        .a_val   (a_val)
    );

    b_register u_b (
        .clk     (sap_clk),
        .rst     (rst),
        .BI      (BI),
        .bus_in  (bus_reg),
        .b_val   (b_val)
    );

    alu u_alu (
        .ALO        (ALO),
        .alu_op     (opcode),
        .a_val      (a_val),
        .b_val      (b_val),
        .flags      (alu_flags),
        .alu_result (alu_result)
    );

    flag_register u_flags (
        .clk       (sap_clk),
        .rst       (rst),
        .FE        (FE),
        .flags_in  (alu_flags),
        .flags_out (latched_flags)
    );

    output_register u_out (
        .clk        (sap_clk),
        .clk_100mhz (CLK),
        .rst        (rst),
        .OI         (OI),
        .bus_in     (bus_reg),
        .prog_mode  (prog_mode),
        .prog_addr  (sw_addr),
        .prog_data  (sw_data),
        .write_done (WRITE_DONE),
        .D0_AN      (D0_AN),
        .D0_SEG     (D0_SEG),
        .D1_AN      (D1_AN),
        .D1_SEG     (D1_SEG),
        .out_val    (out_val)
    );

    control_unit u_cu (
        .clk     (sap_clk),
        .rst     (rst),
        .opcode  (opcode),
        .flags   (latched_flags),
        .MI(MI), .RO(RO), .RI(RI),
        .II(II), .IO(IO),
        .CO(CO), .CE(CE), .CL(CL),
        .AI(AI), .AO(AO),
        .ALO(ALO), .BI(BI), .OI(OI), .FE(FE),
        .HLT     (HLT_sig),
        .t_state (t_state)
    );

    // LEDs
    assign LED[15:8] = prog_mode ? sw_data      : out_val;
    assign LED[7]    = prog_mode ? sw_addr[3]   : latched_flags[1];
    assign LED[6]    = prog_mode ? sw_addr[2]   : latched_flags[0];
    assign LED[5]    = prog_mode ? sw_addr[1]   : t_state[2];
    assign LED[4]    = prog_mode ? sw_addr[0]   : t_state[1];
    assign LED[3]    = prog_mode ? WRITE_DONE   : t_state[0];
    assign LED[2]    = prog_mode ? 1'b1         : pc_val[2];
    assign LED[1]    = prog_mode ? 1'b1         : pc_val[1];
    assign LED[0]    = prog_mode ? 1'b1         : pc_val[0];

endmodule
