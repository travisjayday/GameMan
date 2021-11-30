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
    (cpu_req.addr_select >= LO && cpu_req.addr_select < HI)

`define DMA_ADDR_IN_RNG(LO, HI) \
    (dma_req.addr_select >= LO && dma_req.addr_select < HI)

/* Handle Bus arbitration between busmasters (CPU, DMA, PPU) */

`define WINS_BUS_CONFLICT_3_CONTENDORS(DST_IF, winner_req, mapped_winner_addr, loser1_req, loser2_req)   \
    DST_IF.addr_select  = mapped_winner_addr;                                       \
    DST_IF.write_value  = winner_req.write_value;                                   \
    DST_IF.write_enable = winner_req.write_enable;                                  \
    winner_req.read_out = DST_IF.read_out;                                          \
    loser1_req.read_out = DST_IF.read_out;                                          \
    loser2_req.read_out = DST_IF.read_out;                                          

`define WINS_BUS_CONFLICT_2_CONTENDORS(DST_IF, winner_req, mapped_winner_addr, loser_req)   \
    DST_IF.addr_select  = mapped_winner_addr;                                       \
    DST_IF.write_value  = winner_req.write_value;                                   \
    DST_IF.write_enable = winner_req.write_enable;                                  \
    winner_req.read_out = DST_IF.read_out;                                          \
    loser_req.read_out  = DST_IF.read_out;                                          

`define WINS_BUS_CONFLICT_NO_CONTENDORS(DST_IF, winner_req, mapped_winner_addr)     \
    DST_IF.addr_select  = mapped_winner_addr;                                       \
    DST_IF.write_value  = winner_req.write_value;                                   \
    DST_IF.write_enable = winner_req.write_enable;                                  \
    winner_req.read_out = DST_IF.read_out;                                          

`define MAP_INTERFACE(EN_IF, DST_IF)                                                \
    begin                                                                           \
        if (en_cpu_ifs & en_dma_ifs & EN_IF) begin                                  \
            /* CPU and DMA both try to access memory. DMA engine wins */            \
            `WINS_BUS_CONFLICT_2_CONTENDORS(DST_IF,                                 \
                dma_req, mapped_dma_addr,   /* winner & winning addresss */         \
                cpu_req                     /* loser */                             \
            );                                                                      \
        end else if (en_dma_ifs & EN_IF) begin                                      \
            /* DMA grabs the bus */                                                 \
            `WINS_BUS_CONFLICT_NO_CONTENDORS(DST_IF,                                \
                dma_req, mapped_dma_addr   /* winner & winning address */           \
            );                                                                      \
        end else begin                                                              \
            /* CPU grabs the bus */                                                 \
            `WINS_BUS_CONFLICT_NO_CONTENDORS(DST_IF,                                \
                cpu_req, mapped_cpu_addr    /* winner & winning address */          \
            );                                                                      \
        end                                                                         \
    end

`define UNMAP_INTERFACE(IF) \
    begin IF.addr_select = 0; IF.write_value = 0; IF.write_enable = 0;  end

`define EN_ROM_IF           10'b00_0000_0001
`define EN_WRAM_IF          10'b00_0000_0010
`define EN_OAM_IF           10'b00_0000_0100
`define EN_VRAM_IF          10'b00_0000_1000
`define EN_TIMER_IF         10'b00_0001_0000
`define EN_INTS_IF          10'b00_0010_0000
`define EN_HRAM_IF          10'b00_0100_0000
`define EN_DMA_IF           10'b00_1000_0000

`define EN_INTERFACE(EN_IF, OFFSET) \
    begin en_cpu_ifs |= EN_IF; mapped_cpu_addr = cpu_req.addr_select + OFFSET; end

`define DMA_EN_INTERFACE(EN_IF, OFFSET) \
    begin en_dma_ifs |= EN_IF; mapped_dma_addr = dma_req.addr_select + OFFSET; end


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
    mem_if.master mmio_timer_if,
    mem_if.master mmio_ints_if,
    mem_if.master mmio_dma_if
    );

    always_comb begin
        logic [9:0] en_cpu_ifs;
        logic [9:0] en_dma_ifs;
        logic [9:0] en_ifs;
        logic [15:0] mapped_cpu_addr; 
        logic [15:0] mapped_dma_addr; 

        en_ifs = 0; 
        en_cpu_ifs = 0; 
        en_dma_ifs = 0; 
        mapped_cpu_addr = 0;
        mapped_dma_addr = 0;
        cpu_req.read_out = 8'hFF;
        dma_req.read_out = 8'hFF;

        /* DMA ACCESS */
        if /* ROM       (0x0000 - 0x7FFF) */
        (`DMA_ADDR_IN_RNG(16'h0000, 16'h8000))      `DMA_EN_INTERFACE(`EN_ROM_IF, 0)
        if /* VRAM      (0x8000 - 0x9FFF) */
        (`DMA_ADDR_IN_RNG(16'h8000, 16'hA000))      `DMA_EN_INTERFACE(`EN_VRAM_IF, -16'h8000)
        if /* EXTRAM    (0xA000 - 0xBFFF) */
        (`DMA_ADDR_IN_RNG(16'hA000, 16'hC000))      begin /* pass. ask raiphy */ end
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
        (`ADDR_IN_RNG(16'hA000, 16'hC000))          begin /* pass. ask raiphy */ end
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
        end
        if /* HRAM (0xFF80 - 0xFFFE) */
        (`ADDR_IN_RNG(16'hFF80, 16'hFFFF))          `EN_INTERFACE(`EN_HRAM_IF, -16'hFF80)

        en_ifs = en_dma_ifs | en_cpu_ifs;

        // Handle bus arbitration between CPU and DMA engine
        if (en_ifs & `EN_ROM_IF)  `MAP_INTERFACE(`EN_ROM_IF, rom_if)            else `UNMAP_INTERFACE(rom_if)
        if (en_ifs & `EN_WRAM_IF) `MAP_INTERFACE(`EN_WRAM_IF, wram_if)          else `UNMAP_INTERFACE(wram_if)
        if (en_ifs & `EN_TIMER_IF)`MAP_INTERFACE(`EN_TIMER_IF, mmio_timer_if)   else `UNMAP_INTERFACE(mmio_timer_if)
        if (en_ifs & `EN_INTS_IF) `MAP_INTERFACE(`EN_INTS_IF, mmio_ints_if)     else `UNMAP_INTERFACE(mmio_ints_if)
        if (en_ifs & `EN_HRAM_IF) `MAP_INTERFACE(`EN_HRAM_IF, hram_if)          else `UNMAP_INTERFACE(hram_if)
        if (en_ifs & `EN_DMA_IF)  `MAP_INTERFACE(`EN_DMA_IF, mmio_dma_if)       else `UNMAP_INTERFACE(mmio_dma_if)
        if (en_ifs & `EN_VRAM_IF) `MAP_INTERFACE(`EN_VRAM_IF, vram_if)          else `UNMAP_INTERFACE(vram_if)
        if (en_ifs & `EN_OAM_IF)  `MAP_INTERFACE(`EN_OAM_IF, oam_if)            else `UNMAP_INTERFACE(oam_if)
    end
endmodule