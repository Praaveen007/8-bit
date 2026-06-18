// =============================================================================
// SAP-1 Clock Module — Boolean FPGA Board
// 100 MHz onboard clock divided to selectable SAP speeds
// SW[1:0]: 00=1Hz  01=10Hz  10=100Hz  11=1kHz
// BTN0: manual single-step pulse
// HLT: freezes clock output
// =============================================================================
module clock_module (
    input  wire        clk_100mhz,
    input  wire        rst_n,
    input  wire [1:0]  speed_sel,
    input  wire        manual_step,
    input  wire        hlt,
    output reg         clk_out
);

    localparam CNT_1HZ   = 50_000_000 - 1;
    localparam CNT_10HZ  =  5_000_000 - 1;
    localparam CNT_100HZ =    500_000 - 1;
    localparam CNT_1KHZ  =     50_000 - 1;

    reg [25:0] counter;
    reg [25:0] max_count;
    reg        auto_clk;

    always @(*) begin
        case (speed_sel)
            2'b00: max_count = CNT_1HZ;
            2'b01: max_count = CNT_10HZ;
            2'b10: max_count = CNT_100HZ;
            2'b11: max_count = CNT_1KHZ;
        endcase
    end

    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter  <= 0;
            auto_clk <= 0;
        end else if (counter >= max_count) begin
            counter  <= 0;
            auto_clk <= ~auto_clk;
        end else begin
            counter <= counter + 1;
        end
    end

    // Edge detect for manual step button
    reg btn_prev;
    wire step_pulse = manual_step & ~btn_prev;
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) btn_prev <= 0;
        else        btn_prev <= manual_step;
    end

    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n)     clk_out <= 0;
        else if (!hlt)  clk_out <= auto_clk | step_pulse;
    end

endmodule
