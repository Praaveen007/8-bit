/*module ram(

    input wire clk,
    input wire RI,          // RAM Write Enable
    input wire RO,          // RAM Read Enable

    input wire [3:0] addr,  // Address from MAR
    input wire [7:0] bus_in,

    output wire [7:0] bus_out

);

    // 16 locations, each 8 bits
    reg [7:0] mem [0:15];

    // Load program and data from external file
    initial begin
        $readmemh("program.mem", mem);
    end

    // Write operation
    always @(posedge clk) begin

        if(RI)
            mem[addr] <= bus_in;

    end

    // Read operation
    assign bus_out = (RO) ? mem[addr] : 8'bz;

endmodule*/
module ram (

    input  wire        clk,          // SAP clock
    input  wire        clk_100mhz,   // Programming clock
    input  wire        rst,

    // -----------------------------
    // CPU Access
    // -----------------------------
    input  wire        RI,
    input  wire        RO,
    input  wire [3:0]  addr,
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,

    // -----------------------------
    // Programming Access
    // -----------------------------
    input  wire        prog_mode,
    input  wire        prog_we,
    input  wire [3:0]  prog_addr,
    input  wire [7:0]  prog_data

);

    // ---------------------------------------
    // Memory Array
    // ---------------------------------------

    reg [7:0] mem [0:15];

    integer i;

    initial begin

        for(i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;

        // -----------------------------------
        // Default Demo Program
        // -----------------------------------

        mem[4'h0] = 8'h1E;   // LDA 14
        mem[4'h1] = 8'h2F;   // ADD 15
        mem[4'h2] = 8'h3F;   // SUB 15
        mem[4'h3] = 8'hE0;   // OUT
        mem[4'h4] = 8'hF0;   // HLT

        // -----------------------------------
        // Data
        // -----------------------------------

        mem[4'hE] = 8'h1C;   // 28
        mem[4'hF] = 8'h0E;   // 14

    end

    // ---------------------------------------
    // PROGRAM MODE WRITE
    // ---------------------------------------

    always @(posedge clk_100mhz)
    begin

        if(prog_mode && prog_we)
            mem[prog_addr] <= prog_data;

    end

    // ---------------------------------------
    // CPU WRITE
    // ---------------------------------------

    always @(posedge clk)
    begin

        if(RI && !prog_mode)
            mem[addr] <= bus_in;

    end

    // ---------------------------------------
    // CPU READ
    // ---------------------------------------

    assign bus_out = (RO) ? mem[addr] : 8'bz;

endmodule
