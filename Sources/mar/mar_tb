`timescale 1ns/1ps

module mar_tb;

    reg        clk;
    reg        rst;
    reg        MI;
    reg [7:0]  bus_in;

    wire [3:0] addr_out;

    
    mar uut (
        .clk(clk),
        .rst(rst),
        .MI(MI),
        .bus_in(bus_in),
        .addr_out(addr_out)
    );

   
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        
        rst    = 1;
        MI     = 0;
        bus_in = 8'h00;

       
        #10;
        rst = 0;

        MI     = 1;
        bus_in = 8'h1E;   // 0001_1110
        #10;

        
        bus_in = 8'h2F;   // 0010_1111
        #10;

       
        bus_in = 8'h05;   // 0000_0101
        #10;

       
        MI     = 0;
        bus_in = 8'h0A;
        #10;

        rst = 1;
        #10;

        rst = 0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t rst=%b MI=%b bus_in=%h addr_out=%h",
        $time, rst, MI, bus_in, addr_out);
    end

endmodule
