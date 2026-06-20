module instruction_register (
    input  wire        clk,
    input  wire        rst,
    input  wire        II,
    input  wire        IO,
    input  wire [7:0]  bus_in,
    output wire [3:0]  opcode,
    output wire [3:0]  operand,
    output wire [7:0]  ir_out);
    reg [7:0] ir;

    always @(posedge clk or posedge rst) begin
        if (rst)      ir <= 8'h00;
        else if (II)  ir <= bus_in;
    end

    assign opcode  = ir[7:4];
    assign operand = ir[3:0];
    assign ir_out  = ir;

endmodule
