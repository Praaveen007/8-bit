module clock_module #(
    parameter SIM_MODE = 0    // Override to 1 from testbench via defparam
) (
    input  wire        clk_100mhz,
    input  wire        rst,
    input  wire [1:0]  speed_sel,
    input  wire        manual_step,
    input  wire        hlt,
    input  wire        prog_mode,
    output reg         clk_out
);

  
    wire [25:0] CNT_1HZ   = SIM_MODE ? 26'd1 : 26'd49_999_999;
    wire [25:0] CNT_10HZ  = SIM_MODE ? 26'd1 : 26'd4_999_999;
    wire [25:0] CNT_100HZ = SIM_MODE ? 26'd1 : 26'd499_999;
    wire [25:0] CNT_1KHZ  = SIM_MODE ? 26'd1 : 26'd49_999;

    reg [25:0] counter;
    reg [25:0] max_count;
    reg        auto_clk;

    always @(*) begin
        case (speed_sel)
            2'b00 : max_count = CNT_1HZ;
            2'b01 : max_count = CNT_10HZ;
            2'b10 : max_count = CNT_100HZ;
            2'b11 : max_count = CNT_1KHZ;
        endcase
    end

    // Frequency divider
    always @(posedge clk_100mhz) begin
        if (rst) begin
            counter  <= 26'd0;
            auto_clk <= 1'b0;
        end
        else if (counter >= max_count) begin
            counter  <= 26'd0;
            auto_clk <= ~auto_clk;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    
    reg  btn_prev;
    wire step_pulse = manual_step & ~btn_prev;

    always @(posedge clk_100mhz) begin
        if (rst) btn_prev <= 1'b0;
        else     btn_prev <= manual_step;
    end

 
    always @(posedge clk_100mhz) begin
        if (rst)
            clk_out <= 1'b0;
        else if (hlt || prog_mode)
            clk_out <= 1'b0;
        else
            clk_out <= auto_clk | step_pulse;
    end

endmodule
