// =============================================================================
// SAP-1 A Register (Accumulator)
// Matches diagram signals:
//   AI = A In  — latch from bus
//   AO = A Out — drive onto bus
// Also feeds ALU directly (a_val always visible)
// =============================================================================
module a_register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        AI,        // A In
    input  wire        AO,        // A Out
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,
    output wire [7:0]  a_val      // Always connected to ALU
);

    reg [7:0] a;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  a <= 8'h00;
        else if (AI) a <= bus_in;
    end

    assign bus_out = AO ? a : 8'bz;
    assign a_val   = a;

endmodule

// =============================================================================
// SAP-1 B Register
// Matches diagram signal:
//   BI = B In — latch from bus
// No B Out — B register feeds ALU only, never drives the bus
// =============================================================================
module b_register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        BI,        // B In
    input  wire [7:0]  bus_in,
    output wire [7:0]  b_val      // Always connected to ALU
);

    reg [7:0] b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  b <= 8'h00;
        else if (BI) b <= bus_in;
    end

    assign b_val = b;

endmodule
