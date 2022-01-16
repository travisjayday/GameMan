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
`define ADDR_IN_RNG(LO, HI) \
    ((cpu_req.addr_select >= LO && cpu_req.addr_select < HI))

`define MAP_INTERFACE(DST_IF, BASE_OFFSET, START_OFFSET)        \
    DST_IF.addr_select  = cpu_req.addr_select - BASE_OFFSET + START_OFFSET;     \
    DST_IF.write_value  = cpu_req.write_value;                                  \
    cpu_req.read_out        = DST_IF.read_out;                                  \
    DST_IF.write_enable = cpu_req.write_enable; 

`define DMA_ADDR_IN_RNG(LO, HI) \
    ((dma_req.addr_select >= LO && dma_req.addr_select < HI))

`define DMA_MAP_INTERFACE(DST_IF, BASE_OFFSET, START_OFFSET)        \
    DST_IF.addr_select  = dma_req.addr_select - BASE_OFFSET + START_OFFSET;     \
    DST_IF.write_value  = dma_req.write_value;                                  \
    dma_req.read_out        = DST_IF.read_out;                                  \
    DST_IF.write_enable = dma_req.write_enable; 


`define UNMAP_INTERFACE(DST_IF)        \
    DST_IF.addr_select  = 0;     \
    DST_IF.write_value  = 0;                                  \
    DST_IF.write_enable = 0; 

`define UNMAP_MMIO()                    \
    `UNMAP_INTERFACE(mmio_ppu_if)      \
    `UNMAP_INTERFACE(mmio_apu_if)      \
    `UNMAP_INTERFACE(mmio_timer_if)    \
    `UNMAP_INTERFACE(mmio_ints_if)     \
    `UNMAP_INTERFACE(mmio_dma_if)      \
    `UNMAP_INTERFACE(mmio_joypad_if)

`define UM(DST_IF) `UNMAP_INTERFACE(DST_IF)

