`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2021 04:07:26 PM
// Design Name: 
// Module Name: ram_unit
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

module bram_main_ram_m (
    input wire clk, 
    mem_if.slave in);

    bram_main_ram unit(
        .addra(in.addr_select[14:0]),
        .clka(clk), 
        .dina(in.write_value),
        .douta(in.read_out),
        .wea(in.write_enable)
        );
endmodule

`define ADDR_IN_RNG(LO, HI) \
    req.addr_select >= LO && req.addr_select < HI

`define MAP_INTERFACE(DST_IF, BASE_OFFSET, START_OFFSET)        \
    DST_IF.addr_select  = req.addr_select - BASE_OFFSET + START_OFFSET;     \
    DST_IF.write_value  = req.write_value;                                  \
    req.read_out        = DST_IF.read_out;                                  \
    DST_IF.write_enable = req.write_enable; 

module mmu_m(input wire clk, mem_if.slave req);

    // Contains:    Cartridge ROM
    // Size:        32KB 
    mem_if rom_if(); 
    bram_32k_rom_m rom(clk, rom_if);

    // Contains: VRAM   EXT RAM     WRAM    OAM     HRAM
    // Size:     8KB    8KB         4KB     160B    128B
    mem_if mram_if(); 
    bram_main_ram_m mram (clk, mram_if);

    always_comb begin
        if      /* ROM (0x0000 - 0x7FFF) */
        (`ADDR_IN_RNG(16'h0000, 16'h8000)) 
        begin
            `MAP_INTERFACE(rom_if, 16'h0000, 16'h0000); // map to rom_if[0:0x8000]
        end 
        else if /* VRAM, EXTRAM, WRAM (0x8000 - 0xDFFF) */
        (`ADDR_IN_RNG(16'h8000, 16'hE000)) 
        begin
            `MAP_INTERFACE(mram_if, 16'h8000, 16'h0000); // map to mram_if[0:0x6000]
        end 
        else if /* ECHO RAM (0xE000 - 0xFDFF) */
        (`ADDR_IN_RNG(16'hE000, 16'hFE00)) 
        begin
            `MAP_INTERFACE(mram_if, 16'hE000, 16'h4000); // map to mram_if[0:0x6000]
            //$display("Request to unimplemented echo ram was made...");
            //$finish;
        end 
        else if /* OAM RAM (0xFE00 - 0xFE9F) */
        (`ADDR_IN_RNG(16'hFE00, 16'hFEA0)) 
        begin
            `MAP_INTERFACE(mram_if, 16'hFE00, 16'hE000); // map to mram_if[0x6000:0x60A0]
        end 
        else if /* UNUSABLE RAM (0xFEA0 - 0xFEFF) */
        (`ADDR_IN_RNG(16'hFEA0, 16'hFF00)) 
        begin
            // Not Usable RAM Requets
            $display("Request to unot usable ram was made...");
            $finish;
        end 
        else if /* IO REGISTERS (0xFF00 - 0xFF7F) */
        (`ADDR_IN_RNG(16'hFF00, 16'hFF80)) 
        begin
            
        end
        else if /* HRAM (0xFF80 - 0xFFFE) */
        (`ADDR_IN_RNG(16'hFF80, 16'hFFFF))
        begin
            $display("Requerst to HRAM: 0x%x WE: %x VAL: %x", mram_if.addr_select, mram_if.write_enable, mram_if.write_value);
            `MAP_INTERFACE(mram_if, 16'hFF80, 16'hE0A0); // map to mram_if[0x60A0:0x6120]
        end 
        else if /* IE REGISTER (0xFFFF) */ 
        (req.addr_select == 16'hFFFF)
        begin

        end
        else begin
            $display("MMU Request to 0x%x unkown...", req.addr_select);
        end
    end
endmodule