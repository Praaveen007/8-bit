module clock_module (
    input  wire        clk_100mhz,
    input  wire        rst,          
    input  wire [1:0]  speed_sel,
    input  wire        manual_step,
    input  wire        hlt,
    input  wire        prog_mode,
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

  
    reg btn_prev;

    wire step_pulse;

    assign step_pulse = manual_step & ~btn_prev;

    always @(posedge clk_100mhz) begin

        if (rst)
            btn_prev <= 1'b0;

        else
            btn_prev <= manual_step;

    end

 
    wire clock_frozen;

    assign clock_frozen = hlt | prog_mode;

    always @(posedge clk_100mhz) begin

        if (rst)
            clk_out <= 1'b0;

        else if (!clock_frozen)
            clk_out <= auto_clk | step_pulse;

    end

endmodule
