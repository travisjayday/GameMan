task NOP; 
begin
    decoded_action.act <= CPU_NOP;
    decoded_action.src <= 8'h00;
    decoded_action.dst <= 8'h00;
    decoded_action.arg <= 8'h00;
    decoded_action.next_pc <= 1; 
end
endtask

task DO_DIE;
    $display("preparing to die...");
    decoded_action.act <= CPU_DIE;
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
    Write 16-bit Register to memory address (Only instance is SP to mem)
    - 5 cycle instruction (king)
*/
task LD_MEM16_REG16; 
    input reg_select_t src;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 20 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 16:
        begin cycles_left <= 16 - 1; 
            // Do reg write request.  
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Hi byte of address coming in now. We need to start write request
            decoded_action.act <= WRITE_MEM8_REG8_WZ;
            decoded_action.dst <= REG_Z;   // Low byte of address
            decoded_action.src <= REG_P;
            decoded_action.arg <= inst;     // high byte of address
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_WZ;   // casting reg_select to logic (kinda sus)
            decoded_action.src <= REG_S;
            decoded_action.arg <= 1;
            decoded_action.next_pc <= 0; 
        end
        /* Fifth Cycle */ 4:
        begin cycles_left <= 4 - 1;
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
    - 2 machine cycle
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
task LD_MEM8_REG8; 
    input reg_select_t dst_addr;
    input reg_select_t src;
    input alu_op_t alu_action;        // nop, increment, or decrement register holding dst_addr
begin
    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;
            // start mem write request
            decoded_action.act <= WRITE_MEM8_REG8; 
            decoded_action.dst <= dst_addr;
            decoded_action.src <= src; 
            decoded_action.arg <= 0;
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            if (alu_action == ALU_OP_NOP) begin
                // do nothing as memory write completes...
                decoded_action.act <= CPU_NOP; 
            end else begin
                // decrement destination address register
                decoded_action.act <= ALU_REG16; 
                decoded_action.arg <= alu_action;
                decoded_action.dst <= dst_addr; 
                decoded_action.src <= REG_UNKOWN; 
            end
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask


/* 
    Load an imm16 into memory pointed to by reg16
    - 3 cycle instruction 
*/
task LD_MEM8_IMM; 
    input reg_select_t dst_addr;
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
            // start mem write request
            decoded_action.act <= WRITE_MEM8_IMM; 
            decoded_action.dst <= dst_addr;
            decoded_action.src <= inst; 
            decoded_action.arg <= 0;
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
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
    // Loads reg8 with value pointed to by reg16. 
    // Incremets or decrements address register if desired. 
    - 2 machine cycles
*/
task LD_REG8_MEM; 
    input reg_select_t dst;
    input reg_select_t src_addr;
    input alu_op_t incdec;          // performs increment / decrement on source address regsiter
    input alu_op_t post_op;         // perofrms alu operation on read value
begin
    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;
            // start mem read request
            decoded_action.act <= READ_MEM8; 
            decoded_action.src <= src_addr;
            decoded_action.dst <= 0; 
            if (incdec == ALU_OP_INC16) 
                decoded_action.arg <= 1; 
            else if (incdec == ALU_OP_DEC16) 
                decoded_action.arg <= 2; 
            else
                decoded_action.arg <= 0; 
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            // the fetched value will now be in inst, so
            // write it to reg as an immediate or perform ALU op on it 
            decoded_action.act <= ALU_IMM8; 
            decoded_action.arg <= post_op;
            decoded_action.dst <= dst;
            decoded_action.src <= inst;
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


/* 
    Decrement 8 bit register 
    - 1 machine cycle
*/
task DEC8; 
    input reg_select_t select;
    begin
    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= ALU_OP_SUB;
    decoded_action.src <= 1;
    decoded_action.dst <= select;
    decoded_action.next_pc <= 1; 
    end
endtask

/* 
    Increment or Decrement 16-bit register
    - 2 machine cycles 
*/
task INCDEC16; 
    input reg_select_t select;
    input wire[7:0] alu_op;
