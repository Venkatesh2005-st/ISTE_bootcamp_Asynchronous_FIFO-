`timescale 1ns / 1ps 

module tb_fifo_mem;
  parameter DEPTH      = 8;
  parameter DATA_WIDTH = 8;
  parameter PTR_WIDTH  = 3; 

  reg wclk;           
  reg w_en;           
  reg rclk;            
  reg r_en;           
  reg [PTR_WIDTH:0] b_wptr;  
  reg [PTR_WIDTH:0] b_rptr;  
  reg [DATA_WIDTH-1:0] data_in; 
  reg full;            
  reg empty;           
  wire [DATA_WIDTH-1:0] data_out; 

  parameter WCLK_PERIOD = 10; // Write clock period (100 MHz)
  parameter RCLK_PERIOD = 15; // Read clock period (~66.6 MHz)

  always #((WCLK_PERIOD)/2) wclk = ~wclk; 
  always #((RCLK_PERIOD)/2) rclk = ~rclk; 

  // Internal counters to simulate FIFO pointer logic and full/empty for the test
  reg [PTR_WIDTH:0] tb_wptr_counter;
  reg [PTR_WIDTH:0] tb_rptr_counter;
  reg [PTR_WIDTH:0] fifo_level; 

  fifo_mem #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .PTR_WIDTH(PTR_WIDTH)
  ) fifo_mem (
    .wclk(wclk),
    .w_en(w_en),
    .rclk(rclk),
    .r_en(r_en),
    .b_wptr(b_wptr),
    .b_rptr(b_rptr),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
  );

  initial begin
    wclk = 0;
    rclk = 0;
    w_en = 0;
    r_en = 0;
    data_in = 0;
    full = 0;
    empty = 1; 
    b_wptr = 0;
    b_rptr = 0;
    tb_wptr_counter = 0;
    tb_rptr_counter = 0;
    fifo_level = 0;

    $dumpfile("fifo_mem_tb.vcd");
    $dumpvars(0, tb_fifo_mem);

    $display("[%0t] Initializing signals...", $time);
    #50; 

    // Perform Writes
    $display("[%0t] --- Starting Write Operations ---", $time);
    w_en = 1; 
    empty = 0; 

    // Write 5 data items
    repeat (5) begin
      @(posedge wclk); 
      if (!full) begin
        data_in = $urandom_range(255, 0); // random data 
        b_wptr = tb_wptr_counter; // Assign current write pointer to DUT input
        $display("[%0t] Write: d_in = %h, b_wptr = %d, fifo_level = %d", $time, data_in, b_wptr, fifo_level);
        tb_wptr_counter = (tb_wptr_counter + 1) % DEPTH; 
        fifo_level = fifo_level + 1; 
        if (fifo_level == DEPTH) full = 1; 
      end else begin
        $display("[%0t] FIFO Full, skipping write.", $time);
      end
    end

    w_en = 0; 
    $display("[%0t] --- Write Operations Finished ---", $time);
    #WCLK_PERIOD; 

    //Perform Reads
    $display("[%0t] --- Starting Read Operations ---", $time);
    r_en = 1; 
    full = 0; 

    // Read 3 data items
    repeat (3) begin
      @(posedge rclk); 
      if (!empty) begin
        b_rptr = tb_rptr_counter; // Assign current read pointer to DUT input
        $display("[%0t] Read: d_out = %h, b_rptr = %d, fifo_level = %d", $time, data_out, b_rptr, fifo_level);
        tb_rptr_counter = (tb_rptr_counter + 1) % DEPTH; 
        fifo_level = fifo_level - 1; 
        if (fifo_level == 0) empty = 1; 
      end else begin
        $display("[%0t] FIFO Empty, skipping read.", $time);
      end
    end

    r_en = 0; 
    $display("[%0t] --- Read Operations Finished ---", $time);
    #RCLK_PERIOD; 

    // Mix Writes and Reads
    $display("[%0t] --- Mixing Write and Read Operations ---", $time);
    // Write 2 more items
    w_en = 1;
    empty = 0;
    repeat (2) begin
      @(posedge wclk);
      if (!full) begin
        data_in = $urandom_range(255, 0);
        b_wptr = tb_wptr_counter;
        $display("[%0t] Mixed Write: d_in = %h, b_wptr = %d, fifo_level = %d", $time, data_in, b_wptr, fifo_level);
        tb_wptr_counter = (tb_wptr_counter + 1) % DEPTH;
        fifo_level = fifo_level + 1;
        if (fifo_level == DEPTH) full = 1;
      end
    end
    w_en = 0;

    // Read 4 items 
    r_en = 1;
    full = 0;
    repeat (4) begin
      @(posedge rclk);
      if (!empty) begin
        b_rptr = tb_rptr_counter;
        $display("[%0t] Mixed Read: d_out = %h, b_rptr = %d, fifo_level = %d", $time, data_out, b_rptr, fifo_level);
        tb_rptr_counter = (tb_rptr_counter + 1) % DEPTH;
        fifo_level = fifo_level - 1;
        if (fifo_level == 0) empty = 1;
      end
    end
    r_en = 0;

    #((WCLK_PERIOD + RCLK_PERIOD) * 2); 

    $display("[%0t] --- Testbench Finished ---", $time);
    $finish; 
  end

endmodule
