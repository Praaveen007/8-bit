module mar (
    input  wire        clk,
    input  wire        rst,      // active HIGH asynchronous
    input  wire        MI,
    input  wire [7:0]  bus_in,
    output reg  [3:0]  addr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)       addr_out <= 4'b0000;
        else if (MI)   addr_out <= bus_in[3:0];
    end
endmodule
