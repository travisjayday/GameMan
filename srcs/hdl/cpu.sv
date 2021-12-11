`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:             ApeGang
// Engineer:            Travis, Ahmad, and Raiphy  
// 
// Create Date:         10/14/2021 12:10:42 AM
// Design Name:         SM80 GameBoy CPU
// Module Name:         cpu 
// Project Name:        GameMan
// Target Devices:      Nexys A7 FPGA
// Tool Versions:       Vivado 2021.1
// Description:         The main CPU FSM
// 
// Dependencies:A       None 
// 
// Revision:           
// Revision 0.01 - File Created
// Additional Comments:
// Ooga booga
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu_m import cpu_defs::*;(
    input wire clk, 
    input wire rst,
    mem_if.master mmu,
    input wire[7:0] mmio_reg_IF,
    input wire[7:0] mmio_reg_IE,
    output logic cpu_died,
    output reg_file_s regs_out 
);

    /* Register file read / write lines */
    reg_file_s regs;
    assign regs_out = regs;
    assign regs.IF = mmio_reg_IF;
    assign regs.IE = mmio_reg_IE;
    reg_select_t reg_wr_select; 
    logic[15:0] reg_wr_value; 
    flags_s flags; 

    /* CPU state */
    logic[15:0] read_val; 
    logic[31:0] totalclks;
    logic[7:0] val;
    logic[7:0] inst;
    assign out = totalclks;

    // Check if an interrupt will be executed at next opportunity
    logic interrupt_happening; 
    assign interrupt_happening = regs.IME && (regs.IF & regs.IE);

    // Instruction is always the output of MMU
    assign inst = mmu.read_out;
    decoded_action_s decoded_action;
    decoder_m decoder(clk, rst, inst, flags, interrupt_happening? regs.IF : 8'b00, decoded_action);

    // Main state for CPU FSM
    cpu_state_t cpu_state;

    logic [11:0] alu_res8; 
    logic [19:0] alu_res16; 

    always_ff @(posedge clk) begin
        if (rst) begin
            totalclks <= 4; 
            val <= 16;
            cpu_state <= DECODE;
            cpu_died <= 0; 
            flags <= 0; 
            reg_wr_select <= REG_UNKOWN;
            reg_wr_value <= 0; 
            mmu.write_enable <= 0; 
            mmu.addr_select <= regs.PC; 
        end else begin
            // See http://www.z80.info/z80arki.htm for overlapping execution model
            // Each state is commented with it's T-state from the diagram

            // Cycle State: T3
            //  M1 - Fetch
            if (cpu_state == FETCH) begin
                // fetch new instruction
                cpu_state <= DECODE;

                if (decoded_action.act == CPU_ENABLE_INTERRUPTS) write_reg8(REG_IME, 1);
            end
            // Cycle State: T4 
            //  M1 - Execute
            else if (cpu_state == DECODE) begin
                // decode instruction (decode -> execute transition is where machine cycle starts)
                cpu_state <= EXECUTE;
            end 
            // Cycle State: T1 
            //  M1 - Execute    
            //  M2 - Fetch      (Start of instruction M2)
            else if (cpu_state == EXECUTE) begin
                // execute instruction
                case (decoded_action.act)
                    WRITE_REG8_IMM: begin
                        write_reg8(reg_select_t'(decoded_action.dst), decoded_action.arg);

                        // short circuit if writing to PC 
                        if (decoded_action.dst == REG_PC_C) begin
                            mmu.addr_select <= { read_reg8(REG_PC_P), decoded_action.arg };
                        end else if (decoded_action.dst == REG_PC_P) begin
                            mmu.addr_select <= { decoded_action.arg, read_reg8(REG_PC_C) };
                        end else begin
                            mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        end
                        mmu.write_enable <= 0; 
                    end
                    WRITE_REG16_IMM: begin
                        // arg + src concat make up 16 bit value to write to 16 bit reg
                        write_reg16(reg_select_t'(decoded_action.dst), 
                            {decoded_action.arg, decoded_action.src});
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                        // intercept write to AF
                        if (reg_select_t'(decoded_action.dst) == REG_AF) begin
                            flags <= decoded_action.src[7:4];
                        end
                    end
                    WRITE_REG8_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst), 
                            read_reg8(reg_select_t'(decoded_action.src))
                        );
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    WRITE_REG16_REG16: begin
                        write_reg16(
                            reg_select_t'(decoded_action.dst), 
                            read_reg16(reg_select_t'(decoded_action.src))
                        );
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    WRITE_MEM8_IMM: begin
                        // initiate memory write.
                        mmu.addr_select <= read_reg16(reg_select_t'(decoded_action.dst));
                        mmu.write_value <= decoded_action.src;
                        mmu.write_enable <= 1'b1; 
                    end
                    WRITE_MEM8_HRAM: begin
                        mmu.addr_select <= { 8'hff, read_reg8(reg_select_t'(decoded_action.dst)) };
                        mmu.write_value <= read_reg8(reg_select_t'(decoded_action.src));
                        mmu.write_enable <= 1'b1;
                    end
                    CPU_DISABLE_INTERRUPTS: begin
                        // set IME=0
                        write_reg8(REG_IME, 0);

                        // set IF=new IF
                        mmu.addr_select <= 16'hFF0F;
                        mmu.write_value <= decoded_action.src;
                        mmu.write_enable <= 1'b1;
                    end
                    WRITE_MEM8_REG8: begin
                        // initiate memory write. If arg is 1 pre-increment dest addrs 
                        mmu.addr_select <= 
                            decoded_action.arg == 1? 
                                read_reg16(reg_select_t'(decoded_action.dst)) + 1 :
                            decoded_action.arg == 2? 
                                read_reg16(reg_select_t'(decoded_action.dst)) - 1 : 
                                read_reg16(reg_select_t'(decoded_action.dst));

                        mmu.write_value <= read_reg8(
                            reg_select_t'(decoded_action.src)
                        );
                        mmu.write_enable <= 1'b1; 

                        // if arg is set, decrement dst register address
                        if (decoded_action.arg == 2) begin
                            write_reg16(
                                reg_select_t'(decoded_action.dst),
                                -2 + read_reg16(reg_select_t'(decoded_action.dst))
                            );
                        end
                    end
                    WRITE_MEM8_REG8_WZ: begin
                        // initiate memory write 
                        mmu.addr_select <= 
                            decoded_action.dst == 0? 
                                { decoded_action.arg, read_reg8(REG_Z) } : 
                                { read_reg8(REG_W), decoded_action.arg };
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
                    WRITE_MEM8_REG8_ALU_HL: begin
                        // initiate memory write if writing is requested
                        if (decoded_action.next_pc == 0) begin
                            mmu.addr_select <= read_reg16(REG_HL);
                            mmu.write_enable <= 1'b1; 
                        end
                        // or skip the write (for BIT [hl] instruction)
                        else begin
                            mmu.addr_select <= read_reg16(REG_PC) + 1; 
                            mmu.write_enable <= 0; 
                        end

                        // Do pre-ALU function on write value (increment or decremnt (used for INC(HL)))
                        {flags, mmu.write_value} <= alu_op8(
                            .op(alu_op_t'(decoded_action.arg)),
                            .dst(decoded_action.dst),
                            .src(decoded_action.src)
                        );
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
                    READ_MEM8_IMM: begin
                        // Initiate memory read 
                        mmu.addr_select <=
                            decoded_action.dst == 0? 
                                { decoded_action.arg, decoded_action.src } : 
                                { decoded_action.arg, read_reg8(reg_select_t'(decoded_action.src)) };
                        mmu.write_enable <= 1'b0; 
                    end
                    ALU_IMM8: begin
                        alu_res8 = alu_op8(
                            .op(alu_op_t'(decoded_action.arg)), 
                            .dst(read_reg8(reg_select_t'(decoded_action.dst))),
                            .src(decoded_action.src)
                        );
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_res8[7:0]
                        );
                        flags <= alu_res8[11:8];
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    ALU_REG8: begin
                        alu_res8 = alu_op8(
                            .op(alu_op_t'(decoded_action.arg)), 
                            .dst(read_reg8(reg_select_t'(decoded_action.dst))), 
                            .src(read_reg8(reg_select_t'(decoded_action.src)))
                        );
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu_res8[7:0]
                        );
                        flags <= alu_res8[11:8];
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    ALU_REG16: begin
                        alu_res16 = alu_op16(
                            alu_op_t'(decoded_action.arg), 
                            read_reg16(reg_select_t'(decoded_action.dst)), 
                            read_reg16(reg_select_t'(decoded_action.src))
                        );
                        write_reg16(
                            reg_select_t'(decoded_action.dst), 
                            alu_res16[15:0]
                        );
                        flags <= alu_res16[19:16];
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    CPU_NOP: begin
                        mmu.addr_select <= read_reg16(REG_PC) + 1; 
                        mmu.write_enable <= 0; 
                    end
                    CPU_DIE: begin
                        cpu_died <= 1; 
                    end
                    FLOW_JR: begin
                        mmu.addr_select <= 
                            read_reg8(REG_Z) >= 128? 
                                read_reg16(REG_PC) - (256 - read_reg8(REG_Z)) :
                                read_reg16(REG_PC) + read_reg8(REG_Z);
                        mmu.write_enable <= 0; 
                    end
                    FLOW_JMP: begin
                        mmu.addr_select <= read_reg16(reg_select_t'(decoded_action.arg));
                        mmu.write_enable <= 0; 
                    end
                    FLOW_JMP_IMM: begin
                        mmu.addr_select <= { decoded_action.arg, decoded_action.src };
                        mmu.write_enable <= 0; 
                    end
                endcase
                cpu_state <= FLOW;
            end
            // Cycle State: T2
            //  M1 - Execute    (End of instruction M1)
            //  M2 - Fetch
            else if (cpu_state == FLOW) begin
                cpu_state <= FETCH;
                if (decoded_action.next_pc) begin
                    write_reg16(REG_PC, mmu.addr_select);
                end
            end

            totalclks <= totalclks + 1; 
        end
    end


    `include "alu.sv"
    `include "regs.sv"

endmodule

