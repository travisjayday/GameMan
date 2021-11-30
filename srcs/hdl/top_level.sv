module top_level import cpu_defs::*;(
    input wire clk_100mhz, 
    input wire[15:0] sw,
    output logic[15:0] led
    );
    logic rst;
    assign rst = sw[15];

    reg_file_s regs_out;
    assign led = regs_out.BC;

    logic clk_4mhz; 
    clk_gen _clk_gen(clk_100mhz, clk_4mhz);

    // Contains:    Cartridge ROM
    // Size:        32KB 
    mem_if rom_if(); 
    bram_32k_rom_m rom(clk_4mhz, rom_if);

    // WRAM: Size 8KB
    mem_if wram_if(); 
    bram_main_ram_m wram (clk_4mhz, wram_if);

    // VRAM: Size: 8KB
    mem_if vram_if(); 
    bram_vram_m vram (clk_4mhz, vram_if);

    // OAM: Size: 160B
    mem_if oam_if(); 
    bram_oam_m oam (clk_4mhz, oam_if);

    // HRAM: Size: 127B
    mem_if hram_if(); 
    bram_hram_m hram (clk_4mhz, hram_if);


    // Interrupt Handler Module 
    // Sets IF flag for CPU. Handles writes and reads to IF and IE cpu.regs. 
    // 0xFFFF - IE (R/W)
    // 0xFF05 - IF (R/W)
    interrupt_lines_s interrupts; 
    // For now, pull other interrupts low
    assign interrupts.vblank = 0;
    assign interrupts.lcd_stat = 0;
    assign interrupts.joypad = 0; 
    mem_if mmio_interrupts_if(); 
    mmio_interrupts_m mmio_interrupts(clk_4mhz, rst, mmio_interrupts_if, interrupts);

    // 0xFF04 - Divider Regiser (R/W)
    mem_if mmio_timer_if();
    mmio_timer_m mmio_timer(clk_4mhz, rst, mmio_timer_if, interrupts.timer);


    // DMA
    mem_if dma_mmu_if();    // Busmaster 1
    mem_if mmio_dma_if();
    mmio_dma_m dma(clk_4mhz, rst, mmio_dma_if, dma_mmu_if);

    // Memory Mapping Unit
    mem_if cpu_mmu_if();    // Busmaster 0
    mmu_m mmu(
        .clk(clk_4mhz), 
        .rst(rst), 
        .cpu_req(cpu_mmu_if), 
        .dma_req(dma_mmu_if),
        .rom_if(rom_if), 
        .vram_if(vram_if),
        .oam_if(oam_if),
        .wram_if(wram_if),
        .hram_if(hram_if),
        .mmio_timer_if(mmio_timer_if),
        .mmio_ints_if(mmio_interrupts_if),
        .mmio_dma_if(mmio_dma_if)
    );


    // CPU 
    logic cpu_died;
    cpu_m cpu(
        .clk(clk_4mhz), 
        .rst(rst), 
        .mmu(cpu_mmu_if), 
        .mmio_reg_IF(mmio_interrupts.IF),
        .mmio_reg_IE(mmio_interrupts.IE), 
        .cpu_died(cpu_died), 
        .regs_out(regs_out)
    );

    initial begin
        $timeformat(-9, 2, " ns", 20);
    end

    /* CPU Watchdog */
    logic[2:0] zombie_cnt;
    always_ff @(posedge clk_4mhz) begin
        if (rst) zombie_cnt <= 0;
        else if (cpu_died && zombie_cnt == 2) begin
            $display("CPU Died!");
`ifndef SYNTHESIS
            dump_system_state();
`endif
            $finish;
        end
        else if (cpu_died) zombie_cnt <= zombie_cnt + 1; 
    end

    `define PRINT_MEM(NAME, MEMUNIT, SIZE)                                                                             \
        num_bytes = SIZE;                                                                                              \
        num_lines = num_bytes / cols_per_line;                                                                         \
        for (int i = 0; i < num_lines; i++) begin                                                                      \
            $fwrite(fd, "%s:%04x  ", NAME, i * cols_per_line);                                                         \
            for (int j = 0; j < cols_per_line; j++)                                                                    \
                $fwrite(fd, "%02x ",                                                                                   \
                    MEMUNIT.unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory[cols_per_line * i + j]);      \
            $fwrite(fd, "\n");                                                                                         \
        end

    task dump_system_state();
        automatic int fd;
        automatic int tmp;
        automatic string mem;
        automatic int cols_per_line = 16;
        automatic int num_lines = 100; 
        automatic int num_bytes = 100; 
        string sections[int] = '{0: "VRAM", 1: "ERAM", 2: "WRAM", 3: "_OAM", 4: "HRAM"};
    begin
        fd = $fopen("simdump.hex", "w");

        $fwrite(fd, "SECTION REGS\n");
        $fwrite(fd, "AF   BC   DE   HL   SP   PC\n");
        $fwrite(fd, "%04x %04x %04x %04x %04x %04x\n", 
            cpu.regs.AF, cpu.regs.BC, cpu.regs.DE, cpu.regs.HL, cpu.regs.SP, cpu.regs.PC);

        $fwrite(fd, "\nSECTION MMIO\n");
        $fwrite(fd, "DIV   TAC   TMA   TIMA\n");
        tmp = mmio_timer.sys_counter - 4;
        $fwrite(fd, "%02x    %02x    %02x   %02x\n", 
            (tmp >> 8) & 8'hff, mmio_timer.tac, mmio_timer.tma, mmio_timer.tima);

        $fwrite(fd, "\nSECTION SYS\n");
        $fwrite(fd, "totalclks    divider\n");
        tmp = mmio_timer.sys_counter - 4;
        $fwrite(fd, "%08x     %08x\n", cpu.totalclks, tmp);

        $fwrite(fd, "\nSECTION MEM\n");
        // in order for the below to compile you have to 
        // add `-L blk_mem_gen_v8_4_4_inst` to xevlog.exe

        `PRINT_MEM("_OAM", oam,  'd160);
        `PRINT_MEM("VRAM", vram, 'h2000);
        `PRINT_MEM("WRAM", wram, 'h2000);
        `PRINT_MEM("HRAM", hram, 'd128);
        `PRINT_MEM("ROM0", rom,  'h8000);
    end
    endtask 

endmodule

module clk_gen(
    (* gated_clock = "yes" *) input clk_in, 
    output reg clk_out
);

    /* Generate a 4.16Mhz Clock by dividing 100Mhz by 12*/
    logic [5:0] clk_divider = 0;

    initial begin
        clk_out = 0; 
    end

    always @(posedge clk_in) begin
        if (clk_divider == 11) begin
            clk_divider <= 0;
            clk_out <= ~clk_out;
        end else begin
            clk_divider <= clk_divider + 1; 
        end
    end
endmodule