// =============================================================================
// SAP-1 RAM — 16 x 8 bits
// Matches diagram signals:
//   RI = RAM In  — write bus data into RAM[addr]  (programming mode)
//   RO = RAM Out — drive RAM[addr] onto bus        (normal fetch)
// Address comes from MAR (4-bit)
//
// Default program:
//   Addr | Data | Meaning
//   0x0  | 1E   | LDA 14      A  = RAM[14] = 28
//   0x1  | 2F   | ADD 15      A  = 28 + 14 = 42
//   0x2  | 3F   | SUB 15      A  = 42 - 14 = 28
//   0x3  | E0   | OUT         Output = 28
//   0x4  | F0   | HLT
//   0xE  | 1C   | data: 28
//   0xF  | 0E   | data: 14
// =============================================================================
/*module ram (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        RI,        // RAM In  — write (programming mode)
    input  wire        RO,        // RAM Out — read to bus
    input  wire [3:0]  addr,      // From MAR
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out
);

    reg [7:0] mem [0:15];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) mem[i] = 8'h00;
        // --- Program ---
        mem[4'h0] = 8'h1E;   // LDA 14      A = 28
        mem[4'h1] = 8'h2F;   // ADD 15      A = 28+14 = 42
        mem[4'h2] = 8'h3F;   // SUB 15      A = 42-14 = 28
        mem[4'h3] = 8'hE0;   // OUT
        mem[4'h4] = 8'hF0;   // HLT
        // --- Data ---
        mem[4'hE] = 8'h1C;   // 28
        mem[4'hF] = 8'h0E;   // 14
    end

    // Synchronous write (RI active)
    always @(posedge clk) begin
        if (RI) mem[addr] <= bus_in;
    end

    // Tri-state read to bus
    assign bus_out = RO ? mem[addr] : 8'bz;

endmodule*/


module ram(

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

endmodule
