`timescale 1ns / 1ps

module tb_system;

    // ── Port declarations 
    reg         CLK;
    reg         BTN0, BTN1, BTN2, BTN3;
    reg  [15:0] SW;

    wire [3:0]  D0_AN;
    wire [7:0]  D0_SEG;
    wire [3:0]  D1_AN;
    wire [7:0]  D1_SEG;
    wire [15:0] LED;

    // ── DUT 
    system_top dut (
        .CLK    (CLK),
        .BTN0   (BTN0), .BTN1 (BTN1),
        .BTN2   (BTN2), .BTN3 (BTN3),
        .SW     (SW),
        .D0_AN  (D0_AN), .D0_SEG (D0_SEG),
        .D1_AN  (D1_AN), .D1_SEG (D1_SEG),
        .LED    (LED)
    );

    // ── CRITICAL: Force SIM_MODE=1 in both clock_module and ram ─────────────
    // defparam works at elaboration time — bypasses `define propagation problem.
    defparam dut.u_cpu.u_clk.SIM_MODE = 1;  // tiny clock dividers
    defparam dut.u_ram.SIM_MODE        = 1;  // short debounce (100 cycles)

   
    initial CLK = 0;
    always  #5 CLK = ~CLK;

    // ── Internal signal taps (correct hierarchy: dut.u_cpu.*) ───────────────
    wire [3:0] w_pc      = dut.u_cpu.pc_val;
    wire [7:0] w_ir      = dut.u_cpu.ir;         // from u_ir.ir_out
    wire [3:0] w_opcode  = dut.u_cpu.opcode;
    wire [3:0] w_operand = dut.u_cpu.operand;
    wire [7:0] w_a       = dut.u_cpu.a_val;
    wire [7:0] w_b       = dut.u_cpu.b_val;
    wire [7:0] w_out     = dut.u_cpu.out_val;
    wire [2:0] w_tstate  = dut.u_cpu.t_state;
    wire [3:0] w_mar     = dut.u_cpu.mar_addr;
    wire       w_hlt     = dut.u_cpu.HLT_sig;
    wire [1:0] w_flags   = dut.u_cpu.latched_flags;
    wire       w_sclk    = dut.u_cpu.sap_clk;
    wire [7:0] w_bus     = dut.u_cpu.bus_reg;

    // ── $monitor — trace every change ───────────────────────────────────────
    initial begin
        $monitor("t=%0t | sclk=%b T=%0d PC=%0h MAR=%0h IR=%02h | A=%0d B=%0d OUT=%0d | CF=%b ZF=%b HLT=%b BUS=%02h",
            $time, w_sclk, w_tstate,
            w_pc, w_mar, w_ir,
            w_a, w_b, w_out,
            w_flags[1], w_flags[0], w_hlt, w_bus);
    end

    // ── Stimulus ──────────────────────────────────────────────────────────────
    integer k;
    initial begin
        // Initialise
        BTN0 = 0; BTN1 = 0; BTN2 = 0; BTN3 = 0;
        SW   = 16'h0000;

        // SW[13:12] = 11 → fastest clock (CNT_1KHZ, = 1 in SIM_MODE)
        // SW[14]    = 0  → RUN mode (MUST stay 0 during CPU execution!)
        SW[13:12] = 2'b11;
        SW[14]    = 1'b0;

        // ── RESET (BTN1 = active HIGH) ───────────────────────────────────────
        $display("\n=== RESET ===");
        repeat(5)  @(posedge CLK); #1;
        BTN1 = 1;
        repeat(50) @(posedge CLK); #1;
        BTN1 = 0;
        repeat(10) @(posedge CLK); #1;
        $display("Reset released at t=%0t", $time);

        // ── RAM PRELOAD VERIFY ───────────────────────────────────────────────
        $display("\n=== RAM PRELOAD CHECK ===");
        $display("mem[0x0] = %02h  %s  (expect 1D LDA 13)",
            dut.u_ram.mem[4'h0], (dut.u_ram.mem[4'h0]==8'h1D) ? "PASS":"FAIL");
        $display("mem[0x1] = %02h  %s  (expect E0 OUT)",
            dut.u_ram.mem[4'h1], (dut.u_ram.mem[4'h1]==8'hE0) ? "PASS":"FAIL");
        $display("mem[0x6] = %02h  %s  (expect 2E ADD 14)",
            dut.u_ram.mem[4'h6], (dut.u_ram.mem[4'h6]==8'h2E) ? "PASS":"FAIL");
        $display("mem[0xA] = %02h  %s  (expect F0 HLT)",
            dut.u_ram.mem[4'hA], (dut.u_ram.mem[4'hA]==8'hF0) ? "PASS":"FAIL");
        $display("mem[0xD] = %02h  %s  (expect 01 F1)",
            dut.u_ram.mem[4'hD], (dut.u_ram.mem[4'hD]==8'h01) ? "PASS":"FAIL");
        $display("mem[0xE] = %02h  %s  (expect 01 F2)",
            dut.u_ram.mem[4'hE], (dut.u_ram.mem[4'hE]==8'h01) ? "PASS":"FAIL");
        $display("mem[0xF] = %02h  %s  (expect 02 F3)",
            dut.u_ram.mem[4'hF], (dut.u_ram.mem[4'hF]==8'h02) ? "PASS":"FAIL");

        // ── RUN CPU ───────────────────────────────────────────────────────────
        $display("\n=== CPU RUNNING ===");
        $display("(watch $monitor output above for each T-state)");

        // Poll for HLT or run 10000 cycles
        for (k = 0; k < 10000; k = k + 1) begin
            @(posedge CLK); #1;
            if (w_hlt) begin
                $display("HLT detected at t=%0t after %0d CLK cycles", $time, k);
                k = 10001; // break
            end
        end

        repeat(20) @(posedge CLK); #1;  // settle

        // ── RESULTS ───────────────────────────────────────────────────────────
        $display("\n=== RESULTS ===");
        $display("sap_clk = %b", w_sclk);
        $display("PC      = %0d", w_pc);
        $display("T-state = %0d", w_tstate);
        $display("A reg   = %0d (0x%02h)", w_a, w_a);
        $display("OUT reg = %0d (0x%02h)", w_out, w_out);
        $display("HLT     = %b",  w_hlt);
        $display("Carry   = %b  Zero = %b", w_flags[1], w_flags[0]);
        $display("LED     = %04h (should have no X bits)", LED);

        if (w_out == 8'd5)
            $display("FIBONACCI PASS — OUT=5 (correct final value)");
        else
            $display("FIBONACCI FAIL — OUT=%0d (expected 5)", w_out);

        // ── PROGRAM MODE WRITE TEST ───────────────────────────────────────────
        $display("\n=== PROGRAM MODE WRITE TEST ===");
        BTN1 = 1;
        repeat(50) @(posedge CLK); #1;
        BTN1 = 0;
        repeat(10) @(posedge CLK); #1;

        SW[14]   = 1'b1;   // PROGRAM mode
        SW[11:8] = 4'hD;   // address 13
        SW[7:0]  = 8'hAB;  // test data
        repeat(10) @(posedge CLK); #1;

        BTN2 = 1;
        repeat(200) @(posedge CLK); #1;
        BTN2 = 0;
        repeat(50) @(posedge CLK); #1;

        $display("RAM[13] after write = %02h  %s  (expected AB)",
            dut.u_ram.mem[4'hD],
            (dut.u_ram.mem[4'hD] == 8'hAB) ? "PASS" : "FAIL");

        $display("\n=== SIMULATION COMPLETE ===");
        #20000000;
        $finish;
       
    end

endmodule
