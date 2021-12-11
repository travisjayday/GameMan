`default_nettype none

module top_level import cpu_defs::*;(
    input wire clk_100mhz, 
    input wire[15:0] sw,
    output logic[15:0] led,
    output logic aud_pwm,
    output logic aud_sd,
    inout  wire      [7:0]       ja,              // ja : d[7:0]
    output logic     [7:0]       jb,              // jb : a[7:0]
    output logic     [7:0]       jc,              // 0:reset, 1:cs, 2:rd, 3:wr, 4:clk. 5-7:nc
    output logic     [7:0]       jd,              // jd : a[15:8]
    input wire       [7:0]       je,               // controlsinput wire [7:0] je,
    output logic [5:0] led16,
    output logic[3:0] vga_r,
    output logic[3:0] vga_b,
    output logic[3:0] vga_g,
    output logic vga_hs,
    output logic vga_vs
    );
    logic rst;
    assign rst = sw[15];

    reg_file_s regs_out;
  
    logic clk_4mhz; 
    clk_wiz_1 _25mhz_to_4mhz(vclock, clk_4mhz);  //TODO: create a clock wizard ip named clk_wiz_1 that tkes 25.17401 MHz and outputs 4.69MHz. disable the locked and reset i/o

    mem_if ppu_oam_if();    // Busmaster 2
    mem_if ppu_vram_if();   // Busmaster 3

    // Contains:    Cartridge ROM
    // Size:        32KB 
    mem_if nop(); 

    mem_if rom_if(); 
    bram_32k_rom_m rom(clk_4mhz, nop);

    cart_if cart(
                    .clk(clk_4mhz),
                    .rst(rst),
                    .rom_if(rom_if),
                    
                    .clk_out(jc[4]),
                    .n_rst_out(jc[0]),
                    .n_write_enable_out(jc[3]),
                    .n_read_enable_out(jc[2]),
                    .n_cs_out(jc[1]),
                    .addr_out({jd,jb}),
                    .data_out(ja)
                    );

    // WRAM: Size 8KB
    mem_if wram_if(); 
    bram_main_ram_m wram (clk_4mhz, wram_if);

    // VRAM: Size: 8KB
    mem_if vram_if(); 
    bram_vram_m vram (clk_4mhz, vram_if, ppu_vram_if);

    // OAM: Size: 160B
    mem_if oam_if(); 
    bram_oam_m oam (.clk(clk_4mhz), .in(oam_if), .ppu_in(ppu_oam_if));

    // HRAM: Size: 127B
    mem_if hram_if(); 
    bram_hram_m hram (clk_4mhz, hram_if);

    mem_if bootrom_if(); 
    bram_bootrom_m bootrom(clk_4mhz, bootrom_if);

    // Interrupt Handler Module 
    // Sets IF flag for CPU. Handles writes and reads to IF and IE cpu.regs. 
    // 0xFFFF - IE (R/W)
    // 0xFF05 - IF (R/W)
    interrupt_lines_s interrupts; 
    // For now, pull other interrupts low
    assign interrupts.joypad = 0; 
    mem_if mmio_interrupts_if(); 
    mmio_interrupts_m mmio_interrupts(clk_4mhz, rst, mmio_interrupts_if, interrupts);

    // 0xFF04 - Divider Regiser (R/W)
    logic[31:0] sys_counter;
    mem_if mmio_timer_if();
    mmio_timer_m mmio_timer(clk_4mhz, rst, mmio_timer_if, interrupts.timer, sys_counter);

    // APU
    logic pwm_val;
    mem_if mmio_apu_if();
    mmio_apu_m mmio_apu(clk_4mhz, rst, mmio_apu_if, sys_counter, pwm_val);
    assign aud_pwm = pwm_val ? 1'bZ : 1'b0; 
    assign aud_sd = 1;

    logic [1:0] pixel_out;

    //DEBUG

    // 0xFF00 - Joypad 
    mem_if mmio_joypad_if();
    mmio_joypad_m joypad(clk_4mhz, rst, je, mmio_joypad_if);

    assign led = regs_out.PC;

    // PPU
    mem_if mmio_ppu_if();      
    logic [15:0] lcd_addr;
    logic lcd_wr;
    logic vclock;
    logic [14:0] lcd_addrb;
    logic [1:0] pixel_to_vga;
    mmio_ppu_m the_ppu(
        .clk(clk_4mhz),
        .rst(rst),
        .req(mmio_ppu_if),
        .ppu_oam_req(ppu_oam_if),
        .ppu_vram_req(ppu_vram_if),
        .pixel_out(pixel_out),
        .lcd_a(lcd_addr),
        .lcd_wr(lcd_wr),
        .vblank_interrupt(interrupts.vblank),
        .statline_interrupt(interrupts.lcd_stat)
    );
    //LCD AKA SCREEN BUFFER
    ram_lcd lcd(            
        .addra(lcd_addr[14:0]),
        .clka(clk_4mhz),
        .dina(pixel_out),
        .wea(lcd_wr),
        .addrb(lcd_addrb),
        .clkb(vclock),
        .doutb(pixel_to_vga)
    );
    //VGA
    vga_master vga(
        .clk_100mhz(clk_100mhz),
        .rst(0),
        .vga_r(vga_r),
        .vga_b(vga_b),
        .vga_g(vga_g),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .addrb(lcd_addrb),
        .clkb(vclock),
        .doutb(pixel_to_vga)
        
        );
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
        .mmio_dma_if(mmio_dma_if),
        .mmio_apu_if(mmio_apu_if),
        .mmio_ppu_if(mmio_ppu_if),
        .mmio_joypad_if(mmio_joypad_if),
        .bootrom_if(bootrom_if)
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
        //`PRINT_MEM("ROM0", rom,  'h8000);
    end
    endtask 

endmodule
`default_nettype wire
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
