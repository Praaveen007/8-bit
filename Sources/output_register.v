// -------------------------------------------------------
// Output Register + 7-Segment Display Driver for SAP-1
//
// Latches the value from the bus and shows it in decimal
// on the Boolean board's 7-segment display (0 to 255).
//
// The display uses 3 digits: hundreds, tens, ones.
// Boolean board anodes are active LOW (0 = digit on).
// Segment cathodes are also active LOW (0 = segment on).
//
// We multiplex the 3 digits rapidly using clk_100mhz
// so all 3 appear lit at the same time to human eyes.
//
// Control signal:
//   OI  = Output In : latch bus value into output register
//   rst = active HIGH reset
// -------------------------------------------------------

module output_register (
    input  wire        clk,         // SAP system clock
    input  wire        clk_100mhz,  // fast clock for display refresh
    input  wire        rst,         // active HIGH reset
    input  wire        OI,          // Output In - load from bus
    input  wire [7:0]  bus_in,

    output reg  [7:0]  AN,          // 7-seg anode select (active LOW)
    output reg  [6:0]  SEG,         // 7-seg segments {g,f,e,d,c,b,a} (active LOW)
    output wire        DP,          // decimal point - always OFF
    output wire [7:0]  out_val      // raw value for LED debug
);

    reg [7:0] out_reg;

    always @(posedge clk) begin
        if (rst)      out_reg <= 8'b0000_0000; // clear display on reset
        else if (OI)  out_reg <= bus_in;         // latch bus value
    end

    assign out_val = out_reg;
    assign DP = 1'b1; // decimal point off (active low, so 1 = off)

    // split value into BCD digits
    wire [3:0] hundreds = out_reg / 100;
    wire [3:0] tens     = (out_reg % 100) / 10;
    wire [3:0] ones     = out_reg % 10;

    // 7-segment encoding, segments = {g, f, e, d, c, b, a}, active LOW
    // so 0 = segment ON, 1 = segment OFF
    function [6:0] bcd_to_seg;
        input [3:0] digit;
        case (digit)
            4'b0000 : bcd_to_seg = 7'b1000000; // 0
            4'b0001 : bcd_to_seg = 7'b1111001; // 1
            4'b0010 : bcd_to_seg = 7'b0100100; // 2
            4'b0011 : bcd_to_seg = 7'b0110000; // 3
            4'b0100 : bcd_to_seg = 7'b0011001; // 4
            4'b0101 : bcd_to_seg = 7'b0010010; // 5
            4'b0110 : bcd_to_seg = 7'b0000010; // 6
            4'b0111 : bcd_to_seg = 7'b1111000; // 7
            4'b1000 : bcd_to_seg = 7'b0000000; // 8
            4'b1001 : bcd_to_seg = 7'b0010000; // 9
            default : bcd_to_seg = 7'b1111111; // blank for invalid
        endcase
    endfunction

    // digit multiplex counter - cycles through 3 digits
    // at 100MHz, [16:15] toggles at about 1.5 kHz per digit
    reg [16:0] mux_cnt;
    always @(posedge clk_100mhz) begin
        if (rst) mux_cnt <= 17'd0;
        else     mux_cnt <= mux_cnt + 1'b1;
    end

    wire [1:0] sel = mux_cnt[16:15]; // which digit is active

    always @(*) begin
        AN  = 8'b1111_1111; // all digits off by default
        SEG = 7'b1111111;   // all segments off by default
        case (sel)
            2'b00 : begin AN = 8'b1111_1110; SEG = bcd_to_seg(ones);     end // rightmost digit
            2'b01 : begin AN = 8'b1111_1101; SEG = bcd_to_seg(tens);     end // middle digit
            2'b10 : begin AN = 8'b1111_1011; SEG = bcd_to_seg(hundreds); end // leftmost digit
            default: ; // 2'b11 : keep all off
        endcase
    end

endmodule
