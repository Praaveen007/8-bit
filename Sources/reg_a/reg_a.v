
module a_register (
    input  wire        clk,
    input  wire        rst,     
    input  wire        AI,      
    input  wire        AO,      
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,
    output wire [7:0]  a_val   
);

    reg [7:0] a;

    always @(posedge clk) begin
        if (rst)      a <= 8'b0000_0000; 
        else if (AI)  a <= bus_in;     
    end

   
    assign bus_out = AO ? a : 8'bz;

   
    assign a_val = a;

endmodule
