// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sun Oct 24 14:54:23 2021
// Host        : BasedTower running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    wea,
    addra,
    dina,
    douta,
    clkb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [8:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [7:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [7:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [8:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [7:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [7:0]doutb;

  wire [8:0]addra;
  wire [8:0]addrb;
  wire clka;
  wire [7:0]dina;
  wire [7:0]dinb;
  wire [7:0]douta;
  wire [7:0]doutb;
  wire [0:0]wea;
  wire [0:0]web;
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
  wire [8:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [8:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "9" *) 
  (* C_ADDRB_WIDTH = "9" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.7033 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
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
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "512" *) 
  (* C_READ_DEPTH_B = "512" *) 
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
  (* C_WRITE_DEPTH_A = "512" *) 
  (* C_WRITE_DEPTH_B = "512" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "8" *) 
  (* C_WRITE_WIDTH_B = "8" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[8:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[8:0]),
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
        .web(web));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21232)
`pragma protect data_block
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
pGI0kisuQcX5OPZaw4ZcWInZccugMdAzoe0VKQ==
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
