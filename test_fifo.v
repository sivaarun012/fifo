module synchronous_fifo #(parameter DEPTH=16, DATA_WIDTH=8) (
  input clk, rst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output full, empty
);
  
  // Define PTR_WIDTH manually as clog2(DEPTH)
  parameter PTR_WIDTH = 4;

  reg [PTR_WIDTH:0] w_ptr, r_ptr; // additional bit to detect full/empty condition
  reg [DATA_WIDTH-1:0] fifo[DEPTH-1:0];
  reg wrap_around;
  
  // Set Default values on reset.
  always @(posedge clk) begin
    if (!rst_n) begin
      w_ptr <= 0; 
      r_ptr <= 0;
      data_out <= 0;
    end
  end
  
  // To write data to FIFO
  always @(posedge clk) begin
    if (w_en & !full) begin
      fifo[w_ptr[PTR_WIDTH-1:0]] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  
  // To read data from FIFO
  always @(posedge clk) begin
    if (r_en & !empty) begin
      data_out <= fifo[r_ptr[PTR_WIDTH-1:0]];
      r_ptr <= r_ptr + 1;
    end
  end
  
  // Wrap-around condition to check if MSB of write and read pointers are different
  assign wrap_around = w_ptr[PTR_WIDTH] ^ r_ptr[PTR_WIDTH];
  
  // Full condition: MSB of write and read pointers are different and remaining bits are the same
  assign full = wrap_around & (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]);
  
  // Empty condition: All bits of write and read pointers are the same
  assign empty = (w_ptr == r_ptr);

endmodule
