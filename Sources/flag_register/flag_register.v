module flag_register(

    input wire clk,
    input wire rst,

    input wire FE,

    input wire [1:0] flags_in,

    output reg [1:0] flags_out

);

always @(posedge clk or posedge rst)
begin

    if(rst)
        flags_out <= 2'b00;

    else if(FE)
        flags_out <= flags_in;

end

endmodule
