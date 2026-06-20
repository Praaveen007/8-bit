`timescale 1ns/1ps

module output_register_tb;

    reg        clk;
    reg        clk_100mhz;
    reg        rst;
    reg        OI;
    reg [7:0]  bus_in;

    wire [7:0] AN;
    wire [6:0] SEG;
    wire       DP;
    wire [7:0] out_val;

    
    output_register uut (
        .clk(clk),
        .clk_100mhz(clk_100mhz),
        .rst(rst),
        .OI(OI),
        .bus_in(bus_in),
        .AN(AN),
        .SEG(SEG),
        .DP(DP),
        .out_val(out_val)
    );

    // SAP clock (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

   
    initial begin
        clk_100mhz = 0;
        forever #1 clk_100mhz = ~clk_100mhz;
    end

    initial begin

       
        rst    = 1;
        OI     = 0;
        bus_in = 8'd0;

       
        #20;
        rst = 0;

       
        OI     = 1;
        bus_in = 8'd28;
        #10;
        OI     = 0;

        #50;

        
        OI     = 1;
        bus_in = 8'd14;
        #10;
        OI     = 0;

        #50;

        
        OI     = 1;
        bus_in = 8'd255;
        #10;
        OI     = 0;

        #100;

        
        rst = 1;
        #20;

        rst = 0;
        #50;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t rst=%b OI=%b bus_in=%d out_val=%d AN=%b SEG=%b",
        $time, rst, OI, bus_in, out_val, AN, SEG);
    end

endmodule
