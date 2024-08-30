'timescale 1ns/1ps

module sync_fifo(clk, reset, wr_en, rd_en, din, dout, full, empty);

    input clk, reset;
    input wr_en, rd_en;

    input [7:0] din;
    
    output full, empty;

    output [7:0] dout;

    reg [7:0] mem [0:15];

    reg [4:0] addr;

    integer i;

    assign full = (addr == 5'b10000) ? 1'b1 : 1'b0;
    assign empty = (addr == 5'b00000) ? 1'b1 : 1'b0;

    always @ (posedge clk)
       begin
        if(reset)
           begin 
            addr = 4'b0000;
            for (i=0; i<15; i=i+1)
               mem[i] = 8'b0;
            end

        else if (wr_en|rd_en)
           begin
            if(wr_en && (!full))
               begin
                mem[addr] = din;
                addr = addr + 1;
               end
        
            else if (rd_en && (!empty))
              begin
               dout = mem[0];
               mem[0] = mem[1];
               mem[1] = mem[2];
               mem[2] = mem[3];
               mem[3] = mem[4];
               mem[4] = mem[5];
               mem[5] = mem[6];
               mem[6] = mem[7];
               mem[7] = mem[8];
               mem[8] = mem[9];
               mem[9] = mem[10];
               mem[10] = mem[11];
               mem[11] = mem[12];
               mem[12] = mem[13];
               mem[13] = mem[14];
               mem[14] = mem[15];
               addr = addr - 1;
              end
           end

       end

endmodule