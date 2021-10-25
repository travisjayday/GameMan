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

module cpu import cpu_defs::*;(
    input wire clk, 
    input wire rst,
    input reg_file_s regs,
    bram_if.master wram 
    );

    /* Register file */
    reg_select_t reg_wr_select; 
    logic[15:0] reg_wr_value; 

    /* CPU state */
    logic[15:0] read_val; 
    logic[7:0] cnt;
    logic[7:0] val;

    logic[7:0] inst;
    assign inst = wram.read_out;
    decoded_action_s decoded_action;
    decoder_m decoder(clk, rst, inst, decoded_action);

    cpu_state_t cpu_state;

    flags_s flags; 
    logic skip_next_fetch; 

    assign out = cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0; 
            val <= 16;
            cpu_state <= FLOW;
        end else begin

            if (cpu_state == FETCH) begin
                // fetch new instruction
                cpu_state <= DECODE;
            end
            else if (cpu_state == DECODE) begin
                // decode instruction (decode -> execute transition is where machine cycle starts)
                cpu_state <= EXECUTE;
            end 
            else if (cpu_state == EXECUTE) begin
                // execute instruction
                case (decoded_action.act)
                    WRITE_REG8_IMM: begin
                        write_reg8(reg_select_t'(decoded_action.dst), decoded_action.arg);
                    end
                    WRITE_REG8_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst), 
                            read_reg8(reg_select_t'(decoded_action.src))
                        );
                    end
                    WRITE_MEM8_IMM: begin
                        // initiate memory write 
                        wram.addr_select <= read_reg16(
                            reg_select_t'(decoded_action.dst)
                        );
                        wram.write_value <= read_reg8(
                            reg_select_t'(decoded_action.src)
                        );
                        wram.write_enable <= 1'b1; 
                    end
                    READ_MEM8: begin
                        // Initiate memory read 
                        wram.addr_select <= read_reg16(
                            reg_select_t'(decoded_action.src)
                        );
                        wram.write_enable <= 1'b0; 
                    end
                    ALU_IMM8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_op8(
                                alu_op_t'(decoded_action.arg), 
                                read_reg8(reg_select_t'(decoded_action.dst)), 
                                decoded_action.src
                            )
                        );
                    end
                    ALU_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_op8(
                                alu_op_t'(decoded_action.arg), 
                                read_reg8(reg_select_t'(decoded_action.dst)), 
                                read_reg8(reg_select_t'(decoded_action.src))
                            )
                        );
                    end
                    CPU_NOP: begin
                        
                    end
                    CPU_DIE: begin
                        $display("CPU dying...");
                        $finish;
                    end
                endcase
                cpu_state <= FLOW;
            end
            else if (cpu_state == FLOW) begin
                // move PC and start fetch
                if (decoded_action.next_pc) begin
                    write_reg16(REG_PC, read_reg16(REG_PC) + 1);
                    wram.addr_select <= read_reg16(REG_PC) + 1;
                end
                wram.write_enable <= 1'b0;
                cpu_state <= FETCH;
            end

            cnt <= cnt + 1; 
        end
    end


    `include "alu.sv"
    `include "regs.sv"

endmodule

