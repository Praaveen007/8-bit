module alu(

input        ALO,
input  [3:0] alu_op,
input  [7:0] a_val,
input  [7:0] b_val,

output [7:0] bus_out,
output reg [1:0] flags,
output reg [7:0] alu_result
```

);

reg carry;

always @(*) begin

```
alu_result = 8'b00000000;
carry      = 1'b0;

case(alu_op)

    4'b0010: begin   // ADD
        {carry, alu_result} = a_val + b_val;
    end

    4'b0011: begin   // SUB
        {carry, alu_result} = a_val - b_val;
    end

    4'b0100: begin   // AND
        alu_result = a_val & b_val;
    end

    4'b0101: begin   // XOR
        alu_result = a_val ^ b_val;
    end

    4'b0110: begin   // OR
        alu_result = a_val | b_val;
    end

    4'b0111: begin   // CMA (NOT A)
        alu_result = ~a_val;
    end

    4'b1000: begin   // INR
        {carry, alu_result} = a_val + 1;
    end

    4'b1001: begin   // DCR
        {carry, alu_result} = a_val - 1;
    end

    4'b1010: begin   // SHL
        carry      = a_val[7];
        alu_result = a_val << 1;
    end

    4'b1011: begin   // SHR
        carry      = a_val[0];
        alu_result = a_val >> 1;
    end

    4'b1100: begin   // NAND
        alu_result = ~(a_val & b_val);
    end

    4'b1101: begin   // NOR
        alu_result = ~(a_val | b_val);
    end

    default: begin
        alu_result = 8'b00000000;
        carry      = 1'b0;
    end

endcase

flags[1] = carry;

if(alu_result == 8'b00000000)
    flags[0] = 1'b1;
else
    flags[0] = 1'b0;
```

end

assign bus_out = (ALO) ? alu_result : 8'bz;

endmodule