begin
    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;

            decoded_action.act <= ALU_REG16; 
            decoded_action.arg <= alu_op;
            decoded_action.dst <= select; 
            decoded_action.src <= REG_UNKOWN; 
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
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
    Increment or decrmement byte at memory location
    - 3 cycle instruction 
*/
task INCDEC_MEM8; 
    input reg_select_t src_addr;
    input alu_op_t inc_or_dec;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            cycles_left <= 12 - 1;
            current_inst <= inst;
            // start mem read request
            decoded_action.act <= READ_MEM8; 
            decoded_action.src <= src_addr;
            decoded_action.dst <= 0; 
            decoded_action.arg <= 0; 
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            // start mem write request
            decoded_action.act <= WRITE_MEM8_REG8_ALU; 
            decoded_action.arg <= inc_or_dec;
            decoded_action.dst <= src_addr;
            decoded_action.src <= inst;     // increment incoming byte and write back
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask


/* Add 8-bit register */
task ALU_OP8; 
    input reg_select_t dst;
    input reg_select_t src;
    input alu_op_t op;
    begin
    decoded_action.act <= ALU_REG8;
    decoded_action.arg <= op;
    decoded_action.src <= src;
    decoded_action.dst <= dst;
    decoded_action.next_pc <= 1; 
    end
endtask


/* Add 16-bit register */
task ADD16; 
    input reg_select_t dst;
    input reg_select_t src;
    begin

    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;

            decoded_action.act <= ALU_REG16;
            decoded_action.arg <= ALU_OP_ADD;
            decoded_action.src <= src;
            decoded_action.dst <= dst;
            decoded_action.next_pc <= 0; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
    end
endtask


/* Flips all bits in A register */
task CPL; 
    begin
    decoded_action.act <= ALU_REG8;
    decoded_action.arg <= ALU_OP_CPL;
    decoded_action.src <= REG_A;
    decoded_action.dst <= REG_A;
    decoded_action.next_pc <= 1; 
    end
endtask

/* Flips all bits in A register */
task CF; 
    input wire new_cf;
    begin
    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= ALU_OP_CF;
    decoded_action.src <= new_cf;
    decoded_action.dst <= REG_UNKOWN;
    decoded_action.next_pc <= 1; 
    end
endtask

/* Rotate Left Carry */
task RL_REG8; 
    input reg_select_t dst;
    input wire with_carry; 
    input wire reset_zero_flag; 
    begin
    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= with_carry? ALU_OP_ROT_LC : ALU_OP_ROT_L;
    decoded_action.dst <= dst;
    decoded_action.src <= reset_zero_flag;
    decoded_action.next_pc <= 1; 
    end
endtask

/* Rotate Right Carry */
task RR_REG8; 
    input reg_select_t dst;
    input wire with_carry;      // if true, turn RR into RRC or RL into RLC
    input wire rst_zflag;       // if true, force reset flags.Z = 0 
    begin
    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= with_carry? ALU_OP_ROT_RC : ALU_OP_ROT_R;
    decoded_action.dst <= dst;
    decoded_action.src <= rst_zflag;
    decoded_action.next_pc <= 1; 
    end
endtask

/* 
    DAA load decimal coded binary into A
    - 1 cycle instruction 
*/
task DAA; 
    begin
        decoded_action.act <= ALU_REG8;
        decoded_action.arg <= ALU_OP_DAA;
        decoded_action.dst <= REG_A;
        decoded_action.src <= REG_A;
        decoded_action.next_pc <= 1; 
    end
endtask

/* 
    Jump to offset given condition. 
    - 3 or 2 cycle instruction 
*/
task JR_CC; 
    input wire condition_flag;  // If true, will do the relative jump
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 12 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 

            // Abort Relative jump because condition is false.
            if (!condition_flag) cycles_left <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            // Do reg write request.  
            decoded_action.act <= FLOW_JR;
            decoded_action.arg <= inst;   
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask
