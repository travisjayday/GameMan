`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2021 05:37:22 PM
// Design Name: 
// Module Name: mmio_ppu
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


module mmio_ppu_m(
    input wire clk, 
    input wire rst,
    mem_if.slave req,
    mem_if.master ppu_oam_req,
    mem_if.master ppu_vram_req,
    output wire [1:0] pixel_out,
    output wire [15:0] lcd_a,
    output wire lcd_wr,
    output wire vblank_interrupt,
    output wire statline_interrupt
    );

    logic start_in;
    assign start_in = 0; 

    // dummies
    logic vram_rd, vram_wr, oam_wr, oam_rd;

    ppu _ppu(
        .clk_in(clk), .rst_in(rst), .start_in(start_in),
        //LCD Logic
        .pixel_out(pixel_out),
        //SCREEN BUFFER
        .lcd_a(lcd_a),
        .lcd_wr(lcd_wr),
        //VRAM DATA BUS, 0x8000 - 0x9FFF 
        .vram_dout(ppu_vram_req.read_out), .vram_a(ppu_vram_req.addr_select), .vram_din(ppu_vram_req.write_value), 
        .vram_wr(vram_wr), 
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(ppu_oam_req.read_out), .oam_a(ppu_oam_req.addr_select), .oam_din(ppu_oam_req.write_value),
        .oam_wr(oam_wr), 
        //CPU R/W REGISTERS 
        .mmio_dout(req.read_out), .mmio_a(req.addr_select), .mmio_din(req.write_value), .mmio_rd(!req.write_enable), .mmio_wr(req.write_enable),
        .stat_interrupt(statline_interrupt),
        .vblank_interrupt(vblank_interrupt)
        );
endmodule
