`timescale 1ns/1ps

module instruction_register_tb;

    reg         clk;
    reg         rst;
    reg         II;
    reg         IO;
    reg  [7:0]  bus_in;

    wire [7:0]  bus_out;
    wire [3:0]  opcode;
    wire [3:0]  operand;

   
    instruction_register uut (
        .clk(clk),
        .rst(rst),
        .II(II),
        .IO(IO),
        .bus_in(bus_in),
        .bus_out(bus_out),
        .opcode(opcode),
        .operand(operand)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        rst    = 1'b1;
        II     = 1'b0;
        IO     = 1'b0;
        bus_in = 8'h00;

     
        #20;
        rst = 1'b0;

        
        II     = 1'b1;
        bus_in = 8'b0001_1110;
        #10;

        II = 1'b0;
        #10;

        IO = 1'b1;
        #10;

        IO = 1'b0;
        #10;

        II     = 1'b1;
        bus_in = 8'b0010_1111;
        #10;

        II = 1'b0;
        #10;

        IO = 1'b1;
        #10;

        IO = 1'b0;
        #10;

        
        II     = 1'b1;
        bus_in = 8'b1110_0000;
        #10;

        II = 1'b0;
        #10;

        IO = 1'b1;
        #10;

        IO = 1'b0;
        #10;

        rst = 1'b1;
        #10;

        rst = 1'b0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t rst=%b II=%b IO=%b bus_in=%h opcode=%h operand=%h bus_out=%h",
        $time, rst, II, IO, bus_in, opcode, operand, bus_out);
    end

endmodule
