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
        if (rst)       pc <= 4'b0000;  
        else if (CL)   pc <= 4'b0000; 
        else if (CE)   pc <= pc + 1'b1; 
        
    end

    
    assign bus_out = CO ? {4'b0000, pc} : 8'bz;

   
    assign pc_val = pc;

endmodule
