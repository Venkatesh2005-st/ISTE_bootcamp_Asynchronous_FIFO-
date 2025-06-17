// Testbench for the two flip-flop synchronizer module

`timescale 1ns / 1ps 

module tb_synchronizer;

  parameter WIDTH = 3; 

  reg clk;      
  reg rst_n;     
  reg [WIDTH:0] d_in;   
  wire [WIDTH:0] d_out;   

  parameter CLK_PERIOD = 10; // 10ns period, 100MHz clock
  always #((CLK_PERIOD)/2) clk = ~clk; 

  synchronizer #(
    .WIDTH(WIDTH) 
  ) ff_sync (
    .clk(clk),    
    .rst_n(rst_n),   
    .d_in(d_in),     
    .d_out(d_out)    
  );

  initial begin

    clk = 0;       
    rst_n = 0;    
    d_in = 0;      

    $dumpfile("synchronizer_tb.vcd"); 
    $dumpvars(0, tb_synchronizer);     

    // Apply reset and hold for a few clock cycles
    #(CLK_PERIOD * 2);

    //Release reset and observe initial state
    rst_n = 1;    
    #(CLK_PERIOD);  

    // Test case 1: Change d_in to a new value
    d_in = 4'hA; 
    #(CLK_PERIOD * 2); 

    // Test case 2: Change d_in to another value
    d_in = 4'h3; 
    #(CLK_PERIOD * 2); 

    // Test case 3: d_in changes mid-cycle
    d_in = 4'hF; 
    #((CLK_PERIOD / 2) + 1); // Change d_in just after posedge clk (asynchronous change)
    d_in = 4'h5;
    #(CLK_PERIOD * 2); 

    // Test case 4: d_in changes multiple times rapidly 
    d_in = 4'h1;
    #((CLK_PERIOD / 4));
    d_in = 4'h2;
    #((CLK_PERIOD / 4));
    d_in = 4'hE;
    #(CLK_PERIOD * 2);

    $finish; 
  end

endmodule
