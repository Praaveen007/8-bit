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

    // DUT - DEBOUNCE_CYCLES overridden to 100 for fast simulation.
    // This works regardless of file/compile order, unlike `define + `ifdef.
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

    // 100 MHz clock
    initial
        clk_100mhz = 0;
    always
        #5 clk_100mhz = ~clk_100mhz;

    initial begin
        // Initial values
        rst        = 1;
        prog_mode  = 0;
        sw_addr    = 4'd0;
        sw_data    = 8'd0;
        btn_write  = 0;

        // Reset
        #50;
        rst = 0;

        // Enter program mode
        #50;
        prog_mode = 1;

        // Address = 5
        // Data = 42
        sw_addr = 4'd5;
        sw_data = 8'd42;

        // Wait
        #50;

        // Hold button long enough to clear synchronizer (2 cycles)
        // + debounce (DEBOUNCE_CYCLES = 100 cycles, overridden above)
        btn_write = 1;
        // 200 clock cycles (200 x 10ns = 2000ns) - comfortably more than
        // the ~102 cycles needed for the button to register as stable
        #2000;
        btn_write = 0;

        // Wait to observe outputs
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
