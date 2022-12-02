module data_memory(output reg [31:0] ReadData,input clk,rst, input [2:0] ReadControl, WriteControl, input [7:0] Address, input [31:0] WriteData);
    reg [31:0] data_mem_file [255:0];
    reg [31:0] store_intermediate, load_intermediate1,load_intermediate2;
    integer i;
    always @(posedge clk or posedge rst) begin //write at WD3 if WE3
        if(rst)
        begin
            for(i=0;i<=255;i=i+1)begin    //set everything to 0
                data_mem_file[i]<=32'd0;
            end
            store_intermediate <= 0;
        end
        else 
        begin
            case(WriteControl)//room for exploitation with funct3 and S or decrease no. of selection bits to 2        //assuming that data is in least significant bits
                3'b000:begin
                    store_intermediate = {24'h000000,WriteData[7:0]}<<({3'd0,Address[1:0]}<<3) ;
                    data_mem_file[Address>>2] = ( (data_mem_file[Address>>2]) & ~(32'h000000ff<< ({3'd0,Address[1:0]}<<3) ) ) | store_intermediate;
                 end            //Store Byte at address without altering other bits
                3'b001:begin
                    store_intermediate = {16'h0000,WriteData[15:0]}<<({3'd0,(Address[1]),1'd0}<<3);
                    data_mem_file[Address>>2] = ( (data_mem_file[Address>>2]) & ~(32'h0000ffff<< ({3'd0,(Address[1]),1'd0}<<3) )) | store_intermediate;//Store Half Word at address without altering other bits
                 end
                3'b010: data_mem_file[Address>>2] <= WriteData;//Store Word
                default: begin
                    for(i=0;i<32;i=i+1)begin    //retain current value
                        data_mem_file[i] <= data_mem_file[i];
                    end 
                end 
            endcase
        end
    end
    always @(*) begin
        case (ReadControl)//room for exploitation with funct3 and L
            3'b000:begin
                load_intermediate1=((3-{3'd0,Address[1:0]})<<3);
                load_intermediate2=data_mem_file[Address >> 2]<<load_intermediate1;
                ReadData = load_intermediate2>>>24;//read Byte                       -shifts byte      to extreme left and then extreme right to discard extra bits
            end
            3'b001:begin
                load_intermediate1=(2-{3'd0,(Address[1]),1'd0})<<3;//increase no. of bits
                load_intermediate2=data_mem_file[Address >> 2]<<load_intermediate1;
                ReadData = load_intermediate2>>>16;//read half-word               -shifts half-word "                                                         "
            end
            3'b010: ReadData =  data_mem_file[Address >> 2];//read word
            3'b100:begin
                load_intermediate1=((3-{3'd0,(Address[1:0])})<<3);
                load_intermediate2=data_mem_file[Address >> 2]<<load_intermediate1;
                ReadData = load_intermediate2>>24;//read Byte unsigned               -shifts byte      "                                                          "
            end
            3'b101:begin
                load_intermediate1=((2-{3'd0,(Address[1]),1'd0})<<3);
                load_intermediate2=data_mem_file[Address >> 2]<<load_intermediate1;
                ReadData = load_intermediate2>>16;//read half-word unsigned       -shifts half-word "                                                          "
            end
            default: begin
            ReadData <= 0;
            load_intermediate1 <= 0;
            load_intermediate2 <= 0;
            end
        endcase
    end
endmodule

