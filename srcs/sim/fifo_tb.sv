`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////

module fifo_tb;

   // Inputs
   logic clk_in;
   logic rst_in;
   logic enable_in;
   logic dequeue_in;
   logic enqueue_in;
   logic [7:0] data_in;

   // Outputs
   logic  [7:0] data;
   logic full_out;
   logic empty_out;

   // Instantiate the Unit Under Test (UUT)
   fifo_generator_0 uut (
      .clk(clk_in),
      .srst(rst_in),
      .wr_en(enqueue_in),
      .rd_en(dequeue_in), 
      .din(data_in), 
      .dout(data), 
      .full(full_out),
      .empty(empty_out)
   );

   always #5 clk_in = !clk_in;
   
   initial begin
      // Initialize Inputs
      clk_in = 0;
      rst_in = 0;
      enable_in = 1;
      dequeue_in = 0;
      enqueue_in = 0;
      data_in = 8'b0000_0000;
      
      // Wait 1000 ns for global reset to finish
      #1000;
      rst_in = 1;   
      #20;
      rst_in = 0;
      #1000;
      // Add stimulus here
      for (int i = 1; i < 17; i++) begin
          #10;
          enqueue_in = 1;    
          data_in = i;      
          #10; 
          enqueue_in = 0;
          #10;
      end 
      #100;
      for (int i = 1; i < 17; i++) begin
          #10;
          dequeue_in = 1;
          #10;
          dequeue_in = 0;
          #10;
      end 
   end
      
endmodule