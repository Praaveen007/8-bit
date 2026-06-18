// =============================================================================
// SAP-1 Flag Register — 2 bits
// Matches diagram:
//   FE = Flag Enable — latch flags from ALU on clock edge
//   flag_out[1] = Carry flag (C)
//   flag_out[0] = Zero  flag (Z)
//
// Flags are latched (not combinational) so they remain stable
// between ALU operations and can be read by the control unit
// for conditional instructions (JZ, JC) in extended SAP designs.
// =============================================================================
/*module flag_register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        FE,            // Flag Enable — latch from ALU
    input  wire [1:0]  flags_in,      // {carry, zero} from ALU
    output reg  [1:0]  flags_out      // Latched flags to Control Unit
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  flags_out <= 2'b00;
        else if (FE) flags_out <= flags_in;
    end

endmodule*/

// ---------------------------------------------------
// Flag Register
//
// flags_out[1] = Carry Flag
// flags_out[0] = Zero Flag
//
// Flags are updated only when FE = 1
// Reset is ACTIVE HIGH
// ---------------------------------------------------

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
