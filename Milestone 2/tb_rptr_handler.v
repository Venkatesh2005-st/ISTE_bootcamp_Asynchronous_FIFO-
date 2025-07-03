`timescale 1ns/1ps

module rptr_handler_tb;

  parameter PTR_WIDTH = 3;
  reg rclk, rrst_n, r_en;
  reg [PTR_WIDTH:0] g_wptr_sync;
  wire [PTR_WIDTH:0] b_rptr, g_rptr;
  wire empty;

  rptr_handler #(PTR_WIDTH) uut (
    .rclk(rclk),
    .rrst_n(rrst_n),
    .r_en(r_en),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr),
    .g_rptr(g_rptr),
    .empty(empty)
  );

  always #5 rclk = ~rclk; // 100 MHz clock

  initial begin
    rclk = 0;
    rrst_n = 0;
    r_en = 0;
    g_wptr_sync = 0;

    $dumpfile("./outputs/rptr_handler.vcd");
    $dumpvars(0,rptr_handler_tb);

    #10;
    rrst_n = 1;

    // Setting g_wptr_sync ahead of g_rptr to simulate available data
    #10 g_wptr_sync = 1; 
    #10 r_en = 1;        
    #10 r_en = 0;

    #10 g_wptr_sync = 2; 
    #10 r_en = 1;
    #10 r_en = 0;

    #10 g_wptr_sync = 3;
    #10 r_en = 1;
    #10 r_en = 0;

    #20 r_en = 0;

    #50;

    $finish;
  end

endmodule
