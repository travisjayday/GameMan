module top_level import cpu_defs::*;(
    input wire clk, 
    input wire[15:0] sw,
    output reg_file_s regs_out
    );
    logic rst;
    assign rst = sw[15];

    // Contains:    Cartridge ROM
    // Size:        32KB 
    mem_if rom_if(); 
    bram_32k_rom_m rom(clk, rom_if);

    // Contains: VRAM   EXT RAM     WRAM    OAM     HRAM
    // Size:     8KB    8KB         4KB     160B    128B
    mem_if mram_if(); 
    bram_main_ram_m mram (clk, mram_if);

    // Interrupt Handler Module 
    // Sets IF flag for CPU. Handles writes and reads to IF and IE regs. 
    // 0xFFFF - IE (R/W)
    // 0xFF05 - IF (R/W)
    interrupt_lines_s interrupts; 
    // For now, pull other interrupts low
    assign interrupts.vblank = 0;
    assign interrupts.lcd_stat = 0;
    assign interrupts.joypad = 0; 
    mem_if mmio_interrupts_if(); 
    mmio_interrupts_m mmio_interrupts(clk, rst, mmio_interrupts_if, interrupts);

    // 0xFF04 - Divider Regiser (R/W)
    mem_if mmio_timer_if();
    mmio_timer_m mmio_timer(clk, rst, mmio_timer_if, interrupts.timer);

    // Memory Mapping Unit
    mem_if mmu_if(); 
    mmu_m mmu(
        .clk(clk), 
        .rst(rst), 
        .req(mmu_if), 
        .rom_if(rom_if), 
        .mram_if(mram_if),
        .mmio_timer_if(mmio_timer_if),
        .mmio_interrupts_if(mmio_interrupts_if)
    );

    // CPU 
    reg_file_s regs;
    assign regs.IF = mmio_interrupts.IF;
    assign regs.IE = mmio_interrupts.IE;
    assign regs_out = regs;

    logic cpu_died;
    cpu _cpu(clk, rst, regs, mmu_if, cpu_died);

    initial begin
        $timeformat(-9, 2, " ns", 20);
    end

    /* CPU Watchdog */
    logic[2:0] zombie_cnt;
    always_ff @(posedge clk) begin
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
            regs.AF, regs.BC, regs.DE, regs.HL, regs.SP, regs.PC);

        $fwrite(fd, "\nSECTION MMIO\n");
        $fwrite(fd, "DIV   TAC   TMA   TIMA\n");
        tmp = mmio_timer.sys_counter-4;
        $fwrite(fd, "%02x    %02x    %02x   %02x\n", 
            (tmp >> 8) & 8'hff, mmio_timer.tac, mmio_timer.tma, mmio_timer.tima);

        $fwrite(fd, "\nSECTION SYS\n");
        $fwrite(fd, "totalclks    divider\n");
        tmp = mmio_timer.sys_counter-4;
        $fwrite(fd, "%08x     %08x\n", _cpu.totalclks, tmp);

        $fwrite(fd, "\nSECTION MEM\n");
        // in order for the below to compile you have to 
        // add `-L blk_mem_gen_v8_4_4_inst` to xevlog.exe

        // VRAM, EXTRAM, WRAM, OAM, HRAM
        num_bytes = 'h2000 + 'h2000 + 'h1000 + 'h1000 + 128 + 160;
        num_lines = num_bytes / cols_per_line;
        for (int i = 0; i < num_lines; i++) begin
            automatic int addr = 'h8000 + i * cols_per_line; 
            automatic int section = 0;
            if (addr >= 'h8000 && addr < 'hA000) section = 0; 
            if (addr >= 'hA000 && addr < 'hC000) section = 1; 
            if (addr >= 'hC000 && addr < 'hE000) section = 2; 
            if (addr >= 'hE000 && addr < 'hE0A0) begin
                section = 3; addr = addr + 'h1E00;
            end
            if (addr >= 'hE0A0 && addr < 'hE120) begin 
                section = 4; addr = addr + 'h1EE0;
            end

            $fwrite(fd, "%s:%04x  ", sections[section], addr);
            for (int j = 0; j < cols_per_line; j++) 
                $fwrite(fd, "%02x ", 
                    mram.unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory[cols_per_line * i + j]);
            $fwrite(fd, "\n");
        end

        num_bytes = 'h8000;
        num_lines = num_bytes / cols_per_line;
        for (int i = 0; i < num_lines; i++) begin
            $fwrite(fd, "ROM0:%04x  ", i * cols_per_line);
            for (int j = 0; j < cols_per_line; j++) 
                $fwrite(fd, "%02x ", 
                    rom.unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory[cols_per_line * i + j]);
            $fwrite(fd, "\n");
        end

    end
    endtask 

endmodule






