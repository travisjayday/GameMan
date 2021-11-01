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
            decoded_action.dst <= 0;        // select Low byte == REG_Z
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
    Write 8-bit Register to memory address 
    - 4 cycle instruction 
*/
task LD_MEM8_REG8_IMMADDR; 
    input reg_select_t src;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 16 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1; 
            // Do reg write request.  
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            // Hi byte of address coming in now. We need to start write request
            decoded_action.act <= WRITE_MEM8_REG8_WZ;
            decoded_action.dst <= 0;        // select Low byte == REG_Z
            decoded_action.src <= src;
            decoded_action.arg <= inst;     // high byte of address
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4:
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
    Load 16bit reg into 16bit reg
    - 2 Machine Cycles
*/
task LD_REG16_REG16; 
    input reg_select_t dst;
    input reg_select_t src;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 8 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG16_REG16;
            decoded_action.dst <= dst;     
            decoded_action.src <= src;     
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
    Load reg into 0xFF00 + imm8 offset
    - 3 cycle instruction 
*/
task LD_HRAM_REG_IMM; 
    input reg_select_t src;  
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 12 - 1;
            current_inst <= inst; 
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_W;
            decoded_action.arg <= 8'hff;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            decoded_action.act <= WRITE_MEM8_REG8_WZ;
            decoded_action.dst <= 1; 
            decoded_action.arg <= inst;
            decoded_action.src <= src;
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
    Load reg into 0xFF00 + imm8 offset
    - 3 cycle instruction 
*/
task LD_REG_HRAM_IMM; 
    input reg_select_t dst;  
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 12 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            decoded_action.act <= READ_MEM8_IMM;
            decoded_action.arg <= 8'hff;
            decoded_action.dst <= 0;            // select src as imm
            decoded_action.src <= inst;
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
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
    Load 0xFF00 + reg8 offset into reg8
    - 2 cycle instruction 
*/
task LD_REG_HRAM_REG; 
    input reg_select_t dst;  
    input reg_select_t offset;  
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 8 - 1;
            current_inst <= inst; 
            decoded_action.act <= READ_MEM8_IMM;
            decoded_action.arg <= 8'hff;
            decoded_action.dst <= 1;            // select read reg src
            decoded_action.src <= offset;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 4:
        begin cycles_left <= 4 - 1;
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
    Load reg into 0xFF00 + reg8 offset
    - 2 cycle instruction 
*/
task LD_HRAM_REG_REG; 
    input reg_select_t src;  
    input reg_select_t offset;  
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 8 - 1;
            current_inst <= inst; 
            decoded_action.act <= WRITE_MEM8_HRAM;
            decoded_action.arg <= 0;
            decoded_action.dst <= offset;            // select read reg src
            decoded_action.src <= src;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 4:
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
    Load value at addr imm16 into a 
    - 4 Machine Cycles
*/
task LD_REG8_IMMADDR; 
    input reg_select_t dst;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 16 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1; 
            // Do reg write request.  
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= READ_MEM8_IMM;
            decoded_action.dst <= 1;  
            decoded_action.arg <= inst;
            decoded_action.src <= REG_Z;
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.arg <= inst;  
            decoded_action.dst <= dst;  
            decoded_action.src <= 0;  
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
    Perform ALU function on byte at memory location
    - 3 cycle instruction 
*/
task ALU_OP8_MEM8; 
    input reg_select_t src_addr;
    input alu_op_t action;
    input wire[7:0] src_arg;
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
            decoded_action.act <= WRITE_MEM8_REG8_ALU_HL; 
            decoded_action.arg <= action;
            decoded_action.dst <= inst;
            decoded_action.src <= src_arg;     // increment incoming byte and write back
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        /* Before going to next instruction */
        1: begin
            cycles_left <= 0; 
            prev_inst <= 0; 
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

    current_inst <= inst; 
    if (cycles_left == 0) cycles_left <= 3; 
    else if (cycles_left == 1) begin 
        prev_inst <= 0; cycles_left <= 0;
    end else cycles_left <= cycles_left - 1; 

    decoded_action.act <= ALU_REG8;
    decoded_action.arg <= op;
    decoded_action.src <= src;
    decoded_action.dst <= dst;
    decoded_action.next_pc <= 1; 
    end
endtask

/* Do ALU Op with bitline select*/
task ALU_OP8_BIT; 
    input reg_select_t dst;
    input alu_op_t op;
    input wire[7:0] src;
    begin

    current_inst <= inst; 
    if (cycles_left == 0) cycles_left <= 3; 
    else if (cycles_left == 1) begin 
        prev_inst <= 0; cycles_left <= 0;
    end else cycles_left <= cycles_left - 1; 

    decoded_action.act <= ALU_IMM8;
    decoded_action.arg <= op;
    decoded_action.src <= src;
    decoded_action.dst <= dst;
    decoded_action.next_pc <= 1; 
    end
