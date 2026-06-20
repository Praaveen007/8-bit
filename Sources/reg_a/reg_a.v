module a_register (
    input  wire        clk,
    input  wire        rst,
    input  wire        AI,
    input  wire        AO,
    input  wire [7:0]  bus_in,
    output wire [7:0]  a_val
);
    reg [7:0] a;

    always @(posedge clk or posedge rst) begin
        if (rst)      a <= 8'h00;
        else if (AI)  a <= bus_in;
    end

    assign a_val = a;

endmodule
