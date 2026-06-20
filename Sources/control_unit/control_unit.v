module control_unit (
    input  wire        clk,
    input  wire        rst,        
    input  wire [3:0]  opcode,
    input  wire [1:0]  flags,      

    output reg         MI,
    output reg         RO,
    output reg         RI,
    output reg         II,
    output reg         IO,
    output reg         CO,
    output reg         CE,
    output reg         CL,
    output reg         AI,
    output reg         AO,
    output reg         ALO,
    output reg         BI,
    output reg         OI,
    output reg         FE,
    output reg         HLT,

    output wire [2:0]  t_state
);

     
    parameter OP_NOP  = 4'h0;
    parameter OP_LDA  = 4'h1;
    parameter OP_ADD  = 4'h2;
    parameter OP_SUB  = 4'h3;
    parameter OP_ANA  = 4'h4;
    parameter OP_XRA  = 4'h5;
    parameter OP_ORA  = 4'h6;
    parameter OP_CMA  = 4'h7;
    parameter OP_INR  = 4'h8;
    parameter OP_DCR  = 4'h9;
    parameter OP_SHL  = 4'hA;
    parameter OP_SHR  = 4'hB;
    parameter OP_NAND = 4'hC;
    parameter OP_NOR  = 4'hD;
    parameter OP_OUT  = 4'hE;
    parameter OP_HLT  = 4'hF;

   
    wire is_binary = (opcode == OP_ADD)  || (opcode == OP_SUB)  ||
                     (opcode == OP_ANA)  || (opcode == OP_XRA)  ||
                     (opcode == OP_ORA)  || (opcode == OP_NAND) ||
                     (opcode == OP_NOR);

     
    wire is_unary  = (opcode == OP_CMA)  || (opcode == OP_INR)  ||
                     (opcode == OP_DCR)  || (opcode == OP_SHL)  ||
                     (opcode == OP_SHR);
 
    reg [2:0] T;
    assign t_state = T;

    always @(posedge clk) begin
        if (rst)
            T <= 3'd0;
        else if (T == 3'd5)
            T <= 3'd0;
        else
            T <= T + 3'd1;
    end

    
    always @(*) begin
        
        {MI,RO,RI,II,IO,CO,CE,CL,AI,AO,ALO,BI,OI,FE,HLT} = 15'b0;

        case (T)
 
            3'd0: begin
                CO = 1'b1;    
                MI = 1'b1;   
            end

            
            3'd1: begin
                CE = 1'b1;   
            end

           
            3'd2: begin
                RO = 1'b1;   
                II = 1'b1;   
            end

           
            3'd3: begin
                if (opcode == OP_LDA || is_binary) begin
                    IO = 1'b1;  
                    MI = 1'b1;   
                end
                else if (is_unary) begin
                    ALO = 1'b1;  
                    AI  = 1'b1;  
                    FE  = 1'b1;  
                end
                else if (opcode == OP_OUT) begin
                    AO  = 1'b1;  
                    OI  = 1'b1;  
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1;
                end
            
            end

            
            3'd4: begin
                if (opcode == OP_LDA) begin
                    RO = 1'b1;  
                    AI = 1'b1;   
                end
                else if (is_binary) begin
                    RO = 1'b1;   
                    BI = 1'b1;   
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1;
                end
            end

           
            3'd5: begin
                if (is_binary) begin
                    ALO = 1'b1; 
                    AI  = 1'b1; 
                    FE  = 1'b1;  
                end
                else if (opcode == OP_HLT) begin
                    HLT = 1'b1;
                end
            end

            default: ;

        endcase
    end

endmodule
