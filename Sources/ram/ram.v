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
