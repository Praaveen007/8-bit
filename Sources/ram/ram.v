
module ram (

    input  wire        clk,         
    input  wire        clk_100mhz,   
    input  wire        rst,

  
    input  wire        RI,
    input  wire        RO,
    input  wire [3:0]  addr,
    input  wire [7:0]  bus_in,
    output wire [7:0]  bus_out,


    input  wire        prog_mode,
    input  wire        prog_we,
    input  wire [3:0]  prog_addr,
    input  wire [7:0]  prog_data

);

  
    reg [7:0] mem [0:15];

    integer i;

    initial begin

        for(i = 0; i < 16; i = i + 1)
            mem[i] = 8'h00;


        mem[4'h0] = 8'h1E;   
        mem[4'h1] = 8'h2F;  
        mem[4'h2] = 8'h3F;   
        mem[4'h3] = 8'hE0;   
        mem[4'h4] = 8'hF0;   
-

        mem[4'hE] = 8'h1C;  
        mem[4'hF] = 8'h0E;   

    end

   
    always @(posedge clk_100mhz)
    begin

        if(prog_mode && prog_we)
            mem[prog_addr] <= prog_data;

    end

    

    always @(posedge clk)
    begin

        if(RI && !prog_mode)
            mem[addr] <= bus_in;

    end


    assign bus_out = (RO) ? mem[addr] : 8'bz;

endmodule
