module b_register (
    input  wire        clk,
    input  wire        rst,     
    input  wire        BI,      
    input  wire [7:0]  bus_in,
    output wire [7:0]  b_val    
);

    reg [7:0] b;

    always @(posedge clk) begin
        if (rst)      b <= 8'b0000_0000; 
        else if (BI)  b <= bus_in;        
    end

   
    assign b_val = b;

endmodule
