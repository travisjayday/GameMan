`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2021 04:48:38 PM
// Design Name: 
// Module Name: instruction_parser
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


task NOP; 
    decoded_action <= CPU_NOP;
    decoded_action.next_pc <= 1; 
endtask

/* 
    Load an imm16 into a reg16 
    - 3 cycle instruction 
*/
task LD_REG16_IMM; 
    input reg_select_t select_hi;
    input reg_select_t select_lo;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 12 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            // Do reg write request.  
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= select_lo;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= select_hi;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/* 
    Load an 8bit register value into an 8bit register
    - 1 machine cycle 
*/
task LD_REG8_REG8; 
    input reg_select_t dst;
    input reg_select_t src;
    begin
        decoded_action.act <= WRITE_REG8_REG8;
        decoded_action.dst <= dst;
        decoded_action.src <= src;
        decoded_action.next_pc <= 1; 
    end
endtask

/* 
    Load an imm8 into a reg8
    - 1 machine cycle
*/
task LD_REG8_IMM; 
    input reg_select_t dst;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 8 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= dst;      // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;     // following instruction is IMM
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/* 
    Load an imm8 into a memory address pointed to by a reg16
    - 2 machine cycles 
*/
task LD_MEM8_IMM; 
    input reg_select_t src;
    input reg_select_t dst_addr;
begin
    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;
            // start mem write request
            decoded_action.act <= WRITE_MEM8_IMM; 
            decoded_action.dst <= dst_addr;
            decoded_action.src <= src; 
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            // do nothing as memory write completes...
            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/* 
    // Loads reg8 with value pointed to by reg16
    - 2 machine cycles
*/
task LD_REG8_MEM; 
    input reg_select_t dst;
    input reg_select_t src_addr;
begin
    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;
            // start mem read request
            decoded_action.act <= READ_MEM8; 
            decoded_action.src <= src_addr;
            decoded_action.dst <= dst; 
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            // the fetched value will now be in inst, so
            // write it to reg as an immediate
            decoded_action.act <= WRITE_REG8_IMM; 
            decoded_action.dst <= dst;
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/* 
    Increment 8 bit register 
    - 1 machine cycle
*/
task INC8; 
    input reg_select_t select;
    begin
    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= ALU_OP_ADD;
    decoded_action.src <= 1;
    decoded_action.dst <= select;
    decoded_action.next_pc <= 1; 
    end
endtask


/* Add 8-bit register */
task ADD8; 
    input reg_select_t src;
    input reg_select_t dst;
    begin
    decoded_action.act <= ALU_REG8;
    decoded_action.arg <= ALU_OP_ADD;
    decoded_action.src <= src;
    decoded_action.dst <= dst;
    decoded_action.next_pc <= 1; 
    end
endtask