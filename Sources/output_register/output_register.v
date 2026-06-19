
module output_register (
    input  wire        clk,         
    input  wire        clk_100mhz,  
    input  wire        rst,        
    input  wire        OI,         
    input  wire [7:0]  bus_in,

    output reg  [7:0]  AN,          
    output reg  [6:0]  SEG,         
    output wire        DP,          
    output wire [7:0]  out_val     
);

    reg [7:0] out_reg;

    always @(posedge clk) begin
        if (rst)      out_reg <= 8'b0000_0000; 
        else if (OI)  out_reg <= bus_in;         
    end

    assign out_val = out_reg;
    assign DP = 1'b1; 

  
    wire [3:0] hundreds = out_reg / 100;
    wire [3:0] tens     = (out_reg % 100) / 10;
    wire [3:0] ones     = out_reg % 10;

    
    function [6:0] bcd_to_seg;
        input [3:0] digit;
        case (digit)
            4'b0000 : bcd_to_seg = 7'b1000000;
            4'b0001 : bcd_to_seg = 7'b1111001; 
            4'b0010 : bcd_to_seg = 7'b0100100; 
            4'b0011 : bcd_to_seg = 7'b0110000; 
            4'b0100 : bcd_to_seg = 7'b0011001; 
            4'b0101 : bcd_to_seg = 7'b0010010; 
            4'b0110 : bcd_to_seg = 7'b0000010; 
            4'b0111 : bcd_to_seg = 7'b1111000; 
            4'b1000 : bcd_to_seg = 7'b0000000; 
            4'b1001 : bcd_to_seg = 7'b0010000; 
            default : bcd_to_seg = 7'b1111111; 
        endcase
    endfunction

    
    reg [16:0] mux_cnt;
    always @(posedge clk_100mhz) begin
        if (rst) mux_cnt <= 17'd0;
        else     mux_cnt <= mux_cnt + 1'b1;
    end

    wire [1:0] sel = mux_cnt[16:15]; 

    always @(*) begin
        AN  = 8'b1111_1111; 
        SEG = 7'b1111111;  
        case (sel)
            2'b00 : begin AN = 8'b1111_1110; SEG = bcd_to_seg(ones);     end
            2'b01 : begin AN = 8'b1111_1101; SEG = bcd_to_seg(tens);     end 
            2'b10 : begin AN = 8'b1111_1011; SEG = bcd_to_seg(hundreds); end 
            default: ; 
        endcase
    end

endmodule
