module top_level import cpu_defs::*;(
    input wire clk, 
    input wire[15:0] sw
    );

    reg_file_s regs;
    bram_if wram_if(); 

    ram_unit wram(clk, wram_if);
    cpu _cpu(clk, sw[15], regs, wram_if);

endmodule