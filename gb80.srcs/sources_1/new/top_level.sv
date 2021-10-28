module top_level import cpu_defs::*;(
    input wire clk, 
    input wire[15:0] sw
    );

    // Memory Mapping Unit
    mem_if mmu_if(); 
    mmu_m mmu(clk, mmu_if);

    reg_file_s regs;
    logic cpu_died;
    cpu _cpu(clk, sw[15], regs, mmu_if, cpu_died);

    /* CPU Watchdog */
    always_comb begin
        if (cpu_died == 1'b1) begin
            $display("CPU Died!");
`ifndef SYNTHESIS
            dump_system_state();
`endif
            $finish;
        end
    end

    task dump_system_state();
        automatic int fd;
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
                    mmu.mram.unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory[cols_per_line * i + j]);
            $fwrite(fd, "\n");
        end

        num_bytes = 'h8000;
        num_lines = num_bytes / cols_per_line;
        for (int i = 0; i < num_lines; i++) begin
            $fwrite(fd, "ROM0:%04x  ", i * cols_per_line);
            for (int j = 0; j < cols_per_line; j++) 
                $fwrite(fd, "%02x ", 
                    mmu.rom.unit.inst.\native_mem_module.blk_mem_gen_v8_4_4_inst .memory[cols_per_line * i + j]);
            $fwrite(fd, "\n");
        end

    end
    endtask 

endmodule






