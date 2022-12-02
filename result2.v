module result2 #(parameter WIDTH = 32)
                      (output  reg [WIDTH-1:0] result2,
                       input [WIDTH-1:0] result,
                       input [1:0] s);
     
     reg [WIDTH-1:0] temp;

 
     always@(*)
        begin
          if(s[1]^s[0])
          begin
            result2 = result;
            temp <= result2;
          end
          else if(result2==0)
            result2 <= temp;
        end
endmodule
