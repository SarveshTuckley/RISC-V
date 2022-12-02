module instruction_memory (output reg [31:0] Instr, input [31:0] PC);
    reg [31:0] instr_mem [44:0];
    
    initial
    $readmemh("INSTRUCTION_MEM.mem", instr_mem);
    
    always@(PC) begin
        Instr <= instr_mem[PC>>2];
    end


	
endmodule
