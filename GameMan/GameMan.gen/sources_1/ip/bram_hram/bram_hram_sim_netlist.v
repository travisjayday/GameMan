// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Fri Nov 12 14:58:57 2021
// Host        : BasedTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               f:/Projects/GameMan/GameMan/GameMan.gen/sources_1/ip/bram_hram/bram_hram_sim_netlist.v
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
JQ==
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
