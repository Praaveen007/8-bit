`timescale 1ns/1ps

module input_module_tb;
    reg clk_100mhz;
    reg rst;
    reg prog_mode;
    reg [3:0] sw_addr;
    reg [7:0] sw_data;
    reg btn_write;
    wire prog_we;
    wire [3:0] prog_addr;
    wire [7:0] prog_data;
    wire write_done;

    
    input_module #(
        .DEBOUNCE_CYCLES(100)
    ) dut (
        .clk_100mhz(clk_100mhz),
        .rst(rst),
        .prog_mode(prog_mode),
        .sw_addr(sw_addr),
        .sw_data(sw_data),
        .btn_write(btn_write),
        .prog_we(prog_we),
        .prog_addr(prog_addr),
        .prog_data(prog_data),
        .write_done(write_done)
    );

  
    initial
        clk_100mhz = 0;
    always
        #5 clk_100mhz = ~clk_100mhz;

    initial begin
     
        rst        = 1;
        prog_mode  = 0;
        sw_addr    = 4'd0;
        sw_data    = 8'd0;
        btn_write  = 0;

      
        #50;
        rst = 0;

      
        #50;
        prog_mode = 1;

       
        sw_addr = 4'd5;
        sw_data = 8'd42;

       
        #50;

        
        btn_write = 1;
       
        #2000;
        btn_write = 0;

      
        #3000;
        $finish;
    end

    initial begin
        $monitor(
            "T=%0t rst=%b btn=%b prog_we=%b addr=%d data=%d done=%b",
            $time,
            rst,
            btn_write,
            prog_we,
            prog_addr,
            prog_data,
            write_done
        );
    end
endmodule
