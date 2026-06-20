`timescale 1ns/1ps

module a_register_tb;

    reg        clk;
    reg        rst;
    reg        AI;
    reg        AO;
    reg [7:0]  bus_in;

    wire [7:0] bus_out;
    wire [7:0] a_val;

   
    a_register uut (
        .clk(clk),
        .rst(rst),
        .AI(AI),
        .AO(AO),
        .bus_in(bus_in),
        .bus_out(bus_out),
        .a_val(a_val)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

     
        rst    = 1;
        AI     = 0;
        AO     = 0;
        bus_in = 8'h00;

     
        #10;
        rst = 0;

       
        AI     = 1;
        bus_in = 8'd28;
        #10;

        AI = 0;
        #10;

       
        AO = 1;
        #10;

        AO = 0;
        #10;

        AI     = 1;
        bus_in = 8'd14;
        #10;

        AI = 0;
        #10;

       
        AO = 1;
        #10;

        AO = 0;
        #10;

       
        AI     = 1;
        bus_in = 8'd255;
        #10;

        AI = 0;
        #10;

     
        AO = 1;
        #10;

        AO = 0;
        #10;

        
        rst = 1;
        #10;

        rst = 0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t rst=%b AI=%b AO=%b bus_in=%h a_val=%h bus_out=%h",
        $time, rst, AI, AO, bus_in, a_val, bus_out
        );
    end

endmodule
