`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2021 12:10:42 AM
// Design Name: 
// Module Name: cpu
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

package cpu_defs;
    typedef enum 
    { REG_READ_AF, REG_READ_BC, REG_READ_DE, REG_READ_HL, REG_READ_SP, 
      REG_READ_A, REG_READ_B, REG_READ_C, REG_READ_D, REG_READ_E, 
      REG_READ_H, REG_READ_L,
      REG_READ_PC 
    } reg_read_t;

    typedef enum logic[3:0] 
    { REG_WRITE_AF, REG_WRITE_BC, REG_WRITE_DE, REG_WRITE_HL, REG_WRITE_SP, REG_WRITE_PC, 
      REG_WRITE_A, REG_WRITE_B, REG_WRITE_C, REG_WRITE_D, REG_WRITE_E, REG_WRITE_L, REG_WRITE_H, 
      REG_WRITE_NOP 
    } reg_write_t;
endpackage

module cpu import cpu_defs::*;(
    input wire clk, 
    input wire rst
    );

    /* Register file */
    reg_write_t reg_wr_select; 
    logic[15:0] reg_wr_value; 
    regs_m regs(clk, rst, reg_wr_select, reg_wr_value);


    /* Work RAM */ 
    logic [7:0] wram_addr_select;
    logic wram_wr_select;
    logic [7:0] wram_rd_out;
    logic [7:0] wram_wr_in;
    mem_m #(512) wram (
        clk, rst, 
        wram_addr_select, wram_wr_select, wram_rd_out, wram_wr_in
    );

    /* CPU state */
    logic[15:0] read_val; 
    logic[7:0] cnt;
    logic[7:0] val;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0; 
            val <= 16;
        end else begin
            // fetch next instruction (will arrive in wram_rd_out next)
            // clock cycle)
            wram_addr_select <= regs.read_reg16(REG_READ_PC);
            wram_wr_in <= 1'b0;

            // decode instruction

           

            // execute instruction

            if (cnt == 0) begin
                write_reg16(REG_WRITE_HL, 16'h1234);
            end else if (cnt == 1) begin
                write_reg8(REG_WRITE_A, 8'hFF);
            end else begin
                write_reg16(REG_WRITE_NOP, 16'h0000);
            end

            cnt <= cnt + 1; 
            val <= val + 1;
        end
    end

    /* Helper tasks */
    task write_reg16;
        input reg_write_t dest;
        input logic[15:0] val;
    begin
        reg_wr_select <= dest; 
        reg_wr_value <= 16'hb00b;
    end
    endtask

    task write_reg8;
        input reg_write_t dest;
        input logic[7:0] val;
    begin
        reg_wr_select <= dest; 
        reg_wr_value <= {8'b0, val};
    end
    endtask
endmodule

module regs_m import cpu_defs::*;(
    input wire clk, 
    input wire rst,
    input reg_write_t wr_select, 
    input wire [15:0] wr_value
);

    /* Register definitions */
    logic [15:0] AF; 
    logic [15:0] BC; 
    logic [15:0] DE; 
    logic [15:0] HL; 
    logic [15:0] SP; 
    logic [15:0] PC; 

    /* Combinationally read an 16 bit register value */
    function [15:0] read_reg16;
        input reg_read_t rd_select;
        logic[15:0] rd_out;
        begin
            case (rd_select) 
                REG_READ_AF: rd_out = AF;
                REG_READ_BC: rd_out = BC;
                REG_READ_DE: rd_out = DE;
                REG_READ_HL: rd_out = HL;
                REG_READ_SP: rd_out = SP;
                REG_READ_PC: rd_out = PC;
                default:     rd_out = 'hdead; 
            endcase
            read_reg16 = rd_out;
        end 
    endfunction

    /* Combinationally read an 8 bit register value */
    function [7:0] read_reg8;
        input reg_read_t rd_select;
        logic[7:0] rd_out;
        begin
            case (rd_select) 
                REG_READ_A: rd_out = AF[15:8];
                REG_READ_B: rd_out = BC[15:8];
                REG_READ_C: rd_out = BC[7:0];
                REG_READ_D: rd_out = DE[15:8];
                REG_READ_E: rd_out = DE[7:0];
                REG_READ_H: rd_out = HL[15:8];
                REG_READ_L: rd_out = HL[7:0];
                default:     rd_out = 'hdead; 
            endcase
            read_reg8 = rd_out;
        end 
    endfunction

    /* Sequentially write register values depending on 
        Moduel input: register[wr_select] <= wr_value;
    */
    always_ff @(posedge clk) begin
        if (rst) begin
            PC <= 0; 
            AF <= 0; 
            BC <= 0; 
            DE <= 0; 
            HL <= 0; 
            SP <= 0; 
        end else begin
            case (wr_select) 
                REG_WRITE_AF: AF <= wr_value; 
                REG_WRITE_BC: BC <= wr_value;
                REG_WRITE_DE: DE <= wr_value; 
                REG_WRITE_HL: HL <= wr_value; 
                REG_WRITE_SP: SP <= wr_value; 
                REG_WRITE_PC: PC <= wr_value;
                REG_WRITE_A:  AF <= { wr_value[7:0], AF[7:0] };
                REG_WRITE_B:  BC <= { wr_value[7:0], BC[7:0] }; 
                REG_WRITE_C:  BC <= { BC[15:8], wr_value[7:0] }; 
                REG_WRITE_D:  DE <= { wr_value[7:0], DE[7:0] };
                REG_WRITE_E:  DE <= { DE[15:8], wr_value[7:0] }; 
                REG_WRITE_H:  HL <= { wr_value[7:0], HL[7:0] }; 
                REG_WRITE_L:  HL <= { HL[15:8], wr_value[7:0] };
                default:      begin end // REG_WRITE_NOP 
            endcase
        end
    end 

endmodule 