module mmu_m(
    input wire clk, 
    input wire rst,    
    mem_if.slave cpu_req, 
    mem_if.slave dma_req, 
    mem_if.master rom_if, 
    mem_if.master wram_if,
    mem_if.master hram_if,
    mem_if.master oam_if,
    mem_if.master vram_if,
    mem_if.master mmio_apu_if,
    mem_if.master mmio_ppu_if,
    mem_if.master mmio_timer_if,
    mem_if.master mmio_ints_if,
    mem_if.master mmio_dma_if,
    mem_if.master mmio_joypad_if,
    mem_if.master bootrom_if,
    logic [7:0] rom_data_read_out
    );

    always_comb begin
        if      /* ROM (0x0000 - 0x7FFF) */
        (`ADDR_IN_RNG(16'h0000, 16'h8000)) 
        begin
            rom_if.addr_select  = cpu_req.addr_select;     
            rom_if.write_value  = cpu_req.write_value;                                  
            cpu_req.read_out    = rom_data_read_out;                                  
            rom_if.write_enable = cpu_req.write_enable; 
        end else begin
            `UNMAP_INTERFACE(rom_if);
        end

        if /* VRAM, EXTRAM, WRAM (0x8000 - 0xDFFF) */
        (`ADDR_IN_RNG(16'h8000, 16'hA000) && dma_req.addr_select == 16'hFFFF) 
        begin
            `MAP_INTERFACE(vram_if, 16'h8000, 16'h0000); // map to mram_if[0:0x6000]
        end else begin
            `UNMAP_INTERFACE(vram_if);
        end

        if
        (`ADDR_IN_RNG(16'hC000, 16'hE000) && dma_req.addr_select == 16'hFFFF) 
        begin
            `MAP_INTERFACE(wram_if, 16'hC000, 16'h0000); // map to mram_if[0:0x6000]
        end else begin
            `UNMAP_INTERFACE(wram_if);
        end

        if /* ECHO RAM (0xE000 - 0xFDFF) */
        (`ADDR_IN_RNG(16'hE000, 16'hFE00)) 
        begin
            `MAP_INTERFACE(bootrom_if, 16'hE000, 16'h0000); // map to rom_if[0:0x8000]
        end else begin
            `UNMAP_INTERFACE(bootrom_if);
        end

        if /* OAM RAM (0xFE00 - 0xFE9F) */
        (`ADDR_IN_RNG(16'hFE00, 16'hFEA0) && dma_req.addr_select == 16'hFFFF) 
        begin
            `MAP_INTERFACE(oam_if, 16'hFE00, 16'h0000); // map to mram_if[0x6000:0x60A0]
        end else begin
            `UNMAP_INTERFACE(oam_if);
        end

        if (`DMA_ADDR_IN_RNG(16'hFE00, 16'hFEA0)) begin
            `DMA_MAP_INTERFACE(oam_if, 16'hFE00, 16'h0000);
        end

        if (`DMA_ADDR_IN_RNG(16'h8000, 16'hA000)) begin
            `DMA_MAP_INTERFACE(vram_if, 16'h8000, 16'h0000);
        end

        if (`DMA_ADDR_IN_RNG(16'hC000, 16'hE000)) begin
            `DMA_MAP_INTERFACE(wram_if, 16'hC000, 16'h0000);
        end


        if /* UNUSABLE RAM (0xFEA0 - 0xFEFF) */
        (`ADDR_IN_RNG(16'hFEA0, 16'hFF00) ) 
        begin
            // Not Usable RAM Requets
            $display("Request to unot usable ram was made...");
            //$finish;
            `UNMAP_MMIO;
        end

        if /* IO REGISTERS (0xFF00 - 0xFF7F) */
        (`ADDR_IN_RNG(16'hFF00, 16'hFF80) || cpu_req.addr_select == 16'hFFFF) 
        begin
            // 0xFF04 - DIV - Divider Register (R/W*)
            if      (cpu_req.addr_select == 16'hFF04) begin `MAP_INTERFACE(mmio_timer_if, 0, 0)
                `UM(mmio_ppu_if); `UM(mmio_joypad_if); `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_apu_if)
            end
            // 0xFF05 - TIMA - Timer Counter (R/W)
            else if (cpu_req.addr_select == 16'hFF05) begin `MAP_INTERFACE(mmio_timer_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_joypad_if); `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_apu_if)
            end
            // 0xFF05 - TMA - Timer Modulo (R/W)
            else if (cpu_req.addr_select == 16'hFF06) begin `MAP_INTERFACE(mmio_timer_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_joypad_if); `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_apu_if)
            end
            // 0xFF07 - TAC - Timer Control (R/W)
            else if (cpu_req.addr_select == 16'hFF07) begin `MAP_INTERFACE(mmio_timer_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_joypad_if); `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_apu_if)
            end
            // 0xFF0F - IF - Interrupt Flags (R/W)
            else if (cpu_req.addr_select == 16'hFF0F) begin `MAP_INTERFACE(mmio_ints_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
            end
            // 0xFF46 - DMA - Direct Memory Access (R/W)
            else if (cpu_req.addr_select == 16'hFF46) begin `MAP_INTERFACE(mmio_dma_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_ints_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
            end
            // 0xFFFF - IE - Interrupt Enable (R/W)
            else if (cpu_req.addr_select == 16'hFFFF) begin `MAP_INTERFACE(mmio_ints_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
            end
            // 0xFF00 - Joypad - Buttons (R/W)
            else if (cpu_req.addr_select == 16'hFF00) begin `MAP_INTERFACE(mmio_joypad_if, 0, 0) 
                `UM(mmio_ppu_if); `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
            end
            // 0xFF40-0xFF45 - PPU Registers
            else if (cpu_req.addr_select >= 16'hFF40 && cpu_req.addr_select <= 16'hFF45)
                begin `MAP_INTERFACE(mmio_ppu_if, 0, 0) 
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
                end
            // 0xFF4A-0xFF4b - More PPU Registesr
            else if (cpu_req.addr_select >= 16'hFF47 && cpu_req.addr_select <= 16'hFF4B)
                begin `MAP_INTERFACE(mmio_ppu_if, 0, 0) 
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_apu_if)
                end
            // 0xFF10-0xFF14 - APU Audio Channel 1
            else if (cpu_req.addr_select >= 16'hFF10 && cpu_req.addr_select <= 16'hFF14)
                begin `MAP_INTERFACE(mmio_apu_if, 0, 0)
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_ppu_if)
                end
            // 0xFF16-0xFF19 - APU Audio Channel 2
            else if (cpu_req.addr_select >= 16'hFF16 && cpu_req.addr_select <= 16'hFF19)
                begin `MAP_INTERFACE(mmio_apu_if, 0, 0)
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_ppu_if)
                end
            // 0xFF1A-0xFF1E - APU Audio Channel 3
            else if (cpu_req.addr_select >= 16'hFF1A && cpu_req.addr_select <= 16'hFF1E)
                begin `MAP_INTERFACE(mmio_apu_if, 0, 0)
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_ppu_if)
                end
            // 0xFF30-0xFF3F - APU Wave Data
            else if (cpu_req.addr_select >= 16'hFF30 && cpu_req.addr_select <= 16'hFF3F)
                begin `MAP_INTERFACE(mmio_apu_if, 0, 0)
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_ppu_if)
                end
            // 0xFF24-0xFF26 - APU Control
            else if (cpu_req.addr_select >= 16'hFF24 && cpu_req.addr_select <= 16'hFF26)
                begin `MAP_INTERFACE(mmio_apu_if, 0, 0) 
                    `UM(mmio_ints_if); `UM(mmio_dma_if); `UM(mmio_joypad_if); `UM(mmio_timer_if); `UM(mmio_ppu_if)
                end
            else begin
                `UNMAP_MMIO;
            end
        end
            else begin
                `UNMAP_MMIO;
            end

        if /* HRAM (0xFF80 - 0xFFFE) */
        (cpu_req.addr_select >= 16'hFF80 && cpu_req.addr_select < 16'hFFFF)
        begin
            `MAP_INTERFACE(hram_if, 16'hFF80, 16'h0000); // map to mram_if[0x60A0:0x6120]
        end else begin
            `UNMAP_INTERFACE(hram_if);
        end
    end

`ifdef 0
    always_comb begin
        logic [11:0] en_cpu_ifs;
        logic [11:0] en_dma_ifs;
        logic [1:0] en_ppu_ifs;
        logic [11:0] en_ifs;
        logic [15:0] mapped_cpu_addr; 
        logic [15:0] mapped_dma_addr; 
        logic [15:0] mapped_ppu_oam_addr; 
        logic [15:0] mapped_ppu_vram_addr; 

        en_ifs = 0; 
        en_cpu_ifs = 0; 
        en_dma_ifs = 0; 
        en_ppu_ifs = 0;
        mapped_cpu_addr = 0;
        mapped_dma_addr = 0;
        mapped_ppu_oam_addr = 0;
        mapped_ppu_vram_addr = 0;
        cpu_req.read_out = 8'hFF;
        dma_req.read_out = 8'hFF;
        ppu_oam_req.read_out = 8'hFF;
        ppu_vram_req.read_out = 8'hFF;
        
        /* PPU ACCESS */
        if /* VRAM      (0x8000 - 0x9FFF) */
        (`PPU_ADDR_IN_RNG(ppu_vram_req, 16'h8000, 16'hA000)) begin
            $display("Enabling VRAM IF bec of address");
            en_ppu_ifs |= `EN_PPU_VRAM_IF;
            mapped_ppu_vram_addr = ppu_vram_req.addr_select - 16'h8000;
        end
        if /* OAM RAM   (0xFE00 - 0xFE9F) */
        (`PPU_ADDR_IN_RNG(ppu_oam_req, 16'hFE00, 16'hFEA0)) begin 
            en_ppu_ifs |= `EN_PPU_OAM_IF;
            mapped_ppu_oam_addr = ppu_oam_req.addr_select - 16'hFE00;
        end

        /* DMA ACCESS */
        if /* ROM       (0x0000 - 0x7FFF) */
        (`DMA_ADDR_IN_RNG(16'h0000, 16'h8000))      `DMA_EN_INTERFACE(`EN_ROM_IF, 0)
        if /* VRAM      (0x8000 - 0x9FFF) */
        (`DMA_ADDR_IN_RNG(16'h8000, 16'hA000))      `DMA_EN_INTERFACE(`EN_VRAM_IF, -16'h8000)
        if /* EXTRAM    (0xA000 - 0xBFFF) */
        (`DMA_ADDR_IN_RNG(16'hA000, 16'hC000))      `DMA_EN_INTERFACE(`EN_ROM_IF, 0) // map these addresses back to the cartridge with no offset
        if /* WRAM      (0xC000 - 0xDFFF) */
        (`DMA_ADDR_IN_RNG(16'hC000, 16'hE000))      `DMA_EN_INTERFACE(`EN_WRAM_IF, -16'hC000)
        if /* ECHO RAM  (0xE000 - 0xFDFF) */
        (`DMA_ADDR_IN_RNG(16'hE000, 16'hFE00))      `DMA_EN_INTERFACE(`EN_WRAM_IF, -16'hE000)
        if /* OAM RAM   (0xFE00 - 0xFE9F) */
        (`DMA_ADDR_IN_RNG(16'hFE00, 16'hFEA0))      `DMA_EN_INTERFACE(`EN_OAM_IF, -16'hFE00)

        /* CPU ACCESS */
        if /* ROM       (0x0000 - 0x7FFF) */
        (`ADDR_IN_RNG(16'h0000, 16'h8000))          `EN_INTERFACE(`EN_ROM_IF, 0)
        if /* VRAM      (0x8000 - 0x9FFF) */
        (`ADDR_IN_RNG(16'h8000, 16'hA000))          `EN_INTERFACE(`EN_VRAM_IF, -16'h8000)
        if /* EXTRAM    (0xA000 - 0xBFFF) */
        (`ADDR_IN_RNG(16'hA000, 16'hC000))          `EN_INTERFACE(`EN_ROM_IF, 0) // map these addresses back to the cartridge with no offset
        if /* WRAM      (0xC000 - 0xDFFF) */
        (`ADDR_IN_RNG(16'hC000, 16'hE000))          `EN_INTERFACE(`EN_WRAM_IF, -16'hC000)
        if /* ECHO RAM  (0xE000 - 0xFDFF) */
        (`ADDR_IN_RNG(16'hE000, 16'hFE00))          `EN_INTERFACE(`EN_WRAM_IF, -16'hE000)
        if /* OAM RAM   (0xFE00 - 0xFE9F) */
        (`ADDR_IN_RNG(16'hFE00, 16'hFEA0) && dma_req.addr_select == 16'hFFFF)  // if no ongoing dma transfer
                                                    `EN_INTERFACE(`EN_OAM_IF, -16'hFE00)
        if /* NOUSE RAM (0xFEA0 - 0xFEFF) */
        (`ADDR_IN_RNG(16'hFEA0, 16'hFF00))          begin /* pass */ end 
        if /* IOREGS    (0xFF00 - 0xFF7F, 0xFFFF) */
        (`ADDR_IN_RNG(16'hFF00, 16'hFF80) || cpu_req.addr_select == 16'hFFFF) begin 
            // 0xFF04 - DIV - Divider Register (R/W*)
            if      (cpu_req.addr_select == 16'hFF04)   `EN_INTERFACE(`EN_TIMER_IF, 0)
            // 0xFF05 - TIMA - Timer Counter (R/W)
            else if (cpu_req.addr_select == 16'hFF05)   `EN_INTERFACE(`EN_TIMER_IF, 0)
            // 0xFF05 - TMA - Timer Modulo (R/W)
            else if (cpu_req.addr_select == 16'hFF06)   `EN_INTERFACE(`EN_TIMER_IF, 0)
            // 0xFF07 - TAC - Timer Control (R/W)
            else if (cpu_req.addr_select == 16'hFF07)   `EN_INTERFACE(`EN_TIMER_IF, 0)
            // 0xFF0F - IF - Interrupt Flags (R/W)
            else if (cpu_req.addr_select == 16'hFF0F)   `EN_INTERFACE(`EN_INTS_IF, 0)
            // 0xFF46 - DMA - Direct Memory Access (R/W)
            else if (cpu_req.addr_select == 16'hFF46)   `EN_INTERFACE(`EN_DMA_IF, 0)
            // 0xFFFF - IE - Interrupt Enable (R/W)
            else if (cpu_req.addr_select == 16'hFFFF)   `EN_INTERFACE(`EN_INTS_IF, 0)
            // 0xFF00 - Joypad - Buttons (R/W)
            else if (cpu_req.addr_select == 16'hFF00)   `EN_INTERFACE(`EN_JOYPAD_IF, 0)
            // 0xFF40-0xFF45 - PPU Registers
            else if (cpu_req.addr_select >= 16'hFF40 && cpu_req.addr_select <= 16'hFF45)
                `EN_INTERFACE(`EN_PPU_IF, 0)
            // 0xFF4A-0xFF4b - More PPU Registesr
            else if (cpu_req.addr_select >= 16'hFF47 && cpu_req.addr_select <= 16'hFF4B)
                `EN_INTERFACE(`EN_PPU_IF, 0)
            // 0xFF16-0xFF19 - APU Audio Channel 2
            else if (cpu_req.addr_select >= 16'hFF16 && cpu_req.addr_select <= 16'hFF19)
                `EN_INTERFACE(`EN_APU_IF, 0)
            // 0xFF24-0xFF26 - APU Control
            else if (cpu_req.addr_select >= 16'hFF24 && cpu_req.addr_select <= 16'hFF26)
                `EN_INTERFACE(`EN_APU_IF, 0)
        end
        if /* HRAM (0xFF80 - 0xFFFE) */
        (`ADDR_IN_RNG(16'hFF80, 16'hFFFF))          `EN_INTERFACE(`EN_HRAM_IF, -16'hFF80)

        en_ifs = en_dma_ifs | en_cpu_ifs;

        // Handle bus arbitration between CPU, DMA engine, and PPU
        if (en_ifs & `EN_ROM_IF)  `MAP_INTERFACE(`EN_ROM_IF,   rom_if,         2'b00) else `UNMAP_INTERFACE(rom_if)
        if (en_ifs & `EN_WRAM_IF) `MAP_INTERFACE(`EN_WRAM_IF,  wram_if,        2'b00) else `UNMAP_INTERFACE(wram_if)
        if (en_ifs & `EN_TIMER_IF)`MAP_INTERFACE(`EN_TIMER_IF, mmio_timer_if,  2'b00) else `UNMAP_INTERFACE(mmio_timer_if)
        if (en_ifs & `EN_INTS_IF) `MAP_INTERFACE(`EN_INTS_IF,  mmio_ints_if,   2'b00) else `UNMAP_INTERFACE(mmio_ints_if)
        if (en_ifs & `EN_HRAM_IF) `MAP_INTERFACE(`EN_HRAM_IF,  hram_if,        2'b00) else `UNMAP_INTERFACE(hram_if)
        if (en_ifs & `EN_DMA_IF)  `MAP_INTERFACE(`EN_DMA_IF,   mmio_dma_if,    2'b00) else `UNMAP_INTERFACE(mmio_dma_if)
        if (en_ifs & `EN_APU_IF)  `MAP_INTERFACE(`EN_APU_IF,   mmio_apu_if,    2'b00) else `UNMAP_INTERFACE(mmio_apu_if)
        if (en_ifs & `EN_PPU_IF)  `MAP_INTERFACE(`EN_PPU_IF,   mmio_ppu_if,    2'b00) else `UNMAP_INTERFACE(mmio_ppu_if)
        if (en_ifs & `EN_JOYPAD_IF)`MAP_INTERFACE(`EN_JOYPAD_IF,mmio_joypad_if,2'b00) else `UNMAP_INTERFACE(mmio_joypad_if)
        if ((en_ifs & `EN_VRAM_IF) || (en_ppu_ifs & `EN_PPU_VRAM_IF)) 
            `MAP_INTERFACE(`EN_VRAM_IF, vram_if, en_ppu_ifs)                          else `UNMAP_INTERFACE(vram_if)
        if ((en_ifs & `EN_OAM_IF) || (en_ppu_ifs & `EN_PPU_OAM_IF))  
            `MAP_INTERFACE(`EN_OAM_IF, oam_if, en_ppu_ifs)                            else `UNMAP_INTERFACE(oam_if)
    end
`endif
endmodule
