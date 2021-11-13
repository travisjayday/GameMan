// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Fri Nov 12 15:01:00 2021
// Host        : BasedTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/Projects/GameMan/GameMan/GameMan.gen/sources_1/ip/bram_main_ram/bram_main_ram_stub.v
// Design      : bram_main_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *)
module bram_main_ram(clka, wea, addra, dina, douta, clkb, enb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[14:0],dina[7:0],douta[7:0],clkb,enb,web[0:0],addrb[14:0],dinb[7:0],doutb[7:0]" */;
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
