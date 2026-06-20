
`timescale 1ns/1ps

module b_register_tb;

    reg        clk;
    reg        rst;
    reg        BI;
    reg [7:0]  bus_in;

    wire [7:0] b_val;

   
    b_register uut (
        .clk(clk),
        .rst(rst),
        .BI(BI),
        .bus_in(bus_in),
        .b_val(b_val)
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

     
        rst    = 1;
        BI     = 0;
        bus_in = 8'h00;

        #10;
        rst = 0;

        BI     = 1;
        bus_in = 8'd28;
        #10;

        BI = 0;
        #10;

      
        BI     = 1;
        bus_in = 8'd14;   
        #10;

        BI = 0;
        #10;

        
        BI     = 1;
        bus_in = 8'd255; 
        #10;

        BI = 0;
        #10;

        bus_in = 8'd99;
        #10;

        rst = 1;
        #10;

        rst = 0;
        #10;

        $finish;

    end

    initial begin
        $monitor(
        "T=%0t rst=%b BI=%b bus_in=%h b_val=%h",
        $time, rst, BI, bus_in, b_val
        );
    end

endmodule
