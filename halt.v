module halt (output gated_clk,
                       input hlt, clk);
					   
     assign gated_clk = (~hlt)&clk;
endmodule