endtask

/* 
    Add immeidate to regsiter
    - 2 Machine Cycles
*/
task ALU_OP8_IMM; 
    input reg_select_t dst;
    input alu_op_t op;
    begin

    case (cycles_left)
        /* First Cycle */ 0: 
        begin
            cycles_left <= 8 - 1;
            current_inst <= inst;

            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        /* Second Machine Cycle */ 4: 
        begin cycles_left <= 4 - 1; 
            decoded_action.act <= ALU_IMM8;
            decoded_action.arg <= op;
            decoded_action.src <= inst;
            decoded_action.dst <= dst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
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

/*
    Computes SP + signed imm8 and saves in in SP
    - 4 Machine Cycles
*/
task OFFSET_SP; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            cycles_left <= 16 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1; 
            // write WZ = 0
            decoded_action.act <= WRITE_REG16_IMM;
            decoded_action.dst <= REG_WZ;
            decoded_action.arg <= 0; 
            decoded_action.src <= 0; 
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;
            decoded_action.arg <= inst; 
            decoded_action.src <= 0; 
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            // Do calculatoin
            decoded_action.act <= ALU_REG16;
            decoded_action.arg <= ALU_SIGNED_OFFSET8;
            decoded_action.dst <= REG_SP;   
            decoded_action.src <= REG_WZ;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/*
    Computes SP + signed imm8 and saves in in SP
    - 4 Machine Cycles
*/
task OFFSET_SP_INTO_HL; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for imm for 1 cycle 
            // write HL <= SP
            cycles_left <= 12 - 1;
            current_inst <= inst; 
            decoded_action.act <= WRITE_REG16_REG16;
            decoded_action.dst <= REG_HL;
            decoded_action.arg <= 0; 
            decoded_action.src <= REG_SP; 
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1; 
            // Z <= offset
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;
            decoded_action.arg <= inst; 
            decoded_action.src <= 0; 
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            // Do calculatoin. HL + offset
            decoded_action.act <= ALU_REG16;
            decoded_action.arg <= ALU_SIGNED_OFFSET8;
            decoded_action.dst <= REG_HL;   
            decoded_action.src <= REG_WZ;
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
    Jumps to (HL)
    - 1 cycle instruction 
*/
task JMP_HL; 
    begin
        decoded_action.act <= FLOW_JMP;
        decoded_action.arg <= REG_HL;
        decoded_action.dst <= 0;
        decoded_action.src <= 0;
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
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 8:
        begin  
            // Abort Relative jump because condition is false.
            if (!condition_flag) begin 
                cycles_left <= 4 - 1; 
            end else begin
                cycles_left <= 8 - 1;
                decoded_action.act <= WRITE_REG8_IMM;
                decoded_action.arg <= inst;
                decoded_action.dst <= REG_Z;
                decoded_action.next_pc <= 1; 
            end
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            // Do reg write request.  
            decoded_action.act <= FLOW_JR;
            //decoded_action.arg <= REG_Z;   auto read from REG_Z
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

