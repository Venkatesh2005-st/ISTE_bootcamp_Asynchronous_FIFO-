`timescale 1ns/1ps

module tb_async_fifo;

  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;
  parameter PTR_WIDTH = $clog2(DEPTH);

  reg wclk, wrst_n, rclk, rrst_n;
  reg w_en, r_en;
  reg [DATA_WIDTH-1:0] data_in;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;

  // Instantiate the DUT
  asynchronous_fifo #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) dut (
    .wclk(wclk), .wrst_n(wrst_n),
    .rclk(rclk), .rrst_n(rrst_n),
    .w_en(w_en), .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full), .empty(empty)
  );

  // Generate clocks
  initial wclk = 0;
  always #5 wclk = ~wclk; // 100 MHz

  initial rclk = 0;
  always #7 rclk = ~rclk; // ~71 MHz

  integer i;

  initial begin

    $dumpfile("./outputs/async_fifo.vcd");
    $dumpvars(0,tb_async_fifo);

    // Initialize
    wrst_n = 0; rrst_n = 0;
    w_en = 0; r_en = 0;
    data_in = 0;

    #20;
    wrst_n = 1; rrst_n = 1;

    // --- Test 1: Write → Read test ---
    $display("Write -> Read Test");
    for (i = 0; i < DEPTH; i = i + 1) begin
      @(negedge wclk);
      if (!full) begin
        data_in = i;
        w_en = 1;
      end
    end
    w_en = 0;

    #50;

    for (i = 0; i < DEPTH; i = i + 1) begin
      @(negedge rclk);
      if (!empty) begin
        r_en = 1;
        @(posedge rclk);
        $display("Read data = %d", data_out);
      end
    end
    r_en = 0;

    #50;

    // --- Test 2: FIFO Full prevention test ---
    $display("Full Prevention Test");
    for (i = 0; i < DEPTH + 2; i = i + 1) begin
      @(negedge wclk);
      if (!full) begin
        data_in = i + 100;
        w_en = 1;
        $display("Writing: %d", data_in);
      end else begin
        $display("Write prevented at i=%d due to full", i);
        w_en = 0;
      end
    end
    w_en = 0;

    #50;

    // --- Test 3: FIFO Empty prevention test ---
    $display("Empty Prevention Test");
    for (i = 0; i < DEPTH + 2; i = i + 1) begin
      @(negedge rclk);
      if (!empty) begin
        r_en = 1;
        @(posedge rclk);
        $display("Read data: %d", data_out);
      end else begin
        $display("Read prevented at i=%d due to empty", i);
        r_en = 0;
      end
    end
    r_en = 0;

    #50;
    $finish;
  end

endmodule
