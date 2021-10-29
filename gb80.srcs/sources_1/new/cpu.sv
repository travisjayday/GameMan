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
    mem_if.master mmu,
    output logic cpu_died
);

    /* Register file read / write lines */
    reg_select_t reg_wr_select; 
    logic[15:0] reg_wr_value; 
    flags_s flags; 

    /* CPU state */
    logic[15:0] read_val; 
    logic[7:0] cnt;
    logic[7:0] val;
    logic[7:0] inst;
    assign out = cnt;

    // Instruction is always the output of MMU
    assign inst = mmu.read_out;
    decoded_action_s decoded_action;
    decoder_m decoder(clk, rst, inst, flags, decoded_action);

    // Main state for CPU FSM
    cpu_state_t cpu_state;

    logic [15:0] new_pc; 

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0; 
            val <= 16;
            cpu_state <= DECODE;
            cpu_died <= 0; 
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
                case (cnt == 0? CPU_NOP : decoded_action.act)
                    WRITE_REG8_IMM: begin
                        write_reg8(reg_select_t'(decoded_action.dst), decoded_action.arg);
                    end
                    WRITE_REG16_IMM: begin
                        // arg + src concat make up 16 bit value to write to 16 bit reg
                        write_reg8(reg_select_t'(decoded_action.dst), {decoded_action.arg, decoded_action.src});
                    end
                    WRITE_REG8_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst), 
                            read_reg8(reg_select_t'(decoded_action.src))
                        );
                    end
                    WRITE_MEM8_IMM: begin
                        // initiate memory write.
                        mmu.addr_select <= read_reg16(reg_select_t'(decoded_action.dst));
                        mmu.write_value <= decoded_action.src;
                        mmu.write_enable <= 1'b1; 
                    end
                    WRITE_MEM8_REG8: begin
                        // initiate memory write. If arg is 1 pre-increment dest addrs 
                        mmu.addr_select <= 
                            decoded_action.arg ? 
                                read_reg16(reg_select_t'(decoded_action.dst)) + 1 :
                                read_reg16(reg_select_t'(decoded_action.dst));

                        mmu.write_value <= read_reg8(
                            reg_select_t'(decoded_action.src)
                        );
                        mmu.write_enable <= 1'b1; 

                    end
                    WRITE_MEM8_REG8_WZ: begin
                        // initiate memory write 
                        mmu.addr_select <= { decoded_action.arg, read_reg8(REG_Z)}; 
                        mmu.write_value <= read_reg8(
                            reg_select_t'(decoded_action.src)
                        );
                        mmu.write_enable <= 1'b1; 

                        // Always write arg to internal W register. This is for 16bit memory
                        // moves and is used for ld [imm16], sp. instruction. 
                        write_reg16(
                            reg_select_t'(REG_W),
                            decoded_action.arg
                        );
                    end
                    WRITE_MEM8_REG8_ALU: begin
                        // initiate memory write 
                        mmu.addr_select <= read_reg16(reg_select_t'(decoded_action.dst));
                        // Do ALU increment or decremnt (used for INC(HL))
                        mmu.write_value <= alu_op8(
                            .op(alu_op_t'(decoded_action.arg)),
                            .dst(decoded_action.src),
                            .src(0)
                        );
                        mmu.write_enable <= 1'b1; 
                    end
                    READ_MEM8: begin
                        // Initiate memory read 
                        mmu.addr_select <= read_reg16(
                            reg_select_t'(decoded_action.src)
                        );
                        mmu.write_enable <= 1'b0; 

                        // if arg is set, increment src register address
                        // used for ld a, (hl+) for example
                        if (decoded_action.arg == 1) begin
                            write_reg16(
                                reg_select_t'(decoded_action.src),
                                1 + read_reg16(reg_select_t'(decoded_action.src))
                            );
                        end else if (decoded_action.arg == 2) begin
                            write_reg16(
                                reg_select_t'(decoded_action.src),
                                -1 + read_reg16(reg_select_t'(decoded_action.src))
                            );
                        end
                    end
                    ALU_IMM8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_op8(
                                .op(alu_op_t'(decoded_action.arg)), 
                                .dst(read_reg8(reg_select_t'(decoded_action.dst))),
                                .src(decoded_action.src)
                            )
                        );
                    end
                    ALU_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_op8(
                                .op(alu_op_t'(decoded_action.arg)), 
                                .dst(read_reg8(reg_select_t'(decoded_action.dst))), 
                                .src(read_reg8(reg_select_t'(decoded_action.src)))
                            )
                        );
                    end
                    ALU_REG16: begin
                        write_reg16(
                            reg_select_t'(decoded_action.dst), 
                            alu_op16(
                                alu_op_t'(decoded_action.arg), 
                                read_reg16(reg_select_t'(decoded_action.dst)), 
                                read_reg16(reg_select_t'(decoded_action.src))
                            )
                        );
                    end
                    CPU_NOP: begin
                        
                    end
                    CPU_DIE: begin
                        cpu_died <= 1; 
                    end
                endcase

                case (decoded_action.act) 
                    FLOW_JR: begin
                        new_pc = 
                            decoded_action.arg >= 128? 
                                read_reg16(REG_PC) - (256 - decoded_action.arg) + 1: 
                                read_reg16(REG_PC) + decoded_action.arg + 1;
                    end
                    default: begin
                        new_pc = read_reg16(REG_PC) + 1;  
                    end
                endcase

                // move PC and start fetch if no mem-op happened
                if (decoded_action.act != WRITE_MEM8_REG8       && 
                    decoded_action.act != READ_MEM8             && 
                    decoded_action.act != WRITE_MEM8_REG8_WZ    &&
                    decoded_action.act != WRITE_MEM8_REG8_ALU   &&
                    decoded_action.act != WRITE_MEM8_IMM
                )
                begin
                    if (decoded_action.next_pc) begin
                        mmu.addr_select <= new_pc;
                    end
                    mmu.write_enable <= 1'b0;
                end
                cpu_state <= FLOW;
            end
            else if (cpu_state == FLOW) begin
                cpu_state <= FETCH;
                if (decoded_action.next_pc) begin
                    write_reg16(REG_PC, new_pc);
                end
            end

            cnt <= cnt + 1; 
        end
    end


    `include "alu.sv"
    `include "regs.sv"

endmodule

