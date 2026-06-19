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
