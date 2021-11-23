`timescale 1ns / 1ps
`default_nettype none


module cart_interface(
                    input wire clk,
                    input wire rst,
                    mem_if.slave rom_if,
                    
                    output logic clk_out,
                    output logic rst_out,
                    output logic not_write_enable_out,
                    output logic not_read_enable_out,
                    output logic not_cs_out,
                    output logic [15:0] addr_out,
                    inout  wire  [7:0] data_out
                    );
                    
    clk_divider #(.DIVIDER(4)) cart_clock (.clk_in(clk),.rst_in(rst),.clk_out(clk_out));
    
    always_comb begin
        rst_out = ~rst;                                 // carteidge is active low reset
        addr_out = rom_if.addr_select;
        not_read_enable_out = rom_if.write_enable;      // no need to invert due to cartride being active low
        not_write_enable_out = ~rom_if.write_enable;    // invert because cartridge is active low.
        not_cs_out = ~(16'hA000 <= rom_if.addr_select && rom_if.addr_select < 16'hC000); // cs is active when the cpu is accessing the external ram (i think)
    end
                    
endmodule


module top_level(
    input wire                  clk_100mhz,
    input  wire    [7:0]       ja,              // ja : a[7:0]
    output logic    [7:0]       jb,              // jb : a[15:8]
    output logic     [7:0]       jc,              // 0:reset, 1:cs, 2:rd, 3:wr, 4:clk. 5-7:nc
    output logic     [7:0]       jd,              // jd : d[7:0]
    //input wire      [7:0]       je,           // idk where is
    input wire      [15:0]       sw,
    output logic      [15:0]     led,

    input wire             uart_txd_in,
    output logic           uart_rxd_out,
    input wire             btnc
    );
    
    logic [15:0] a;
    logic [7:0]  d;
    logic cart_clk;
    logic wr;
    logic rd;
    logic cs;
    logic cart_rst;
    
    logic system_reset;
    assign system_reset = btnc;
    
    assign cart_rst = ~system_reset;
    
    assign {jb,jd} = a;
    //assign d = jd;
    assign jc = {1'd0,1'd0,1'd0,cart_clk,wr,rd,cs,cart_rst};
    
    
    assign cs = 0;
    assign rd = 1;
    
    assign a = sw;
    
    assign led[7:0] = ~ja;
    
    clk_divider cart_clock (.clk_in(clk_100mhz),.rst_in(system_reset),.clk_out(cart_clk));
        
    cart_if cart_if_m ();

    always_ff @ (posedge clk_100mhz) begin
    
    
    
    end

    
    
    
    
endmodule


`default_nettype wire