// -------------------------------------------------------
// Clock Module for SAP-1 Computer
// Boolean FPGA Board - 100 MHz input clock
//
// SW[1:0] selects the SAP clock speed:
//   00 = 1 Hz   (slow, easy to watch)
//   01 = 10 Hz
//   10 = 100 Hz
//   11 = 1 kHz  (fast, use for simulation)
//
// BTN0 = manual single step (one clock pulse per press)
// HLT  = stops the clock when control unit halts
// rst  = active HIGH reset (BTN1 on Boolean board)
// -------------------------------------------------------

module clock_module (
    input  wire        clk_100mhz,  // 100 MHz from board crystal
    input  wire        rst,         // reset, active HIGH
    input  wire [1:0]  speed_sel,   // SW[1:0] clock speed select
    input  wire        manual_step, // BTN0 single step
    input  wire        hlt,         // halt signal from control unit
    output reg         clk_out      // SAP system clock output
);

    // Number of 100MHz ticks for each half-period
    // formula: 100_000_000 / (2 * target_hz) - 1
    parameter CNT_1HZ   = 26'd49_999_999;  // gives 1 Hz
    parameter CNT_10HZ  = 26'd4_999_999;   // gives 10 Hz
    parameter CNT_100HZ = 26'd499_999;     // gives 100 Hz
    parameter CNT_1KHZ  = 26'd49_999;      // gives 1 kHz

    reg [25:0] counter;
    reg [25:0] max_count;
    reg        auto_clk;

    // Choose divider value based on switch setting
    always @(*) begin
        case (speed_sel)
            2'b00 : max_count = CNT_1HZ;
            2'b01 : max_count = CNT_10HZ;
            2'b10 : max_count = CNT_100HZ;
            2'b11 : max_count = CNT_1KHZ;
        endcase
    end

    // Clock divider - toggles auto_clk at selected speed
    always @(posedge clk_100mhz) begin
        if (rst) begin
            counter  <= 26'd0;
            auto_clk <= 1'b0;
        end
        else if (counter >= max_count) begin
            counter  <= 26'd0;
            auto_clk <= ~auto_clk;  // toggle to create clock
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    // Detect rising edge of manual step button
    // step_pulse goes high for exactly one 100MHz cycle
    reg  btn_prev;
    wire step_pulse = manual_step & ~btn_prev;

    always @(posedge clk_100mhz) begin
        if (rst) btn_prev <= 1'b0;
        else     btn_prev <= manual_step;
    end

    // Final clock output
    // If HLT is asserted the clock freezes (stays at last value)
    always @(posedge clk_100mhz) begin
        if (rst)
            clk_out <= 1'b0;
        else if (!hlt)
            clk_out <= auto_clk | step_pulse;
    end

endmodule
