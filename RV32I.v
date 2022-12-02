
module RV32I(output [31:0] Result,output zero,overload,hlt,input clk,rst,test,input [7:0] test_addr );
wire [6:0] opcode;
wire [14:12] funct3; 
wire [31:25] funct7; 
wire [31:0] Instr;
wire br_taken,ResultSrc,reg_wr,sel_A,sel_B; 
wire [3:0] alu_op;
wire [2:0] ImmSrc, br_type,ReadControl,WriteControl;
wire [1:0] wb_sel;
wire hlt,gated_clk;



//For test Purpose code
wire [2:0] ReadControl_t;
assign ReadControl_t = test?3'b010:ReadControl;
//End for Test Purpose Code


datapath dp(.opcode(opcode), .funct3(funct3), .funct7(funct7), .Result(Result), .rst(rst),.clk(gated_clk),.reg_wr(reg_wr),.sel_A(sel_A),.sel_B(sel_B), .wb_sel(wb_sel), 
.ImmSrc(ImmSrc), .alu_op(alu_op),.br_type(br_type),.ReadControl(ReadControl_t),.WriteControl(WriteControl),.test(test),.test_addr(test_addr),.zero(zero),.over_load(overload));

controller con(.ImmSrc(ImmSrc),.alu_op(alu_op),.br_type(br_type),.ReadControl(ReadControl),.WriteControl(WriteControl), .reg_wr(reg_wr), .sel_A(sel_A), .sel_B(sel_B),.hlt(HLT), 
.wb_sel(wb_sel), .opcode(opcode), .funct3(funct3), .funct7(funct7),.rst(rst));

halt stop(.gated_clk(gated_clk),.hlt(hlt),.clk(clk));

endmodule

