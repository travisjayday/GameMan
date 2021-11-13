// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Fri Nov 12 14:58:57 2021
// Host        : BasedTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bram_hram_sim_netlist.v
// Design      : bram_hram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bram_hram,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_4 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20544)
`pragma protect data_block
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
GX6DxAQ58vg/IC6i99KMAf5hpHnuk8Ir
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
