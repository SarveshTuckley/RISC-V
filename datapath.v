module datapath(output [6:0] opcode,
                output [14:12] funct3, 
                output [31:25] funct7, 
                output [31:0] Result,
                output zero,over_load,
                input rst,clk, reg_wr,sel_A,sel_B,
                input [1:0] wb_sel,
                input [2:0] ImmSrc,input [3:0] alu_op, input [2:0] br_type, ReadControl, WriteControl,input test,input [7:0]test_addr);
	
	wire [31:0] PC, PCNext, PCPlus4, ImmExt, SrcA, RD1, RD2, SrcB, rdata, ALUResult, Instr;
	wire [24:20] rs2;
	wire [19:15] rs1;
	wire [11:7] rd;
    wire [31:7] imm;
    wire br_taken;

	//For Test Purpose
    wire [31:0] inpaddr_t;
    wire [31:0] Result_temp;
	assign inpaddr_t = test ? test_addr:ALUResult[7:0];
	assign Result = test ? rdata : Result_temp;
	//End of Test Purpose Code
	


	
	//instantiate and join all modules of datapath here
	mux2 #(32) pcnext(.y(PCNext),.d0(PCPlus4),.d1(ALUResult),.s(br_taken));
	pc pc_inst(.PC(PC),.clk(clk),.reset(rst),.PCNext(PCNext));
	adder pc_plus4(.y(PCPlus4),.a(PC),.b(32'd4));
	instruction_memory ins_mem(.Instr(Instr),.PC(PC));
	instruction_fetch ins_fetch(.opcode(opcode),.rd(rd),.funct3(funct3),.rs1(rs1),.rs2(rs2),.funct7(funct7),.imm(imm),.Instr(Instr));
	extend ext(.immext(ImmExt),.instr(Instr[31:7]),.immsrc(ImmSrc));
	register_file reg_file(.RD1(RD1),.RD2(RD2),.clk(clk), .WE3(reg_wr), .rst(rst), .A1(rs1),.A2(rs2),.A3(rd), .WD3(Result));
	branch_cond Br_taken(.br_taken(br_taken),.br_type(br_type),.A(RD1),.B(RD2));
	mux2 #(32) srcA(.y(SrcA),.d0(PC),.d1(RD1),.s(sel_A));
	mux2 #(32) srcB(.y(SrcB),.d0(RD2),.d1(ImmExt),.s(sel_B));
	alu aalu(.A(SrcA),.B(SrcB),.ALU_Sel(alu_op), .ALU_Out(ALUResult),.zero(zero),.over_load(over_load));
	data_memory data_mem(.ReadData(rdata),.clk(clk),.rst(rst),.ReadControl(ReadControl),.WriteControl(WriteControl),.Address(inpaddr_t),.WriteData(RD2));
	mux3 #(32) result(.y(Result_temp),.d0(PCPlus4),.d1(ALUResult),.d2(rdata),.s(wb_sel));
	
endmodule
