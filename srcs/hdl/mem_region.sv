`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2021 12:52:30 PM
// Design Name: 
// Module Name: mem_region
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

module bram_32k_rom_m (
    input wire clk, 
    mem_if.slave in);

    bram_32k_rom unit(
        .addra(in.addr_select),
        .clka(clk), 
        //.dina(in.write_value),
        //.wea(in.write_enable),
        .douta(in.read_out)
        );
endmodule

module bram_hram_m (
    input wire clk, 
    mem_if.slave in);

    bram_hram unit(
        .addra(in.addr_select[6:0]),
        .clka(clk), 
        .dina(in.write_value),
        .wea(in.write_enable),
        .douta(in.read_out)
        );
endmodule

module bram_vram_m (
    input wire clk, 
    mem_if.slave in);

    bram_vram unit(
        .addra(in.addr_select[12:0]),
        .clka(clk), 
        .dina(in.write_value),
        .wea(in.write_enable),
        .douta(in.read_out)
        );
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

module bram_main_ram_m (
    input wire clk, 
    mem_if.slave in);

    logic [7:0] outb;
    bram_main_ram unit(
        .clka(clk), 
        .addra(in.addr_select[14:0]),
        .dina(in.write_value),
        .douta(in.read_out),
        .wea(in.write_enable),

        .clkb(clk),
        .addrb(15'b0),
        .dinb(8'b0),
        .doutb(outb),
        .web(1'b0),
        .enb(1'b0)
        );
endmodule
