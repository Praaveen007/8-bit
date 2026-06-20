`timescale 1ns/1ps

module flag_register_tb;

    reg clk;
    reg rst;
    reg FE;
    reg [1:0] flags_in;

    wire [1:0] flags_out;

   
    flag_register uut (
        .clk(clk),
        .rst(rst),
        .FE(FE),
        .flags_in(flags_in),
        .flags_out(flags_out)
    );

  
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

      
        rst      = 1'b1;
        FE       = 1'b0;
        flags_in = 2'b00;

       
        #20;
        rst = 1'b0;

        
        FE       = 1'b1;
        flags_in = 2'b10;
        #10;

        
        flags_in = 2'b01;
        #10;

        
        flags_in = 2'b11;
        #10;

      
        FE       = 1'b0;
        flags_in = 2'b00;
        #20;

        FE       = 1'b1;
        flags_in = 2'b00;
        #10;

        rst = 1'b1;
        #10;

        rst = 1'b0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "Time=%0t rst=%b FE=%b flags_in=%b flags_out=%b",
        $time, rst, FE, flags_in, flags_out);
    end

endmodule
