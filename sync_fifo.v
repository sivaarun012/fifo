module fifo_tb;
  parameter DATA_WIDTH = 8;
  
  reg clk, rst_n;
  reg w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;
  
  // FIFO instance
  synchronous_fifo #(.DEPTH(8), .DATA_WIDTH(DATA_WIDTH)) s_fifo (
    .clk(clk), 
    .rst_n(rst_n), 
    .w_en(w_en), 
    .r_en(r_en), 
    .data_in(data_in), 
    .data_out(data_out), 
    .full(full), 
    .empty(empty)
  );

  // Clock generation
  always #5 clk = ~clk;
  
  // Array for storing expected write data
  reg [DATA_WIDTH-1:0] wdata_q[0:31];
  integer wdata_index = 0;
  integer rdata_index = 0;
  integer i; // Declaring 'i' outside of the loops

  initial begin
    clk = 1'b0; 
    rst_n = 1'b0;
    w_en = 1'b0;
    data_in = 0;

    // Reset the FIFO
    repeat(10) @(posedge clk);
    rst_n = 1'b1;

    // Write data to FIFO
    repeat(2) begin
      for (i = 0; i < 30; i = i + 1) begin
        @(posedge clk);
        w_en = (i % 2 == 0) ? 1'b1 : 1'b0;
        if (w_en & !full) begin
          data_in = $random;
          wdata_q[wdata_index] = data_in;  // Store data in array
          wdata_index = wdata_index + 1;
        end
      end
      #50;
    end
  end

  initial begin
    r_en = 1'b0;

    // Wait some cycles after reset
    repeat(20) @(posedge clk);
    rst_n = 1'b1;

    // Read data from FIFO and compare with expected data
    repeat(2) begin
      for (i = 0; i < 30; i = i + 1) begin
        @(posedge clk);
        r_en = (i % 2 == 0) ? 1'b1 : 1'b0;
        if (r_en & !empty) begin
          #1;
          if (data_out !== wdata_q[rdata_index]) 
            $display("ERROR at time %0t: Expected data = %h, Read data = %h", $time, wdata_q[rdata_index], data_out);
          else 
            $display("PASS at time %0t: Expected data = %h, Read data = %h", $time, wdata_q[rdata_index], data_out);
          rdata_index = rdata_index + 1;
        end
      end
      #50;
    end

    $finish;
  end

  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
endmodule
