module system_top (
    input  wire        CLK,
    input  wire        BTN0,
    input  wire        BTN1,
    input  wire        BTN2,
    input  wire        BTN3,
    input  wire [15:0] SW,
    output wire [3:0]  D0_AN,
    output wire [7:0]  D0_SEG,
    output wire [3:0]  D1_AN,
    output wire [7:0]  D1_SEG,
    output wire [15:0] LED);
    wire [3:0] MEM_ADDR;
    wire       MEM_RD;
    wire       MEM_WR;
    wire [7:0] MEM_DOUT;
    wire [7:0] MEM_DIN;
    wire       SAP_CLK;
    wire       WRITE_DONE;

    cpu_top u_cpu (
        .CLK        (CLK),
        .BTN0       (BTN0),
        .BTN1       (BTN1),
        .BTN3       (BTN3),
        .SW         (SW),
        .MEM_ADDR   (MEM_ADDR),
        .MEM_RD     (MEM_RD),
        .MEM_WR     (MEM_WR),
        .MEM_DOUT   (MEM_DOUT),
        .MEM_DIN    (MEM_DIN),
        .SAP_CLK    (SAP_CLK),
        .WRITE_DONE (WRITE_DONE),
        .D0_AN      (D0_AN),
        .D0_SEG     (D0_SEG),
        .D1_AN      (D1_AN),
        .D1_SEG     (D1_SEG),
        .LED        (LED));

    ram u_ram (
        .clk_100mhz (CLK),
        .rst        (BTN1),
        .MEM_ADDR   (MEM_ADDR),
        .MEM_RD     (MEM_RD),
        .MEM_WR     (MEM_WR),
        .MEM_DOUT   (MEM_DOUT),
        .MEM_DIN    (MEM_DIN),
        .sap_clk    (SAP_CLK),
        .prog_mode  (SW[14]),
        .sw_data    (SW[7:0]),
        .sw_addr    (SW[11:8]),
        .btn_write  (BTN2),
        .write_done (WRITE_DONE));
endmodule
