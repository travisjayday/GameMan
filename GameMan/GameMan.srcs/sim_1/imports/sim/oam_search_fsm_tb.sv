`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2021 07:00:39 PM
// Design Name: 
// Module Name: OAM_Search_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module oam_search_fsm_tb import cpu_defs::*;();

   // Inputs
   logic clk_in;
   logic rst_in;
   logic start_in;
   logic [7:0] data_from_oam;
   logic [7:0] LCDC;
   logic [7:0] LY;
   
   // Outputs
   logic [15:0] oam_addr;
   logic [15:0] queue_oam [9:0];
   logic [7:0] oam_din;
   logic oam_rd, oam_wr;
   //Debug
   logic [3:0] index;
   logic [15:0] curr_addr;
   logic [1:0] rd_count;
   logic [6:0] time_count;
   logic done;
   

   // Instantiate the Unit Under Test (UUT)
   
   oam_search_fsm uut(
    .clk_in(clk_in), .rst_in(rst_in), .start_in(start_in),
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    .oam_dout(data_from_oam),
    .oam_a(oam_addr),
    .oam_din(oam_din),
    .oam_rd(oam_rd),
    .oam_wr(oam_wr), 
    //Registers
    .LCDC(LCDC),
    .LY(LY),
    //Output Sprites 2 bytes 10 elements 
    .obj_queue_out(queue_oam),
    .done_out(done),
    //Debug
    .index(index),
    .curr_addr(curr_addr),
    .rd_count(rd_count),
    .count(time_count)
    ); 
    
    bram_oam unit(
        .addra(oam_addr[7:0]),
        .clka(clk_in), 
        .dina(oam_din),
        .wea(oam_wr),
        .douta(data_from_oam)
        );
        
        
//    mem_if oam_if();
//    bram_oam_m oam(
//        clk, oam_if
//        );

   always #5 clk_in = !clk_in;
   
   initial begin
       $readmemh("C:\\Users\\Ahmad\\Desktop\\Ape_Gang_FPGA_Project\\Tetris_OAM_RD_Test.txt", unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory);
        
      // Initialize Inputs
      clk_in = 0;
      rst_in = 0;
      start_in = 0;
      LCDC = 8'b0000_0000;
      LY = 8'd70;
      // Wait 1000 ns for global reset to finish
      #10000;
      
      rst_in = 1;
      #20;
      rst_in = 0;
      #20;
      
   end
endmodule


module bram_oam_m (
    input wire clk, 
    mem_if.slave in);
    
    bram_oam unit(
        .addra(in.addr_select[7:0]),
        .clka(clk), 
        .dina(in.write_value),
        .wea(in.write_enable),
        .douta(in.read_out)
        );
    
endmodule