`timescale 1ns / 1ps

module mmio_timer_m(
    input wire clk,
    input wire rst,
    mem_if.slave req,
    output logic interrupt
    );

    /* MMIO Regs */
    logic[31:0] sys_counter;        // 0xFF04
    logic [7:0] tima;               // 0xFF05
    logic [7:0] tma;                // 0xFF06
    logic [2:0] tac;                // 0xFF07

    /* Ouput for each register */
    always_comb begin
        case (req.addr_select) 
            16'hFF04: req.read_out = sys_counter[15:8];
            16'hFF05: req.read_out = tima;
            16'hFF06: req.read_out = tma;
            16'hFF07: req.read_out = {~5'b0, tac[2:0]};
            default:  req.read_out = 8'haa;
        endcase
    end

    /* 0xFF04 - DIV - Divider Register (R/W*) */
    logic[1:0] div_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            sys_counter <= 4; 
            div_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle. Reset counter on next rising edge
            if (div_we_hi == 1) begin
                sys_counter <= 0; 
            end else begin
                sys_counter <= sys_counter + 1;  
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF04) 
                div_we_hi <= div_we_hi + 1;  
            else                  
                div_we_hi <= 0; 
        end
    end

    /* 0xFF05 - TIMA - Timer Counter (R/W) */
    logic [2:0] tima_we_hi; 
    logic [31:0] prev_sys_counter;
    logic [4:0] div_index;
    logic old_tac_en; 
    always_comb begin 
        case (tac[1:0]) 
            2'b00: div_index = 9; 
            2'b01: div_index = 3;
            2'b10: div_index = 5; 
            2'b11: div_index = 7;
        endcase
    end
    assign interrupt =(~(sys_counter[div_index] & tac[2]) & 
                     (prev_sys_counter[div_index] & old_tac_en))  && tima == 8'hff ? 1 : 0;

    always_ff @(posedge clk) begin
        if (rst) begin
            tima <= 0; 
            tima_we_hi <= 0;
            //interrupt <= 0; 
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (tima_we_hi == 1) begin
                tima <= req.write_value;
            end else begin
                // falling edge detector. See /TCAGBD%20(2).pdf page 20 for schematic.
                if (~(sys_counter[div_index] & tac[2]) & 
                     (prev_sys_counter[div_index] & old_tac_en)) begin
                    // increment tima
                    tima <= tima + 1;

                    if (tima == 8'hff) begin
                        //interrupt <= 1; 
                    end
                end
            end

            // keep interrupt high for only one cycle
            //if (interrupt == 1) interrupt <= 0; 

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF05) 
                tima_we_hi <= tima_we_hi + 1;  
            else                  
                tima_we_hi <= 0; 

            // keep track of past sys_counter for falling edge detector
            prev_sys_counter <= sys_counter;
            old_tac_en <= tac[2];
        end
    end

    /* 0xFF06 - TMA - Timer Modulo (R/W) */
    logic [2:0] tma_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            tma <= 0; 
            tma_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (tma_we_hi == 1) begin
                tma <= req.write_value;
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF06) 
                tma_we_hi <= tma_we_hi + 1;  
            else                  
                tma_we_hi <= 0; 
        end
    end

    /* 0xFF07 - TAC - Timer Control (R/W) */
    logic [2:0] tac_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            tac <= 0; 
            tac_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle. Reset counter on next rising edge
            if (tac_we_hi == 1) begin
                tac <= req.write_value[2:0];
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF07) 
                tac_we_hi <= tac_we_hi + 1;  
            else                  
                tac_we_hi <= 0; 
        end
    end
endmodule
