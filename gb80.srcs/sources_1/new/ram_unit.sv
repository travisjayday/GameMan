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

    logic [7:0] outb;
    bram_main_ram unit(
        .clka(clk), 
        .addra(in.addr_select[14:0]),
        .dina(in.write_value),
        .douta(in.read_out),
        .wea(in.write_enable),

        .clkb(clk),
        .addrb(0),
        .dinb(0),
        .doutb(outb),
        .web(0),
        .enb(0)
        );
endmodule

`define ADDR_IN_RNG(LO, HI) \
    (req.addr_select >= LO && req.addr_select < HI)

`define MAP_INTERFACE(DST_IF, BASE_OFFSET, START_OFFSET)                    \
    DST_IF.addr_select  = req.addr_select - BASE_OFFSET + START_OFFSET;     \
    DST_IF.write_value  = req.write_value;                                  \
    req.read_out        = DST_IF.read_out;                                  \
    DST_IF.write_enable = req.write_enable;                                 \
    if (!(req.addr_select >= 16'hFF04 && req.addr_select <= 16'hFF07))      \
        mmio_timer_if.write_enable = 0;             \

`define UNMAP_INTERFACE(IF) \
    IF.addr_select = 0; IF.write_value = 0; IF.write_enable = 0;  

`define UNMAP_INTERFACES(IF1, IF2, IF3) \
    `UNMAP_INTERFACE(IF1); `UNMAP_INTERFACE(IF2); `UNMAP_INTERFACE(IF3);       

`define UNMAP_ALL_INTERFACES \
    `UNMAP_INTERFACE(rom_if); `UNMAP_INTERFACE(mram_if); `UNMAP_INTERFACE(mmio_timer_if); \
    `UNMAP_INTERFACE(mmio_interrupts_if);
    
`define UNMAP_EXCEPT_MRAM_IF `UNMAP_INTERFACES(rom_if, mmio_timer_if, mmio_interrupts_if);
`define UNMAP_EXCEPT_ROM_IF `UNMAP_INTERFACES(mram_if, mmio_timer_if, mmio_interrupts_if);
`define UNMAP_EXCEPT_TIMER_IF `UNMAP_INTERFACES(mram_if, rom_if, mmio_interrupts_if);
`define UNMAP_EXCEPT_INTERRUPTS_IF `UNMAP_INTERFACES(mram_if, rom_if, mmio_timer_if);

module mmu_m(
    input wire clk, 
    input wire rst,    
    mem_if.slave req, 
    mem_if.master rom_if, 
    mem_if.master mram_if,
    mem_if.master mmio_timer_if,
    mem_if.master mmio_interrupts_if
    );

    always_comb begin
        if      /* ROM (0x0000 - 0x7FFF) */
        (`ADDR_IN_RNG(16'h0000, 16'h8000)) 
        begin
            `MAP_INTERFACE(rom_if, 16'h0000, 16'h0000); // map to rom_if[0:0x8000]
            `UNMAP_EXCEPT_ROM_IF;
        end 
        else if /* VRAM, EXTRAM, WRAM (0x8000 - 0xDFFF) */
        (`ADDR_IN_RNG(16'h8000, 16'hE000)) 
        begin
            `MAP_INTERFACE(mram_if, 16'h8000, 16'h0000); // map to mram_if[0:0x6000]
            `UNMAP_EXCEPT_MRAM_IF;
        end 
        else if /* ECHO RAM (0xE000 - 0xFDFF) */
        (`ADDR_IN_RNG(16'hE000, 16'hFE00)) 
        begin
            `MAP_INTERFACE(mram_if, 16'hE000, 16'h4000); // map to mram_if[0:0x6000]
            `UNMAP_EXCEPT_MRAM_IF;
            //$display("Request to unimplemented echo ram was made...");
            //$finish;
        end 
        else if /* OAM RAM (0xFE00 - 0xFE9F) */
        (`ADDR_IN_RNG(16'hFE00, 16'hFEA0)) 
        begin
            `MAP_INTERFACE(mram_if, 16'hFE00, 16'hE000); // map to mram_if[0x6000:0x60A0]
            `UNMAP_EXCEPT_MRAM_IF;
        end 
        else if /* UNUSABLE RAM (0xFEA0 - 0xFEFF) */
        (`ADDR_IN_RNG(16'hFEA0, 16'hFF00)) 
        begin
            // Not Usable RAM Requets
            `UNMAP_ALL_INTERFACES;
            req.read_out = 0; 
            $display("Request to unot usable ram was made...");
            $finish;
        end 
        else if /* IO REGISTERS (0xFF00 - 0xFF7F, 0xFFFF) */
        (`ADDR_IN_RNG(16'hFF00, 16'hFF80) || req.addr_select == 16'hFFFF) 
        begin
            // 0xFF04 - DIV - Divider Register (R/W*)
            if      (req.addr_select == 16'hFF04) begin 
                `MAP_INTERFACE(mmio_timer_if, 0, 0); `UNMAP_EXCEPT_TIMER_IF;
            end
            // 0xFF05 - TIMA - Timer Counter (R/W)
            else if (req.addr_select == 16'hFF05) begin 
                `MAP_INTERFACE(mmio_timer_if, 0, 0); `UNMAP_EXCEPT_TIMER_IF;
            end
            // 0xFF05 - TMA - Timer Modulo (R/W)
            else if (req.addr_select == 16'hFF06) begin 
                `MAP_INTERFACE(mmio_timer_if, 0, 0); `UNMAP_EXCEPT_TIMER_IF;
            end
            // 0xFF07 - TAC - Timer Control (R/W)
            else if (req.addr_select == 16'hFF07) begin 
                `MAP_INTERFACE(mmio_timer_if, 0, 0); `UNMAP_EXCEPT_TIMER_IF;
            end
            // 0xFF0F - IF - Interrupt Flags (R/W)
            else if (req.addr_select == 16'hFF0F) begin 
                `MAP_INTERFACE(mmio_interrupts_if, 0, 0); `UNMAP_EXCEPT_INTERRUPTS_IF;
            end
            // 0xFFFF - IE - Interrupt Enable (R/W)
            else if (req.addr_select == 16'hFFFF) begin 
                `MAP_INTERFACE(mmio_interrupts_if, 0, 0); `UNMAP_EXCEPT_INTERRUPTS_IF;
            end
            else begin 
                `UNMAP_ALL_INTERFACES;
                mmio_timer_if.write_enable = 0;
                mmio_interrupts_if.write_enable = 0;
                req.read_out = 0; 
            end
        end
        else if /* HRAM (0xFF80 - 0xFFFE) */
        (`ADDR_IN_RNG(16'hFF80, 16'hFFFF))
        begin
            //$display("Requerst to HRAM: 0x%x WE: %x VAL: %x", mram_if.addr_select, mram_if.write_enable, mram_if.write_value);
            `MAP_INTERFACE(mram_if, 16'hFF80, 16'hE0A0); // map to mram_if[0x60A0:0x6120]
            `UNMAP_EXCEPT_MRAM_IF;
        end 
        else begin
            `UNMAP_ALL_INTERFACES;
            $display("MMU Request to 0x%x unkown...", req.addr_select);
            req.read_out = 0; 
        end
    end
endmodule