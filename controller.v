`timescale 1ns / 1ps

module controller(output reg [2:0] ImmSrc, output reg [3:0] alu_op, output reg [2:0] br_type,ReadControl,WriteControl,
                    output reg reg_wr, sel_A, sel_B,hlt,
                    output reg [1:0] wb_sel,
                    input[6:0] opcode,    //for all instructions
                    input [14:12] funct3, //for R,I,S,B and R4 Type   not for U and J Type
                    input [31:25] funct7, //only for R-Type         //-*change to base x:0
                    input rst);
                    
        
        reg R,Ii,S,L,B,auipc,lui,jal,jalr,halt;
        `define Type {R,Ii,S,L,B,auipc,lui,jal,jalr,halt}
        `define Control {ImmSrc,sel_A, sel_B,wb_sel,reg_wr,hlt}
        //determine instruction type
    always@(*)begin    
        if (rst)
        begin
            `Type<=0;
        end    
        else 
        begin //what to do for lui, auipc,
            case(opcode)//Type {R,Ii,S,L,B,auipc,lui,jal,jalr}  Type     Description             ALU     sel_A   sel_B   wb_sel  imm_gen     br_type   alu_op  reg_wr      d_wr
                3: `Type<= 'b0001000000;                         //I-Type   Load                    yes     1       1       2       0           none      0       1           0
                19:`Type<= 'b0100000000;                         //I-Type   immediate operation     yes     1       1       1       0           none      xxxx    1           0
                23:`Type<= 'b0000010000;                         //U-Type   auipc                   yes     0       1       1       4(u)        none      0       1           0
                35:`Type<= 'b0010000000;                         //S-Type   Store                   yes     1       1       z       1           none      0       0           1
                51:`Type<= 'b1000000000;                         //R-Type   register operation      yes     1       0       1       z           none      xxxx    1           0
                55:`Type<= 'b0000001000;                         //U-Type   lui                     yes?    1       1       1       4(u)        none      copy    1           0
                93:`Type<= 'b0000000001;						 //HALT     HALT
				99:`Type<= 'b0000100000;                         //B-Type   conditional branch      yes     0       1       z       2           xxx       0       0           0
                103:`Type<='b0000000010;                         //I-Type   jalr                    yes     1       1       0       0           uncond    0       1           0
                111:`Type<='b0000000100;                         //J-Type   jal                     yes     1       1       0       3           uncond    0       1           0
                default:`Type<='b0000000000;
            endcase    
        end
    end
    
    always @(*) begin
        if (R||Ii) begin    //determine aluop using: R,Ii,lui,funct3,funct7
            casex({R,funct7[30],funct7[25],funct3})//does not? cater for some Immediate instructions with fulty opcode
                6'b100000:alu_op<=0;//add
                6'b110000:alu_op<=1;//sub
                6'b000000:alu_op<=0;//addi
                6'b100001:alu_op<=4;//sll
                6'b000001:alu_op<=4;//slli
                6'b100010:alu_op<=14;//slt
                6'b000010:alu_op<=14;//slti
                6'b100011:alu_op<=13;//sltu
                6'b000011:alu_op<=13;//sltiu
                6'b100100:alu_op<=10;//xor
                6'b000100:alu_op<=10;//xori
                6'b100101:alu_op<=5;//srl
                6'b000101:alu_op<=5;//srli
                6'b110101:alu_op<=6;//sra
                6'b010101:alu_op<=6;//srai
                6'b100110:alu_op<=9;//or
                6'b000110:alu_op<=9;//ori
                6'b100111:alu_op<=8;//and
                6'b000111:alu_op<=8;//andi
                default:alu_op<=0;
            endcase    
        end
        else if(lui)begin
            alu_op<=4'b1100;//aluop for result=B
        end
        else begin
            alu_op<=0;//all other instructions use operation A+B of ALU
        end            
    end
    
    always @(*) begin//for WriteControl
        case ({S})
            1: WriteControl<=funct3;
            default: WriteControl<=7;//retain current value
        endcase
    end

    always @(*) begin//for ReadControl
        case ({L})
            1: ReadControl<=funct3;
            default: ReadControl<=7;//output 0
        endcase
    end

    always @(*) begin//for br_type
        casex({jal,jalr,B})
            3'b100: br_type <= 3 ;
            3'b010: br_type <= 3 ;//jal,jalr
            3'b001: br_type <= funct3 ;
            default: br_type<= 2; //no jump
        endcase
    end
    //Fix control signals for each instruction type
    always@(*)begin
        case(`Type)//Type {R,Ii,S,L,B,auipc,lui,jal,jalr,hlt}
        //Control {ImmSrc,sel_A, sel_B,wb_sel,reg_wr,hlt}
            10'b1000000000:`Control<=9'b000100110;//R
            10'b0100000000:`Control<=9'b000110110;//Ii
            10'b0010000000:`Control<=9'b001110000;//S
            10'b0001000000:`Control<=9'b000111010;//L
            10'b0000100000:`Control<=9'b010010000;//B
            10'b0000010000:`Control<=9'b011010110;//auipc
            10'b0000001000:`Control<=9'b011110110;//lui
            10'b0000000100:`Control<=9'b100010010;//jal
            10'b0000000010:`Control<=9'b000110010;//jalr
			10'b0000000001:`Control<=9'b000000001;//HALT
            default: `Control<=0;
        endcase
    end
    
endmodule