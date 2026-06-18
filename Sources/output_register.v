// =============================================================================
// SAP-1 Output Register + 7-Segment BCD Display Driver
// Matches diagram signal:
//   OI = Output In — latch byte from bus
//
// Drives Boolean board 7-segment display (multiplexed, active-low anodes)
// Shows value 0–255 in decimal across 3 digits
// =============================================================================
module output_register (
    input  wire        clk,
    input  wire        clk_100mhz,   // Fast clock for display multiplexing
    input  wire        rst_n,
    input  wire        OI,           // Output In
    input  wire [7:0]  bus_in,

    // Boolean board 7-segment (active-low)
    output reg  [7:0]  AN,           // Anode selects
    output reg  [6:0]  SEG,          // Segment cathodes {g,f,e,d,c,b,a}
    output wire        DP,           // Decimal point — off

    output wire [7:0]  out_val       // Raw stored value (for LEDs/debug)
);

    reg [7:0] out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  out_reg <= 8'h00;
        else if (OI) out_reg <= bus_in;
    end

    assign out_val = out_reg;
    assign DP = 1'b1;  // Decimal point off

    // BCD decomposition
    wire [3:0] hundreds = out_reg / 100;
    wire [3:0] tens     = (out_reg % 100) / 10;
    wire [3:0] ones     = out_reg % 10;

    // 7-segment encoding {g,f,e,d,c,b,a} active-low
    function [6:0] bcd_to_seg;
        input [3:0] digit;
        case (digit)
            4'd0: bcd_to_seg = 7'b1000000;
            4'd1: bcd_to_seg = 7'b1111001;
            4'd2: bcd_to_seg = 7'b0100100;
            4'd3: bcd_to_seg = 7'b0110000;
            4'd4: bcd_to_seg = 7'b0011001;
            4'd5: bcd_to_seg = 7'b0010010;
            4'd6: bcd_to_seg = 7'b0000010;
            4'd7: bcd_to_seg = 7'b1111000;
            4'd8: bcd_to_seg = 7'b0000000;
            4'd9: bcd_to_seg = 7'b0010000;
            default: bcd_to_seg = 7'b1111111; // blank
        endcase
    endfunction

    // Multiplexing counter (~1.5 kHz refresh per digit at 100 MHz)
    reg [16:0] mux_cnt;
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) mux_cnt <= 0;
        else        mux_cnt <= mux_cnt + 1;
    end

    wire [1:0] sel = mux_cnt[16:15];

    always @(*) begin
        AN  = 8'b11111111;
        SEG = 7'b1111111;
        case (sel)
            2'd0: begin AN = 8'b11111110; SEG = bcd_to_seg(ones);     end
            2'd1: begin AN = 8'b11111101; SEG = bcd_to_seg(tens);     end
            2'd2: begin AN = 8'b11111011; SEG = bcd_to_seg(hundreds); end
            default:;
        endcase
    end

endmodule
