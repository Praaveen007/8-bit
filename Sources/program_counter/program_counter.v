module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        CO,
    input  wire        CL,
    input  wire        CE,
    input  wire [7:0]  bus_out,   
    output wire [3:0]  pc_val
);
    reg [3:0] pc = 4'd0;

    always @(posedge clk or posedge rst) begin
        if (rst)      pc <= 4'h0;
        else if (CL)  pc <= 4'h0;
        else if (CE)  pc <= pc + 4'd1;
    end

    assign pc_val = pc;
endmodule
