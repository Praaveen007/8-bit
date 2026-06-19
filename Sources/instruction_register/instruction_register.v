module instruction_register (
    input  wire        clk,
    input  wire        rst,      
    input  wire        II,      
    input  wire        IO,       
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,  
    output wire [3:0]  opcode,   
    output wire [3:0]  operand   
);

    reg [7:0] ir;

    always @(posedge clk) begin
        if (rst)      ir <= 8'b0000_0000; 
        else if (II)  ir <= bus_in;       
    end

  
    assign opcode = ir[7:4];

   
    assign operand = ir[3:0];

    
    assign bus_out = IO ? {4'b0000, ir[3:0]} : 8'bz;

endmodule
