module program_counter (
    input  wire        clk,
    input  wire        rst,     
    input  wire        CO,      
    input  wire        CE,     
    input  wire        CL,      
    output wire [7:0]  bus_out, 
    output wire [3:0]  pc_val);

    reg [3:0] pc;

    always @(posedge clk) begin
        if (rst)       pc <= 4'b0000;  // reset PC to zero
        else if (CL)   pc <= 4'b0000;  // clear PC to zero
        else if (CE)   pc <= pc + 1'b1; // increment PC
        // if none of the above, PC holds its value
    end

    // PC only drives the bus when CO = 1 (tri-state otherwise)
    // upper nibble is always 0000 since PC is only 4 bits
    assign bus_out = CO ? {4'b0000, pc} : 8'bz;

    // always show PC value on debug output
    assign pc_val = pc;

endmodule
