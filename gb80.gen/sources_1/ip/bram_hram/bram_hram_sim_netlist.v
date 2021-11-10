// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Tue Nov  9 11:13:41 2021
// Host        : BasedTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               f:/Projects/gb80/gb80.gen/sources_1/ip/bram_hram/bram_hram_sim_netlist.v
// Design      : bram_hram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bram_hram,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module bram_hram
   (clka,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [6:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [7:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [7:0]douta;

  wire [6:0]addra;
  wire clka;
  wire [7:0]dina;
  wire [7:0]douta;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [7:0]NLW_U0_doutb_UNCONNECTED;
  wire [6:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [6:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "7" *) 
  (* C_ADDRB_WIDTH = "7" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.54005 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "bram_hram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "127" *) 
  (* C_READ_DEPTH_B = "127" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "8" *) 
  (* C_READ_WIDTH_B = "8" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "127" *) 
  (* C_WRITE_DEPTH_B = "127" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "8" *) 
  (* C_WRITE_WIDTH_B = "8" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  bram_hram_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[7:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[6:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[6:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[7:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2021.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
sbNGmomEbP78s1hfxgX3P1Jo01EKJk0i0C7iGpF+Yibr9EK0s4mcIifHDN/ag4jpPwW3bPllMHvn
U8AEY3mO8hCXVVoilrcRuCaEna/98GycCzy4G7FnYMfowsJb5k9ifRdE2jnurzeTLFbupUSpDF0H
Rl3Ci3DTGeExAZZ9UQE=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zZZZoIprBFYfDWmCCcduELBM7HU98/+rvP9g8+y1mYyD3r3HEDm4ZwehwZvPoYWqoGXYoFqWZh3h
utt0abIfUW9/oF2vJ9hXn7nArtcm/Eui18rPYqp3aj/AItPNVXojk9zp7uFZLPTqcyig5v3Jtenl
qPnLi1Z84ZCW7NIRw6Y0bgmw6z26E8VPbYrZHs+0YW8Sztjo6CdIrQeEL5WBDolA0aHoKHWRZyFs
l5eRDmBAolj2uF07t/3eY3J7cYJmEDaoZ0TR1qcz25VFNu0OlcrEJ19IT+QdAxTah4jqJtknGZrT
6lUMwDZ7dBQwF1EuaE6p90gGNERhGAsbHLdvaw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KUbz0Iu2faeWqD6HFeuGLtSOAlqZmpKCCJfzym8tkcWUUNgNMn2mYvx6PTM7j4tyig8JdUG3uZYs
NfPgAsNXQtTI7b19u9CkMks9jR+oEzX1rW7QtTvSj/nHZLg2smoFwuB5Ieb7/B8IIs1NTUrIz6Rc
itLQVG+L+GMziamsrx4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
G7XYdRx9VGclyxTEtwMG+rjJHV8bfBxEGdkcN82UL3koN3Dt0M5AWkzEvHcskt1W0hTOjyYgmvYj
/p70w1nz96tlg226+e4UubpRmBH9QXBBX6UmqIwSiHj9H+XI1yNfTIdlwBKGQvfzwCAMwBwrrrGL
/804k5Ux3RhWRvwezZB4+sj9DFm4akREVXmNpfeqjI2X02LU/MxWMUbKxvjJnD9YxikAAO6ccTd6
8DKv76V76MEFVyXc7E2FeQDToW3lqkRTa6MTpIXbYSekRihQC+qPVuhPUneA4kepvQDfgFYE8/Ir
gu5gK+s/qNfuXhJUAqyLjslrUcY4+XD9ckpSvQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YXkYRXpUPv/tETnwnThdQ46UaPmI23lN9vrxHQjIOhq3WNJCuz7TYZK9hyzSdo6k0U6QE9ihQy2L
rYZg68RGbrK8bzlcnQ41r18LZb4GYlAn9PH7IrF1B+aHm3578doOZHf8wzUE2s+d1aHQIn6VIZjL
14pCTAjErJfMO13fgX6h8sgxb4GFC3eIORmkrq2J/fB9HALyh/qdGiLi7DejMfmdsssbOcPQTZUh
6Belf7fHTkIEr9B44rFZgMyrMVx4N9p0XpXD3JPe7Xeg6a3jxdqxHATaMuLdIa4s+ZiAz1TRx0EO
FFihCnLLb7weBBITQyTIncRL817BrF/ZXZD8Yw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
g7FbNw1ywd4TBNHq8OmK/4zoKI/t7vKmyT8R8SeiyUtKywhn0/7DZ/lV0Lf4IhY8X5MYsKtOQ5l6
DIl3fxtOhxpi8NHn9Nw3Nfb8NnS38Zuy6DSpwOL0f/GSmUSf2/YdB5Ben6xibQT0Oy//oBl5/1kR
pV5fWjj8WRgI6cnmfyj3g1MxepxPu1A/UHxlm1/i9yUHHi114N/hEQ0iujjrn6GxfZSiJUVF+r6c
rnxD//eOAl/YaxhdU/KhUkfsMn+MxtA5m6hTYYE0bnze8rpmEU5UGYKyY0p8KUs+MgsdTe+m/7gV
HSf6puBqQmEa1qksRfl742aL9B9y169or7Jp9Q==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kd1A2zIphLxXB0RyfHIqLkHXfWl0n38vROERuDghYrhK0ItcWGEP0XBrri6k1VZCSPYwiSu//pM6
83BfcPKbk09/A+ksvDIa3xS8Tg7DJK2AS+0pdnzBSjVWh+QD+glA3Hjk6LG9OMbjXyqD3hnMKacA
VRMwxKktV+KT5NXj5a7fMxXjo9exc0xM+woUJiSYs8onoUSwfBeH5/xhUy+iu+w0/OOydQE2LXZ0
1y+RObiz5C22dD4GGCfuvUCGAthYpUf633ZxRYN45mmAn5PxPsH4o+l2GhH/50Gu/VPVoAWDhgXQ
e93oPri++HinkK2uvDhDl4PI9HtRkq11Ky3uXQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
gDrrFgXHVyBo+Cn0bYn+SOSOCXPg7besukY6l0JmA/nu4gap105Wxbg11c7TJZ9ctHVLc5DXAxr+
EIvFpAIepoZBREtMjTlaIdNJ8k1nUpwAv2jaQeseq1TudTjugV1jtOYYk0RKd88z/6SJ8t9urDW0
yKqsfEWU3PwGcUGHOWtTn2hfAceNznmEIFWLmFmzSQJ1hQNdsIQn3jHnfMVYu8cAz5xvPVQWYyJW
pMHXhNYk6GyAjIshh991slb1g01K1ilR2tKD1EmxH5WGrX9BEUqBjHQo6uluC/d3mvcEQ5nJ1v+P
hIlj4qzUQT1wXjpk6d/BvNx7LyWmj5iq35dzNm+cdhfGwaFGG//vgmB6D/dFfs2BYSjHsa6VlpVM
7e2OgoFenuG9p1SVPI6gAs2MuFtnDKfxW7jS3RGhvsquS3tg1iFCDH/OU7E5aWfY7twF3yyN6G10
l72RZw62DfNoCdyUMG9sA8nc4qf6dEhyrr5S6XxpJhoBDJvkeq0TCUQZ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XR7vRF1m+9DS2Pv4r/O4uHwmvtXkChnKbsJCYczn1dvkZbcZSbBm/2UH78dXUaNorOh9XAuCvSjb
ER73y7e0anAfaIf1tJ9Y9pIb8EuNxGS/Pqdvg36cWarwGac9tsscdv/HWfb5Z+qWEk0/uFcLI7pH
CZO7fF2/ONQjA0NtUFBjW4idlx8WrySIuJgDs4jyGkMhbHR3U/ghF1YhMhwgwsbbcptfC1XLrIqQ
OecZnZu8E2hyc5eK/ccYdKcHnXoL55z1p5amI6Fuvz0wKTz2QQ/mwXodfGjEC1ZRWwTn7zCFM91M
qrA1Is49i6pSa7/VICjgn8ULMT1oKGfJLPm7hg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20464)
`pragma protect data_block
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
PQ==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
