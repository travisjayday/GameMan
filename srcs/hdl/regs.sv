//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2021 01:53:05 PM
// Design Name: 
// Module Name: regs
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


/*module regs_m import cpu_defs::*;(
    input wire clk, 
    input wire rst,
    input reg_select_t wr_select, 
    input wire [15:0] wr_value
);*/

/* Helper tasks */
task write_reg16;
    input reg_select_t dest;
    input logic[15:0] val;
begin
    reg_wr_select <= dest; 
    reg_wr_value <= val;
end
endtask

task write_reg8;
    input reg_select_t dest;
    input logic[7:0] val;
begin
    reg_wr_select <= dest; 
    reg_wr_value <= {7'b0, val};
end
endtask

/* Combinationally read an 16 bit register value */
function [15:0] read_reg16;
    input reg_select_t rd_select;
    logic[15:0] rd_out;
    begin
        case (rd_select) 
            REG_AF: rd_out = regs.AF;
            REG_BC: rd_out = regs.BC;
            REG_DE: rd_out = regs.DE;
            REG_HL: rd_out = regs.HL;
            REG_SP: rd_out = regs.SP;
            REG_PC: rd_out = regs.PC;
            REG_WZ: rd_out = regs.WZ;
            default:     rd_out = 'hdead; 
        endcase
        read_reg16 = rd_out;
    end 
endfunction

/* Combinationally read an 8 bit register value */
function [7:0] read_reg8;
    input reg_select_t rd_select;
    logic[7:0] rd_out;
    begin
        case (rd_select) 
            REG_A: rd_out = regs.AF[15:8];
            REG_F: rd_out = regs.AF[7:0];
            REG_B: rd_out = regs.BC[15:8];
            REG_C: rd_out = regs.BC[7:0];
            REG_D: rd_out = regs.DE[15:8];
            REG_E: rd_out = regs.DE[7:0];
            REG_H: rd_out = regs.HL[15:8];
            REG_L: rd_out = regs.HL[7:0];
            REG_S: rd_out = regs.SP[15:8];
            REG_P: rd_out = regs.SP[7:0];
            REG_W: rd_out = regs.WZ[15:8];
            REG_Z: rd_out = regs.WZ[7:0];
            REG_PC_P: rd_out = regs.PC[15:8];
            REG_PC_C: rd_out = regs.PC[7:0];
            default:     rd_out = 'hdead; 
        endcase
        read_reg8 = rd_out;
    end 
endfunction

/* Assign flags register values */
assign regs.AF[7:4] = flags;

logic[4:0] schedule_IME = 0;

/* Sequentially write register values depending on 
    Moduel input: register[wr_select] <= wr_value;
*/
always_ff @(negedge clk) begin
    if (rst) begin
        regs.PC <= 16'h0000;  // E000
        regs.AF[15:8] <= 0; 
        regs.AF[3:0] <= 0; 
        regs.BC <= 0; 
        regs.DE <= 0; 
        regs.HL <= 0; 
        regs.SP <= 0; 
        regs.WZ <= 0; 
        regs.IME <= 0; 
    end else begin
        case (reg_wr_select) 
            REG_AF: begin 
                // If write to AF, update flags. See Pop AF instruction.
                regs.AF[15:8] <= reg_wr_value[15:8];
            end
            REG_BC: regs.BC <= reg_wr_value;
            REG_DE: regs.DE <= reg_wr_value; 
            REG_HL: regs.HL <= reg_wr_value; 
            REG_SP: regs.SP <= reg_wr_value; 
            REG_PC: regs.PC <= reg_wr_value;
            REG_WZ: regs.WZ <= reg_wr_value;
            REG_A:  regs.AF[15:8] <= reg_wr_value[7:0]; //, regs.AF[7:0] };
            REG_B:  regs.BC <= { reg_wr_value[7:0], regs.BC[7:0] }; 
            REG_C:  regs.BC <= { regs.BC[15:8], reg_wr_value[7:0] }; 
            REG_D:  regs.DE <= { reg_wr_value[7:0], regs.DE[7:0] };
            REG_E:  regs.DE <= { regs.DE[15:8], reg_wr_value[7:0] }; 
            REG_H:  regs.HL <= { reg_wr_value[7:0], regs.HL[7:0] }; 
            REG_L:  regs.HL <= { regs.HL[15:8], reg_wr_value[7:0] };
            REG_S:  regs.SP <= { reg_wr_value[7:0], regs.SP[7:0] };
            REG_P:  regs.SP <= { regs.SP[15:8], reg_wr_value[7:0] };
            REG_W:  regs.WZ <= { reg_wr_value[7:0], regs.WZ[7:0] };
            REG_Z:  regs.WZ <= { regs.WZ[15:8], reg_wr_value[7:0] };
            REG_PC_P:  regs.PC <= { reg_wr_value[7:0], regs.PC[7:0] };
            REG_PC_C:  regs.PC <= { regs.PC[15:8], reg_wr_value[7:0] };
            REG_IME:   begin
                // If wrote 1, schedule IME to be enabled next machine cycle
                if (reg_wr_value[0]) schedule_IME <= 4; 
                else begin
                    // If wrote 0, cancel IME enable and set IME to zero
                    regs.IME <= 0; 
                    schedule_IME <= 0; 
                end
            end
            default:      begin end // REG_WRITE_NOP 
        endcase

        // Check if should enable IME 
        if (schedule_IME > 0 && reg_wr_select != REG_IME) begin
            if (schedule_IME == 1) begin
                regs.IME <= 1; 
            end
            schedule_IME <= schedule_IME - 1; 
        end
    end
end 

