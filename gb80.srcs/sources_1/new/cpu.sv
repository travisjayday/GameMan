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

    typedef enum logic[3:0] 
    { 
        REG_AF, REG_BC, REG_DE, REG_HL, REG_SP, REG_PC, 
        REG_A, REG_B, REG_C, REG_D, REG_E, REG_H, REG_L, REG_UNKOWN 
    } reg_select_t;


    typedef enum {
        WRITE_REG16_IMM, WRITE_REG8_IMM, WRITE_REG8_REG8, 
        WRITE_MEM8_IMM, READ_MEM, 
        ALU_IMM8, ALU_REG8, CPU_NOP, CPU_STALL_PC, DIE
    } action;

    typedef enum {
        FETCH, DECODE, EXECUTE, FLOW
    } cpu_state_t;

    typedef struct packed {
        action act;
        logic[7:0] src;
        logic[7:0] dst;
        logic[7:0] arg;
    } decoded_action_s;

    typedef struct packed {
        logic Z;
        logic N;
        logic H; 
        logic C; 
    } flags_s; 

    typedef enum {
        ALU_OP_ADD, ALU_OP_SUB, ALU_OP_OR
    } alu_op_t;

endpackage

module cpu import cpu_defs::*;(
    input wire clk, 
    input wire rst
    );

    /* Register file */
    reg_select_t reg_wr_select; 
    logic[15:0] reg_wr_value; 
    regs_m regs(clk, rst, reg_wr_select, reg_wr_value);


    /* Work RAM */ 
    logic [15:0] wram_addr_select;
    logic wram_wr_select;
    logic [7:0] wram_rd_out;
    logic [7:0] wram_wr_value;
    mem_m #(512) wram (
        clk, rst, 
        wram_addr_select, wram_wr_select, wram_rd_out, wram_wr_value
    );

    /* CPU state */
    logic[15:0] read_val; 
    logic[7:0] cnt;
    logic[7:0] val;

    logic[7:0] inst;
    assign inst = wram_rd_out;
    decoded_action_s decoded_action;
    decoder_m decoder(clk, rst, inst, decoded_action);

    cpu_state_t cpu_state;

    flags_s flags; 
    alu_m alu(rst, flags);

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= 0; 
            val <= 16;
            cpu_state <= FETCH;
        end else begin
            // fetch next instruction every four clock cycles

            if      (cpu_state == FETCH) begin
                // fetch new instruction
                wram_addr_select <= regs.read_reg16(REG_PC);
                wram_wr_select <= 1'b0;

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
                            regs.read_reg8(reg_select_t'(decoded_action.src))
                        );
                    end
                    WRITE_MEM8_IMM: begin
                        // initiate memory write 
                        wram_addr_select <= regs.read_reg16(
                            reg_select_t'(decoded_action.dst)
                        );
                        wram_wr_value <= regs.read_reg8(
                            reg_select_t'(decoded_action.src)
                        );
                        wram_wr_select <= 1'b1; 
                    end
                    ALU_IMM8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu.op8(
                                alu_op_t'(decoded_action.arg), 
                                regs.read_reg8(reg_select_t'(decoded_action.dst)), 
                                decoded_action.src
                            )
                        );
                    end
                    ALU_REG8: begin
                        write_reg8(
                            reg_select_t'(decoded_action.dst),
                            alu.op8(
                                alu_op_t'(decoded_action.arg), 
                                regs.read_reg8(reg_select_t'(decoded_action.dst)), 
                                regs.read_reg8(reg_select_t'(decoded_action.src))
                            )
                        );
                    end
                    CPU_STALL_PC: begin
                        write_reg16(REG_PC, regs.read_reg16(REG_PC) - 1);
                    end
                    CPU_NOP: begin
                        
                    end
                    DIE: begin
                        $display("CPU dying...");
                        $finish;
                    end
                endcase
                cpu_state <= FLOW;
            end
            else if (cpu_state == FLOW) begin
                // increment PC 
                write_reg16(REG_PC, regs.read_reg16(REG_PC) + 1);

                // Stop writing to ram 
                if (wram_wr_select) wram_wr_select <= 0; 

                cpu_state <= FETCH;
            end

            cnt <= cnt + 1; 
        end
    end

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
        reg_wr_value <= {8'b0, val};
    end
    endtask
endmodule

module regs_m import cpu_defs::*;(
    input wire clk, 
    input wire rst,
    input reg_select_t wr_select, 
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
        input reg_select_t rd_select;
        logic[15:0] rd_out;
        begin
            case (rd_select) 
                REG_AF: rd_out = AF;
                REG_BC: rd_out = BC;
                REG_DE: rd_out = DE;
                REG_HL: rd_out = HL;
                REG_SP: rd_out = SP;
                REG_PC: rd_out = PC;
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
                REG_A: rd_out = AF[15:8];
                REG_B: rd_out = BC[15:8];
                REG_C: rd_out = BC[7:0];
                REG_D: rd_out = DE[15:8];
                REG_E: rd_out = DE[7:0];
                REG_H: rd_out = HL[15:8];
                REG_L: rd_out = HL[7:0];
                default:     rd_out = 'hdead; 
            endcase
            read_reg8 = rd_out;
        end 
    endfunction

    /* Sequentially write register values depending on 
        Moduel input: register[wr_select] <= wr_value;
    */
    always_ff @(negedge clk) begin
        if (rst) begin
            PC <= 16'h100; 
            AF <= 0; 
            BC <= 0; 
            DE <= 0; 
            HL <= 0; 
            SP <= 0; 
        end else begin
            case (wr_select) 
                REG_AF: AF <= wr_value; 
                REG_BC: BC <= wr_value;
                REG_DE: DE <= wr_value; 
                REG_HL: HL <= wr_value; 
                REG_SP: SP <= wr_value; 
                REG_PC: PC <= wr_value;
                REG_A:  AF <= { wr_value[7:0], AF[7:0] };
                REG_B:  BC <= { wr_value[7:0], BC[7:0] }; 
                REG_C:  BC <= { BC[15:8], wr_value[7:0] }; 
                REG_D:  DE <= { wr_value[7:0], DE[7:0] };
                REG_E:  DE <= { DE[15:8], wr_value[7:0] }; 
                REG_H:  HL <= { wr_value[7:0], HL[7:0] }; 
                REG_L:  HL <= { HL[15:8], wr_value[7:0] };
                default:      begin end // REG_WRITE_NOP 
            endcase
        end
    end 

endmodule 
