module alu(output [31:0] ALU_Out, // ALU 8-bit Output
           output reg zero,over_load,
		   input [31:0] A,B,  // ALU 8-bit Inputs
           input [3:0] ALU_Sel// ALU Selection
           );
    reg [31:0] ALU_Result;
    wire [32:0] tmp;
    
    assign ALU_Out = ALU_Result; // ALU out
    
    always @(*)begin
      case(ALU_Sel)
      4'b0000: // Addition
      begin
        ALU_Result <= A + B ;

                if ((A[31] == B[31])&&(ALU_Result[31] != B[31])) over_load <= 1;
                else over_load <=0;
      end
      4'b0001:
      begin // Subtraction
        ALU_Result <= A - B ;
                if ((A[31]!=B[31])&&(ALU_Result[31] == B[31])) over_load <= 1;
                else over_load <=0;
      end
      4'b0100: // Logical shift left
        ALU_Result <= A<<B[4:0];//max shifting limit of 31 bits
      4'b0101: // Logical shift right
        ALU_Result <= A>>B[4:0];//max shifting limit of 31 bits
      4'b0110: // Arithmetic Shift right
        ALU_Result <= A>>>B[4:0];
      4'b1000: //  Logical and
        ALU_Result <= A & B;
      4'b1001: //  Logical or
        ALU_Result <= A | B;
      4'b1010: //  Logical xor
        ALU_Result <= A ^ B;
      4'b1100: //  copy B for lui
        ALU_Result <= B;
      4'b1101: // Greater comparison unsigned
        ALU_Result <= (A < B)?32'd1:32'd0 ;
      4'b1110: // Greater comparison signed
        ALU_Result <= ($signed(A) < $signed(B))?32'd1:32'd0 ;
      default: ALU_Result <= 32'b0 ;
      endcase
      if (ALU_Result == 0) zero <=1;
                else zero <= 0;
    end

endmodule
