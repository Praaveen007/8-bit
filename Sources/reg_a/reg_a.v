
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
