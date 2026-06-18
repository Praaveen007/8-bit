`timescale 1ns/1ps

module alu_tb;

    reg        ALO;
    reg  [3:0] alu_op;
    reg  [7:0] a_val;
    reg  [7:0] b_val;

    wire [7:0] bus_out;
    wire [1:0] flags;
    wire [7:0] alu_result;

    alu uut (
        .ALO(ALO),
        .alu_op(alu_op),
        .a_val(a_val),
        .b_val(b_val),
        .bus_out(bus_out),
        .flags(flags),
        .alu_result(alu_result)
    );

    initial begin

        ALO = 1'b1;

        alu_op = 4'b0010;
        a_val  = 8'd10;
        b_val  = 8'd5;
        #10;

        alu_op = 4'b0011;
        #10;

        alu_op = 4'b0100;
        a_val  = 8'hAA;
        b_val  = 8'h55;
        #10;

        alu_op = 4'b0101;
        #10;

        alu_op = 4'b0110;
        #10;

        alu_op = 4'b0111;
        a_val  = 8'h0F;
        #10;

        alu_op = 4'b1000;
        a_val  = 8'd15;
        #10;

        alu_op = 4'b1001;
        a_val  = 8'd15;
        #10;

        alu_op = 4'b1010;
        a_val  = 8'b10010110;
        #10;

        alu_op = 4'b1011;
        a_val  = 8'b10010110;
        #10;

        alu_op = 4'b1100;
        a_val  = 8'hAA;
        b_val  = 8'h55;
        #10;

        alu_op = 4'b1101;
        #10;

        alu_op = 4'b0011;
        a_val  = 8'd5;
        b_val  = 8'd5;
        #10;

        alu_op = 4'b0010;
        a_val  = 8'hFF;
        b_val  = 8'h01;
        #10;

        ALO = 1'b0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t | OP=%b | A=%h | B=%h | RESULT=%h | FLAGS=%b | BUS=%h",
         $time, alu_op, a_val, b_val,
         alu_result, flags, bus_out);
    end

endmodule
