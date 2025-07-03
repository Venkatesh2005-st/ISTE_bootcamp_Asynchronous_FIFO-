// Testbench for wptr_handler module

`timescale 1ns / 1ps

module tb_wptr_handler;

  parameter PTR_WIDTH = 3; 

  reg wclk;
  reg wrst_n;
  reg w_en;
  reg [PTR_WIDTH:0] g_rptr_sync;

  wire [PTR_WIDTH:0] b_wptr;
  wire [PTR_WIDTH:0] g_wptr;
  wire full;

  wptr_handler #(
    .PTR_WIDTH(PTR_WIDTH)
  ) uut (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .w_en(w_en),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr),
    .g_wptr(g_wptr),
    .full(full)
  );

  // Clock generation
  initial begin
    wclk = 0;
    forever #5 wclk = ~wclk; // 10ns period
  end

  initial begin
    wrst_n = 0; 
    w_en = 0;
    g_rptr_sync = 0;

    // Dump all signals in this scope to VCD file for GTKWave
    $dumpfile("./outputs/wptrhandler.vcd");
    $dumpvars(0, tb_wptr_handler); // Dumps all signals in the current scope (tb_wptr_handler)

    #10; // Wait for 10ns (2 clock cycles) for reset to be stable
    wrst_n = 1; // De-assert reset

    #40
    w_en = 1;
    
    #1000
    $finish;

  end
endmodule
