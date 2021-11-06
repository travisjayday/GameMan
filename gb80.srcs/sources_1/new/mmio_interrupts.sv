module mmio_interrupts_m import cpu_defs::*;(
    input wire clk,
    input wire rst,
    mem_if.slave req,
    input interrupt_lines_s interrupts
    );

    /* 0xFFFF - IE - Interrupt Enable (R/W) */
    logic [7:0] IE; 
    logic [2:0] IE_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            IE <= 0; 
            IE_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (IE_we_hi == 1) begin
                IE <= req.write_value;
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFFFF) 
                IE_we_hi <= IE_we_hi + 1;  
            else                  
                IE_we_hi <= 0; 
        end
    end

    /* 0xFF0F - IF - Interrupt Flag (R/W) */
    logic [7:0] IF; 
    logic [2:0] IF_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            IF <= 0; 
            IF_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (IF_we_hi == 1) begin
                IF <= req.write_value;
            end else begin
                IF <= {3'b0, 
                    /* Joypad  */ interrupts.joypad   | IF[4], 
                    /* Serial  */ 1'b0, 
                    /* Timer   */ interrupts.timer    | IF[2],
                    /* LCDStat */ interrupts.lcd_stat | IF[1],
                    /* VBlank  */ interrupts.vblank   | IF[0] 
                };
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF0F) 
                IF_we_hi <= IF_we_hi + 1;  
            else                  
                IF_we_hi <= 0; 
        end
    end
endmodule
