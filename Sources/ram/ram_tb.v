`timescale 1ns/1ps

module ram_tb;

    reg         clk;
    reg         RI;
    reg         RO;
    reg  [3:0]  addr;
    reg  [7:0]  bus_in;

    wire [7:0]  bus_out;

    ram uut (
        .clk(clk),
        .RI(RI),
        .RO(RO),
        .addr(addr),
        .bus_in(bus_in),
        .bus_out(bus_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        RI     = 0;
        RO     = 0;
        addr   = 0;
        bus_in = 0;

        #10;

        RO   = 1;
        addr = 4'h0;
        #10;

        addr = 4'h1;
        #10;

        addr = 4'h2;
        #10;

        addr = 4'h3;
        #10;

        addr = 4'h4;
        #10;

        addr = 4'hE;
        #10;

        addr = 4'hF;
        #10;


        RO     = 0;
        RI     = 1;
        addr   = 4'h5;
        bus_in = 8'hAA;

        #10;   

        RI   = 0;
        RO   = 1;
        addr = 4'h5;

        #10;

      
        RO = 0;

        #10;

        $finish;

    end

    initial begin
        $monitor(
        "Time=%0t | RI=%b | RO=%b | ADDR=%h | BUS_IN=%h | BUS_OUT=%h",
        $time, RI, RO, addr, bus_in, bus_out);
    end

endmodule
