module alu (
    input        ALO,
    input  [3:0] alu_op,
    input  [7:0] a_val,
    input  [7:0] b_val,
    output reg [1:0] flags,
    output reg [7:0] alu_result
);

    reg carry;

    always @(*) begin
        alu_result = 8'h00;
        carry      = 1'b0;

        case (alu_op)
            4'h2: {carry, alu_result} = a_val + b_val;          // ADD
            4'h3: {carry, alu_result} = a_val - b_val;          // SUB
            4'h4: alu_result = a_val & b_val;                   // ANA
            4'h5: alu_result = a_val ^ b_val;                   // XRA
            4'h6: alu_result = a_val | b_val;                   // ORA
            4'h7: alu_result = ~a_val;                          // CMA
            4'h8: {carry, alu_result} = a_val + 8'd1;           // INR
            4'h9: {carry, alu_result} = a_val - 8'd1;           // DCR
            4'hA: begin carry = a_val[7]; alu_result = a_val << 1; end // SHL
            4'hB: begin carry = a_val[0]; alu_result = a_val >> 1; end // SHR
            4'hC: alu_result = ~(a_val & b_val);                // NAND
            4'hD: alu_result = ~(a_val | b_val);                // NOR
            default: begin alu_result = 8'h00; carry = 1'b0; end
        endcase

        flags[1] = carry;
        flags[0] = (alu_result == 8'h00) ? 1'b1 : 1'b0;
    end

endmodule
