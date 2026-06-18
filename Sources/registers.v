// -------------------------------------------------------
// A Register (Accumulator) for SAP-1
//
// The A register is the main working register.
// All ALU results are stored back here.
// It can both receive from and drive the shared bus.
//
// Control signals:
//   AI = A In  : latch bus value into A register
//   AO = A Out : put A register value onto bus
//   rst = active HIGH reset
// -------------------------------------------------------

module a_register (
    input  wire        clk,
    input  wire        rst,     // active HIGH reset
    input  wire        AI,      // A In  - load A from bus
    input  wire        AO,      // A Out - drive A onto bus
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,
    output wire [7:0]  a_val    // direct connection to ALU (always on)
);

    reg [7:0] a;

    always @(posedge clk) begin
        if (rst)      a <= 8'b0000_0000; // clear accumulator on reset
        else if (AI)  a <= bus_in;        // load new value from bus
    end

    // drive bus only when AO = 1
    assign bus_out = AO ? a : 8'bz;

    // always feed current A value to ALU
    assign a_val = a;

endmodule


// -------------------------------------------------------
// B Register for SAP-1
//
// The B register holds the second operand for the ALU.
// It is loaded from the bus but CANNOT drive the bus.
// It only feeds the ALU directly.
//
// Control signal:
//   BI = B In : latch bus value into B register
//   rst = active HIGH reset
// -------------------------------------------------------

module b_register (
    input  wire        clk,
    input  wire        rst,     // active HIGH reset
    input  wire        BI,      // B In - load B from bus
    input  wire [7:0]  bus_in,
    output wire [7:0]  b_val    // direct connection to ALU (always on)
);

    reg [7:0] b;

    always @(posedge clk) begin
        if (rst)      b <= 8'b0000_0000; // clear B register on reset
        else if (BI)  b <= bus_in;        // load new value from bus
    end

    // always feed current B value to ALU (no bus drive for B)
    assign b_val = b;

endmodule
