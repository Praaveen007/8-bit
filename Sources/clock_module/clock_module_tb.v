`timescale 1ns/1ps

module clock_module_tb;

    reg clk_100mhz;
    reg rst;
    reg [1:0] speed_sel;
    reg manual_step;
    reg hlt;

    wire clk_out;

    // DUT
    clock_module uut (
        .clk_100mhz(clk_100mhz),
        .rst(rst),
        .speed_sel(speed_sel),
        .manual_step(manual_step),
        .hlt(hlt),
        .clk_out(clk_out)
    );

    // 100 MHz clock (10 ns period)
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end

    initial begin

        // Initialize
        rst         = 1'b1;
        speed_sel   = 2'b11; // 1 kHz mode (fastest)
        manual_step = 1'b0;
        hlt         = 1'b0;

        // Hold reset
        #100;
        rst = 1'b0;

        // Run long enough to see clock divider output
        #1200000;  // 1.2 ms

        // Manual step test
        manual_step = 1'b1;
        #20;
        manual_step = 1'b0;

        #100000;

        // Halt test
        hlt = 1'b1;
        #500000;

        // Resume
        hlt = 1'b0;
        #500000;

        $finish;

    end

    initial begin
        $monitor(
        "Time=%0t rst=%b speed=%b step=%b hlt=%b clk_out=%b",
        $time, rst, speed_sel, manual_step, hlt, clk_out);
    end

endmodulehgygu
