// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *)
module bram_main_ram(clka, wea, addra, dina, douta, clkb, enb, web, addrb, dinb, 
  doutb);
  input clka;
  input [0:0]wea;
  input [14:0]addra;
  input [7:0]dina;
  output [7:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [14:0]addrb;
  input [7:0]dinb;
  output [7:0]doutb;
endmodule
