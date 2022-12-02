
module clock_divider(output reg clk_out, input clk_in );

    reg [31:0] counter=32'd0;
    
    parameter divisor = 100000000;
    
    always@(posedge clk_in)
        begin
            if(counter==divisor-1)
                counter<=32'b0;
           else
            counter<=counter+1'b1;
                clk_out <= (counter<divisor/2)?1'b1:1'b0;
        end
    
endmodule
