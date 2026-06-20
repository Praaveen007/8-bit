`timescale 1ns/1ps

module control_unit_tb;

    reg clk;
    reg rst;
    reg [3:0] opcode;
    reg [1:0] flags;

    wire MI,RO,RI,II,IO,CO,CE,CL;
    wire AI,AO,ALO,BI,OI,FE,HLT;
    wire [2:0] t_state;

    
    control_unit dut (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .flags(flags),

        .MI(MI),
        .RO(RO),
        .RI(RI),
        .II(II),
        .IO(IO),
        .CO(CO),
        .CE(CE),
        .CL(CL),
        .AI(AI),
        .AO(AO),
        .ALO(ALO),
        .BI(BI),
        .OI(OI),
        .FE(FE),
        .HLT(HLT),

        .t_state(t_state)
    );

   
    initial
        clk = 0;

    always #5 clk = ~clk;

   
    initial begin

        $display("Starting Control Unit Test");

        rst    = 1;
        opcode = 4'h0;
        flags  = 2'b00;

        #20;
        rst = 0;

       
        opcode = 4'h1;
        #70;

        opcode = 4'h2;
        #70;

      
        opcode = 4'h7;
        #70;

       
        opcode = 4'hE;
        #70;

       
        opcode = 4'hF;
        #70;

        $finish;

    end

   
    initial begin
        $monitor(
        "Time=%0t T=%0d OPCODE=%h MI=%b RO=%b II=%b IO=%b AI=%b BI=%b ALO=%b OI=%b FE=%b HLT=%b",
        $time,t_state,opcode,
        MI,RO,II,IO,AI,BI,ALO,OI,FE,HLT);
    end

endmodule
