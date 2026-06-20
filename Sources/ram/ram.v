module ram #(
    parameter SIM_MODE = 0
) (
    input  wire        clk_100mhz,
    input  wire        rst,

    input  wire [3:0]  MEM_ADDR,
    input  wire        MEM_RD,
    input  wire        MEM_WR,
    input  wire [7:0]  MEM_DOUT,
    output wire [7:0]  MEM_DIN,

    input  wire        sap_clk,

    input  wire        prog_mode,
    input  wire [7:0]  sw_data,
    input  wire [3:0]  sw_addr,
    input  wire        btn_write,

    output wire        write_done
);
    (* ram_style = "registers" *)
    reg [7:0] mem [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;

        mem[4'h0] = 8'h1D;  // LDA 13  A = 1
        mem[4'h1] = 8'hE0;  // OUT     â†’ 001
        mem[4'h2] = 8'h1E;  // LDA 14  A = 1
        mem[4'h3] = 8'hE0;  // OUT     â†’ 001
        mem[4'h4] = 8'h1F;  // LDA 15  A = 2
        mem[4'h5] = 8'hE0;  // OUT     â†’ 002
        mem[4'h6] = 8'h2E;  // ADD 14  A = 2+1 = 3
        mem[4'h7] = 8'hE0;  // OUT     â†’ 003
        mem[4'h8] = 8'h2F;  // ADD 15  A = 3+2 = 5
        mem[4'h9] = 8'hE0;  // OUT     â†’ 005
        mem[4'hA] = 8'hF0;  // HLT
        mem[4'hB] = 8'h00;
        mem[4'hC] = 8'h00;
        mem[4'hD] = 8'h01;  // F(1)=1
        mem[4'hE] = 8'h01;  // F(2)=1
        mem[4'hF] = 8'h02;  // F(3)=2
    end

    
    wire [20:0] DEBOUNCE_CYCLES = SIM_MODE ? 21'd100 : 21'd2_000_000;

    reg btn_s1, btn_s2;
    always @(posedge clk_100mhz) begin
        if (rst) begin btn_s1 <= 1'b0; btn_s2 <= 1'b0; end
        else     begin btn_s1 <= btn_write; btn_s2 <= btn_s1; end
    end

    reg        btn_stable;
    reg [20:0] deb_cnt;
    always @(posedge clk_100mhz) begin
        if (rst) begin btn_stable <= 1'b0; deb_cnt <= 0; end
        else if (btn_s2 != btn_stable) begin
            if (deb_cnt >= DEBOUNCE_CYCLES - 1) begin
                btn_stable <= btn_s2;
                deb_cnt    <= 0;
            end else
                deb_cnt <= deb_cnt + 1'b1;
        end else
            deb_cnt <= 0;
    end

    reg  btn_prev;
    wire write_pulse = btn_stable & ~btn_prev & prog_mode;

    reg  write_done_r;
    assign write_done = write_done_r;

    always @(posedge clk_100mhz) begin
        if (rst) begin
            btn_prev     <= 1'b0;
            write_done_r <= 1'b0;
        end else begin
            btn_prev     <= btn_stable;
            write_done_r <= 1'b0;
            if (write_pulse) begin
                mem[sw_addr] <= sw_data;
                write_done_r <= 1'b1;
            end
        end
    end

    // CPU write (SAP clock domain, RUN mode only)
    always @(posedge sap_clk) begin
        if (!rst && MEM_WR && !prog_mode)
            mem[MEM_ADDR] <= MEM_DOUT;
    end

    assign MEM_DIN = MEM_RD ? mem[MEM_ADDR] : 8'h00;

endmodule
