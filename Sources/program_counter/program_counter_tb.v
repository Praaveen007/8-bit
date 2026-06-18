`timescale 1ns/1ps

module program_counter_tb;

    reg clk;
    reg rst;
    reg CO;
    reg CE;
    reg CL;

    wire [7:0] bus_out;
    wire [3:0] pc_val;

    program_counter uut (
        .clk(clk),
        .rst(rst),
        .CO(CO),
        .CE(CE),
        .CL(CL),
        .bus_out(bus_out),
        .pc_val(pc_val)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        rst = 1;
        CO  = 0;
        CE  = 0;
        CL  = 0;

        // Apply reset
        #10;
        rst = 0;

        // Count 5 times
        CE = 1;
        #50;

        // Stop counting
        CE = 0;
        #10;

        // Put PC onto bus
        CO = 1;
        #10;

        // Remove from bus
        CO = 0;
        #10;

        // Clear PC
        CL = 1;
        #10;
        CL = 0;

        // Show cleared PC on bus
        CO = 1;
        #10;

        // Count 3 more times
        CO = 0;
        CE = 1;
        #30;

        // Show PC on bus again
        CE = 0;
        CO = 1;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "Time=%0t | PC=%d | rst=%b | CE=%b | CL=%b | CO=%b | BUS=%h",
        $time, pc_val, rst, CE, CL, CO, bus_out);
    end

endmodule