task JMP_CC; 
    input wire condition;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 16 - 1;
            current_inst <= inst; 
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1; 
            // Do reg write request.  
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 8:
        begin 
            if (condition) begin
                // Do reg write request.  
                decoded_action.act <= WRITE_REG8_IMM;
                decoded_action.dst <= REG_W;   // casting reg_select to logic (kinda sus)
                decoded_action.arg <= inst;
                decoded_action.src <= 0;
                decoded_action.next_pc <= 0; 
                cycles_left <= 8 - 1;
            end else begin
                decoded_action.act <= CPU_NOP;
                decoded_action.next_pc <= 1; 
                cycles_left <= 4 - 1;
            end
        end
        /* Fourth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= FLOW_JMP;
            decoded_action.arg <= REG_WZ;   // casting reg_select to logic (kinda sus)
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

task RST; 
    input wire[7:0] vector; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin cycles_left <= 16 - 1; 
            current_inst <= inst;
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Write PC into memory at stack pointer --
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // Low byte of address
            decoded_action.src <= REG_PC_P;
            decoded_action.arg <= 2;        // decrement SP before and after
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // casting reg_select to logic (kinda sus)
            decoded_action.src <= REG_PC_C;
            decoded_action.arg <= 0;
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4: 
        begin cycles_left <= 4 - 1;
            decoded_action.act <= FLOW_JMP_IMM;
            decoded_action.arg <= 0;
            decoded_action.src <= vector;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

/* 
    Calls function if condition is met
*/
task CALL_CC; 
    input wire condition;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            // Wait for IMM  
            cycles_left <= 24 - 1;
            current_inst <= inst; 

            decoded_action.act <= CPU_NOP; 
            decoded_action.next_pc <= 1; 
        end
        /* Second Cycle */ 20: 
        begin cycles_left <= 20 - 1; 
            // Do reg write request. Write high byte of address nn into W.
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_Z;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 
        end
        /* Third Cycle */ 16:
        begin 
            // Do reg write request.  Write low byte of address nn into Z
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_W;   // casting reg_select to logic (kinda sus)
            decoded_action.arg <= inst;
            decoded_action.src <= 0;
            decoded_action.next_pc <= 1; 

            // Abort if condition is false
            if (!condition) cycles_left <= 4 - 1; 
            else cycles_left <= 16 - 1; 
        end
        /* Fourth Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Write PC into memory at stack pointer --
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // Low byte of address
            decoded_action.src <= REG_PC_P;
            decoded_action.arg <= 2;        // decrement SP after
            decoded_action.next_pc <= 0; 
        end
        /* Fith Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // casting reg_select to logic (kinda sus)
            decoded_action.src <= REG_PC_C;
            decoded_action.arg <= 0;
            decoded_action.next_pc <= 0; 
        end
        /* Sixth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= FLOW_JMP; 
            decoded_action.arg <= REG_WZ;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

task RET; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            cycles_left <= 16 - 1;
            current_inst <= inst; 

            decoded_action.act <= READ_MEM8;
            decoded_action.src <= REG_SP;       // Read LSB of PC 
            decoded_action.arg <= 1;            // increment SP after
            decoded_action.dst <= 0;   
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Write LSB of PC
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_PC_C;
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= READ_MEM8;
            decoded_action.src <= REG_SP;       // Read LSB of PC 
            decoded_action.arg <= 1;            // increment SP after
            decoded_action.dst <= 0;   
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_PC_P;
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

task RET_CC; 
    input wire condition;
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            cycles_left <= 20 - 1;
            current_inst <= inst; 

            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 16: 
        begin 
            if (condition) begin
                cycles_left <= 16 - 1;
                decoded_action.act <= READ_MEM8;
                decoded_action.src <= REG_SP;       // Read LSB of PC 
                decoded_action.arg <= 1;            // increment SP after
                decoded_action.dst <= 0;   
                decoded_action.next_pc <= 0; 
            end else begin
                cycles_left <= 4 - 1;
                decoded_action.act <= CPU_NOP;
                decoded_action.next_pc <= 1; 
            end
        end
        /* Third Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Write LSB of PC
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_PC_C;
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= READ_MEM8;
            decoded_action.src <= REG_SP;       // Read LSB of PC 
            decoded_action.arg <= 1;            // increment SP after
            decoded_action.dst <= 0;   
            decoded_action.next_pc <= 0; 
        end
        /* Firth Cycle */ 4:
        begin cycles_left <= 4 - 1;
            decoded_action.act <= WRITE_REG8_IMM;
            decoded_action.dst <= REG_PC_P;
            decoded_action.arg <= inst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask

task PUSH; 
    input reg_select_t src_hi; 
    input reg_select_t src_lo; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin cycles_left <= 16 - 1; 
            current_inst <= inst;
            decoded_action.act <= CPU_NOP;
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 12:
        begin cycles_left <= 12 - 1;
            // Write PC into memory at stack pointer --
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // Low byte of address
            decoded_action.src <= src_hi;
            decoded_action.arg <= 2;        // decrement SP before and after
            decoded_action.next_pc <= 0; 
        end
        /* Third Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= WRITE_MEM8_REG8;
            decoded_action.dst <= REG_SP;   // casting reg_select to logic (kinda sus)
            decoded_action.src <= src_lo;
            decoded_action.arg <= 0;
            decoded_action.next_pc <= 0; 
        end
        /* Fourth Cycle */ 4: 
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


task POP; 
    input reg_select_t dst; 
begin
    case (cycles_left) 
        /* First Cycle */ 0: 
        begin 
            cycles_left <= 12 - 1;
            current_inst <= inst; 

            decoded_action.act <= READ_MEM8;
            decoded_action.src <= REG_SP;       // Read LSB of Thing on stack
            decoded_action.arg <= 1;            // increment SP after
            decoded_action.dst <= 0;   
            decoded_action.next_pc <= 0; 
        end
        /* Second Cycle */ 8:
        begin cycles_left <= 8 - 1;
            decoded_action.act <= READ_MEM8;
            decoded_action.src <= REG_SP;       // Read MSB of Thing on stack
            decoded_action.arg <= 1;            // increment SP after
            decoded_action.dst <= 0;   
            decoded_action.next_pc <= 0; 
            prev_inst <= inst;           // LSB = prev_instruction
        end
        /* Third Cycle */ 4:
        begin cycles_left <= 4 - 1;
            // Write LSB of PC
            decoded_action.act <= WRITE_REG16_IMM;
            decoded_action.dst <= dst;
            decoded_action.arg <= inst;         // MSB = inst
            decoded_action.src <= prev_inst;
            decoded_action.next_pc <= 1; 
        end
        default: begin
            cycles_left <= cycles_left - 1; 
        end
    endcase
end
endtask