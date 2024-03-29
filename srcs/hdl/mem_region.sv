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
    input wire [1:0] sw,
    output logic[7:0] rom_data_read_out,
    mem_if.slave in);

    logic [7:0] game0_out;
    bram_32k_rom game0(
        .addra(in.addr_select),
        .clka(clk), 
        .douta(game0_out)
        );
    //assign game0_out = 0;

    logic [7:0] game1_out;
    bram_32k_rom_2 game1(
        .addra(in.addr_select),
        .clka(clk), 
        .douta(game1_out)
        );
   
    always_comb begin
        case (sw)
            2'b00: rom_data_read_out = game0_out;
            2'b01: rom_data_read_out = game1_out;
            default: rom_data_read_out = game0_out;
        endcase
    end
    
endmodule

module bram_bootrom_m (
    input wire clk, 
    mem_if.slave in);

    bram_bootrom unit(
        .addra(in.addr_select[9:0]),
        .clka(clk), 
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
    mem_if.slave in,
    mem_if.slave ppu_in);

    bram_vram unit(
        .addra(in.addr_select[12:0]),
        .clka(clk), 
        .dina(in.write_value),
        .wea(in.write_enable),
        .douta(in.read_out),

        .addrb(ppu_in.addr_select[12:0]),
        .clkb(clk),
        .dinb(ppu_in.write_value),
        .web(0),
        .doutb(ppu_in.read_out)
        );
endmodule

module bram_oam_m (
    input wire clk, 
    mem_if.slave in, 
    mem_if.slave ppu_in);

    bram_oam unit(
        .addra(in.addr_select[7:0]),
        .clka(clk), 
        .dina(in.write_value),
        .wea(in.write_enable),
        .douta(in.read_out),

        .addrb(ppu_in.addr_select[7:0]),
        .clkb(clk),
        .dinb(ppu_in.write_value),
        .web(0),
        .doutb(ppu_in.read_out)
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
