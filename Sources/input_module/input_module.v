module input_module #(
    parameter DEBOUNCE_CYCLES = 2_000_000   // override from tb: #(.DEBOUNCE_CYCLES(100))
) (
    input  wire        clk_100mhz,
    input  wire        rst,
    input  wire        prog_mode,
    input  wire [3:0]  sw_addr,
    input  wire [7:0]  sw_data,
    input  wire        btn_write,
    output reg         prog_we,
    output reg  [3:0]  prog_addr,
    output reg  [7:0]  prog_data,
    output reg         write_done
);
    localparam CTR_BITS = 21;
    // ---------------------------------------------------
    // Stage 1 : Synchronizer
    // ---------------------------------------------------
    reg btn_s1;
    reg btn_s2;
    always @(posedge clk_100mhz)
    begin
        if(rst)
        begin
            btn_s1 <= 1'b0;
            btn_s2 <= 1'b0;
        end
        else
        begin
            btn_s1 <= btn_write;
            btn_s2 <= btn_s1;
        end
    end
    // ---------------------------------------------------
    // Stage 2 : Debounce
    // ---------------------------------------------------
    reg btn_stable;
    reg [CTR_BITS-1:0] deb_cnt;
    always @(posedge clk_100mhz)
    begin
        if(rst)
        begin
            btn_stable <= 1'b0;
            deb_cnt    <= 0;
        end
        else if(btn_s2 != btn_stable)
        begin
            if(deb_cnt >= DEBOUNCE_CYCLES - 1)
            begin
                btn_stable <= btn_s2;
                deb_cnt    <= 0;
            end
            else
                deb_cnt <= deb_cnt + 1'b1;
        end
        else
            deb_cnt <= 0;
    end
    // ---------------------------------------------------
    // Stage 3 : Rising Edge Detect
    // ---------------------------------------------------
    reg btn_prev;
    wire write_pulse;
    assign write_pulse = btn_stable & ~btn_prev & prog_mode;
    always @(posedge clk_100mhz)
    begin
        if(rst)
        begin
            btn_prev   <= 1'b0;
            prog_we    <= 1'b0;
            prog_addr  <= 4'b0000;
            prog_data  <= 8'b00000000;
            write_done <= 1'b0;
        end
        else
        begin
            btn_prev   <= btn_stable;
            write_done <= 1'b0;
            if(write_pulse)
            begin
                prog_we    <= 1'b1;
                prog_addr  <= sw_addr;
                prog_data  <= sw_data;
                write_done <= 1'b1;
            end
            else
            begin
                prog_we <= 1'b0;
            end
        end
    end
endmodule
