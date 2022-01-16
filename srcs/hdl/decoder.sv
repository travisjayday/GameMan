/*
    CPU Decoder. 
    Reads in opcodes and spits out executable CPU actions. 
    Handles multi-cycle instructions. 
*/
module decoder_m import cpu_defs::*; (
    input wire clk, 
    input wire rst,
    input wire[7:0] inst,
    input flags_s flags,
    input wire cpu_halt,
    input wire[7:0] active_IF,
    output decoded_action_s decoded_action
);

    /*
        Set by multi-cycle instructions. 
        If cycles_left is greater than zero, CPU is executing the
        multi-cycle instruction opcode located in current_inst. 
        cycles_left lets the decoder know how far the current instruciton
        is done executing, hence creating state.
    */ 
    logic[5:0] cycles_left;     
    logic[7:0] current_inst; 
    logic[7:0] current_isr; 

    // previous instruction. used sometimes. (see pop)
    logic[7:0] prev_inst; 

    // used for fetching data from stack in one instruciton
    logic[7:0] tmp_const;
    
    /* 
        Temproary combinational variable that contains the currently
        executing instruction opcode 
    */
    logic [7:0] active_inst;
    assign active_inst = cycles_left == 0? inst : current_inst;

    always_ff @(posedge clk) begin
        if (rst) begin
            cycles_left <= 0;
            decoded_action.next_pc <= 1; 
            decoded_action.act <= CPU_NOP;
            decoded_action.src <= 0; 
            decoded_action.dst <= 0; 
            decoded_action.arg <= 0; 
            current_isr <= 0; 
            prev_inst <= 0;
        end else begin
            // If we're starting a new instruction and an interrupt needs to be
            // serviced, service that interrupt

            if (current_isr || (cycles_left == 0 && active_IF != 0 && prev_inst != 8'hCB)) begin
                if      (current_isr[0]||active_IF[0]) CALL_ISR(8'h40, 8'b1111_1110); // Vsync ISR
                else if (current_isr[1]||active_IF[1]) CALL_ISR(8'h48, 8'b1111_1101); // LCD Stat ISR
                else if (current_isr[2]||active_IF[2]) CALL_ISR(8'h50, 8'b1111_1011); // Timer ISR
                else if (current_isr[4]||active_IF[4]) CALL_ISR(8'h60, 8'b1110_1111); // Joypad ISR
                else begin
                    $display("CPU trying to execute unkown ISR...");
                    $finish();
                end
            end else begin
                // Check if should execute ISR transition on next cycle
                //current_isr <= (cycles_left == 1 && IF != 0 && prev_inst != 8'hCB) ? IF : 0;
                if (prev_inst != 8'hCB) begin
                    // Switch on the first hex number of current executing instruction 
                    case (active_inst[7:4]) 
                        4'h0: ROW0(active_inst[3:0]);
                        4'h1: ROW1(active_inst[3:0]);
                        4'h2: ROW2(active_inst[3:0]);
                        4'h3: ROW3(active_inst[3:0]);
                        4'h4: ROW4(active_inst[3:0]);
                        4'h5: ROW5(active_inst[3:0]);
                        4'h6: ROW6(active_inst[3:0]);
                        4'h7: ROW7(active_inst[3:0]);
                        4'h8: ROW8(active_inst[3:0]);
                        4'h9: ROW9(active_inst[3:0]);
                        4'hA: ROWA(active_inst[3:0]);
                        4'hB: ROWB(active_inst[3:0]);
                        4'hC: ROWC(active_inst[3:0]);
                        4'hD: ROWD(active_inst[3:0]);
                        4'hE: ROWE(active_inst[3:0]);
                        4'hF: ROWF(active_inst[3:0]);
                        default: unkown_opcode();
                    endcase
                end else begin
                    // If the last instruction was CB-prefixed, 
                    // switch instead on the CB_ rows
                    case (active_inst[7:4]) 
                        4'h0: CB_ROW0(active_inst[3:0]);
                        4'h1: CB_ROW1(active_inst[3:0]);
                        4'h2: CB_ROW2(active_inst[3:0]);
                        4'h3: CB_ROW3(active_inst[3:0]);
                        4'h4: CB_ROW4(active_inst[3:0]);
                        4'h5: CB_ROW5(active_inst[3:0]);
                        4'h6: CB_ROW6(active_inst[3:0]);
                        4'h7: CB_ROW7(active_inst[3:0]);
                        4'h8: CB_ROW8(active_inst[3:0]);
                        4'h9: CB_ROW9(active_inst[3:0]);
                        4'hA: CB_ROWA(active_inst[3:0]);
                        4'hB: CB_ROWB(active_inst[3:0]);
                        4'hC: CB_ROWC(active_inst[3:0]);
                        4'hD: CB_ROWD(active_inst[3:0]);
                        4'hE: CB_ROWE(active_inst[3:0]);
                        4'hF: CB_ROWF(active_inst[3:0]);
                        default: unkown_opcode();
                    endcase
                end
            end
        end
    end

    task PREFIX_CB(); 
    begin
        current_inst <= inst; 
        if (cycles_left == 0) cycles_left <= 3; 
        else if (cycles_left == 1) begin 
            prev_inst <= 8'hCB; cycles_left <= 0;
        end else cycles_left <= cycles_left - 1; 

        decoded_action.act <= CPU_NOP;
        decoded_action.next_pc <= 1;
    end
    endtask 

    task unkown_opcode(); 
    begin
        // check if inst != 0xXX
        if (inst !== 8'hxx) begin
            $display("Encountered unkown instruction: %x", inst);
            decoded_action.act <= CPU_DIE;
        end
    end
    endtask 
    
    task BREAKPOINT(); 
    begin
        $display("Reached Breakpoint. Dying...");
        decoded_action.act <= CPU_DIE;
    end
    endtask 

    task ROW0; input logic [3:0] col; case (col)
        4'h0: NOP();
        4'h1: LD_REG16_IMM(REG_B, REG_C);                           // LD BC, d16
        4'h2: LD_MEM8_REG8(REG_BC, REG_A, ALU_OP_NOP);              // LD (BC), A
        4'h3: INCDEC16(REG_BC, ALU_OP_INC16);                       // INC BC
        4'h4: INC8(REG_B);                                          // INC B 
        4'h5: DEC8(REG_B);                                          // DEC B 
        4'h6: LD_REG8_IMM(REG_B);                                   // LD B, d8
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_LCA);                // RLCA
        4'h8: LD_MEM16_REG16(REG_SP);                               // LD (a16), SP
        4'h9: ADD16(REG_HL, REG_BC);                                // ADD HL, BC
        4'hA: LD_REG8_MEM(REG_A, REG_BC, ALU_OP_NOP, ALU_OP_NOP);   // LD A, (BC)
        4'hB: INCDEC16(REG_BC, ALU_OP_DEC16);                       // DEC BC
        4'hC: INC8(REG_C);                                          // INC C
        4'hD: DEC8(REG_C);                                          // DEC C
        4'hE: LD_REG8_IMM(REG_C);                                   // LD C, d8
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_RCA);                // RRCA
        default: unkown_opcode();
    endcase endtask 

    task ROW1; input logic [3:0] col; case (col)
        // TODO: STOP 0
        4'h1: LD_REG16_IMM(REG_D, REG_E);                           // LD DE, d16
        4'h2: LD_MEM8_REG8(REG_DE, REG_A, ALU_OP_NOP);              // LD (DE), A
        4'h3: INCDEC16(REG_DE, ALU_OP_INC16);                       // INC DE
        4'h4: INC8(REG_D);                                          // INC D
        4'h5: DEC8(REG_D);                                          // DEC D
        4'h6: LD_REG8_IMM(REG_D);                                   // LD D, d8
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_LA);                 // RLA
        4'h8: JR_CC(/*condition=*/1);                               // JR r8
        4'h9: ADD16(REG_HL, REG_DE);                                // ADD HL, DE
        4'hA: LD_REG8_MEM(REG_A, REG_DE, ALU_OP_NOP, ALU_OP_NOP);   // LD A, (DE)
        4'hB: INCDEC16(REG_DE, ALU_OP_DEC16);                       // DEC DE
        4'hC: INC8(REG_E);                                          // INC E
        4'hD: DEC8(REG_E);                                          // DEC E
        4'hE: LD_REG8_IMM(REG_E);                                   // LD E, d8
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_RA);                 // RRA
        default: unkown_opcode();
    endcase endtask 

    task ROW2; input logic [3:0] col; case (col)
        4'h0: JR_CC(/*condition=*/!flags.Z);                        // JR NZ, r8
        4'h1: LD_REG16_IMM(REG_H, REG_L);                           // LD HL, d16
        4'h2: LD_MEM8_REG8(REG_HL, REG_A, ALU_OP_INC16);            // LD (HL+), A
        4'h3: INCDEC16(REG_HL, ALU_OP_INC16);                       // INC HL
        4'h4: INC8(REG_H);                                          // INC H 
        4'h5: DEC8(REG_H);                                          // DEC H
        4'h6: LD_REG8_IMM(REG_H);                                   // LD H, d8
        4'h7: DAA();                                                // DAA
        4'h8: JR_CC(/*condition=*/flags.Z);                         // JR Z, r8
        4'h9: ADD16(REG_HL, REG_HL);                                // ADD HL, HL
        4'hA: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_INC16, ALU_OP_NOP); // LD A, (HL+)
        4'hB: INCDEC16(REG_HL, ALU_OP_DEC16);                       // DEC HL
        4'hC: INC8(REG_L);                                          // INC L
        4'hD: DEC8(REG_L);                                          // DEC L
        4'hE: LD_REG8_IMM(REG_L);                                   // LD L, d8
        4'hF: CPL();                                                // CPL
        default: unkown_opcode();
    endcase endtask 

    task ROW3; input logic [3:0] col; case (col)
        4'h0: JR_CC(/*condition=*/!flags.C);                        // JR NC, r8
        4'h1: LD_REG16_IMM(REG_S, REG_P);                           // LD SP, d16
        4'h2: LD_MEM8_REG8(REG_HL, REG_A, ALU_OP_DEC16);            // LD (HL-), A
        4'h3: INCDEC16(REG_SP, ALU_OP_INC16);                       // INC SP
        4'h4: ALU_OP8_MEM8(REG_HL, ALU_OP_INC8, 0);                 // INC (HL)
        4'h5: ALU_OP8_MEM8(REG_HL, ALU_OP_DEC8, 0);                 // DEC (HL)
        4'h6: LD_MEM8_IMM(REG_HL);                                  // LD (HL), d8
        4'h7: CF(1);                                                // SCF
        4'h8: JR_CC(/*condition=*/flags.C);                         // JR C, r8
        4'h9: ADD16(REG_HL, REG_SP);                                // ADD HL, SP
        4'hA: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_DEC16, ALU_OP_NOP); // LD A, (HL-)
        4'hB: INCDEC16(REG_SP, ALU_OP_DEC16);                       // DEC SP
        4'hC: INC8(REG_A);                                          // INC A
        4'hD: DEC8(REG_A);                                          // DEC A
        4'hE: LD_REG8_IMM(REG_A);                                   // LD A, d8
        4'hF: CF(0);                                                // CCF
        default: unkown_opcode();
    endcase endtask 

    task ROW4; input logic [3:0] col; case (col)
        //4'h0: BREAKPOINT();                           // LD B, B
        4'h0: LD_REG8_REG8(REG_B, REG_B);                           // LD B, B
        4'h1: LD_REG8_REG8(REG_B, REG_C);                           // LD B, C
        4'h2: LD_REG8_REG8(REG_B, REG_D);                           // LD B, D
        4'h3: LD_REG8_REG8(REG_B, REG_E);                           // LD B, E
        4'h4: LD_REG8_REG8(REG_B, REG_H);                           // LD B, H
        4'h5: LD_REG8_REG8(REG_B, REG_L);                           // LD B, L
        4'h6: LD_REG8_MEM(REG_B, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD B, (HL)
        4'h7: LD_REG8_REG8(REG_B, REG_A);                           // LD B, A
        4'h8: LD_REG8_REG8(REG_C, REG_B);                           // LD C, B
        4'h9: LD_REG8_REG8(REG_C, REG_C);                           // LD C, C
        4'hA: LD_REG8_REG8(REG_C, REG_D);                           // LD C, D
        4'hB: LD_REG8_REG8(REG_C, REG_E);                           // LD C, E
        4'hC: LD_REG8_REG8(REG_C, REG_H);                           // LD C, H
        4'hD: LD_REG8_REG8(REG_C, REG_L);                           // LD C, L
        4'hE: LD_REG8_MEM(REG_C, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD C, (HL)
        4'hF: LD_REG8_REG8(REG_C, REG_A);                           // LD C, A
        default: unkown_opcode();
    endcase endtask 

    task ROW5; input logic [3:0] col; case (col)
        4'h0: LD_REG8_REG8(REG_D, REG_B);                           // LD D, B
        4'h1: LD_REG8_REG8(REG_D, REG_C);                           // LD D, C
        4'h2: LD_REG8_REG8(REG_D, REG_D);                           // LD D, D
        4'h3: LD_REG8_REG8(REG_D, REG_E);                           // LD D, E
        4'h4: LD_REG8_REG8(REG_D, REG_H);                           // LD D, H
        4'h5: LD_REG8_REG8(REG_D, REG_L);                           // LD D, L
        4'h6: LD_REG8_MEM(REG_D, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD D, (HL)
        4'h7: LD_REG8_REG8(REG_D, REG_A);                           // LD D, A
        4'h8: LD_REG8_REG8(REG_E, REG_B);                           // LD E, B
        4'h9: LD_REG8_REG8(REG_E, REG_C);                           // LD E, C
        4'hA: LD_REG8_REG8(REG_E, REG_D);                           // LD E, D
        4'hB: LD_REG8_REG8(REG_E, REG_E);                           // LD E, E
        4'hC: LD_REG8_REG8(REG_E, REG_H);                           // LD E, H
        4'hD: LD_REG8_REG8(REG_E, REG_L);                           // LD E, L
        4'hE: LD_REG8_MEM(REG_E, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD E, (HL)
        4'hF: LD_REG8_REG8(REG_E, REG_A);                           // LD E, A
        default: unkown_opcode();
    endcase endtask 

    task ROW6; input logic [3:0] col; case (col)
        4'h0: LD_REG8_REG8(REG_H, REG_B);                           // LD H, B
        4'h1: LD_REG8_REG8(REG_H, REG_C);                           // LD H, C
        4'h2: LD_REG8_REG8(REG_H, REG_D);                           // LD H, D
        4'h3: LD_REG8_REG8(REG_H, REG_E);                           // LD H, E
        4'h4: LD_REG8_REG8(REG_H, REG_H);                           // LD H, H
        4'h5: LD_REG8_REG8(REG_H, REG_L);                           // LD H, L
        4'h6: LD_REG8_MEM(REG_H, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD H, (HL)
        4'h7: LD_REG8_REG8(REG_H, REG_A);                           // LD H, A
        4'h8: LD_REG8_REG8(REG_L, REG_B);                           // LD L, B
        4'h9: LD_REG8_REG8(REG_L, REG_C);                           // LD L, C
        4'hA: LD_REG8_REG8(REG_L, REG_D);                           // LD L, D
        4'hB: LD_REG8_REG8(REG_L, REG_E);                           // LD L, E
        4'hC: LD_REG8_REG8(REG_L, REG_H);                           // LD L, H
        4'hD: LD_REG8_REG8(REG_L, REG_L);                           // LD L, L
        4'hE: LD_REG8_MEM(REG_L, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD L, (HL)
        4'hF: LD_REG8_REG8(REG_L, REG_A);                           // LD L, A
        default: unkown_opcode();
    endcase endtask 

    task ROW7; input logic [3:0] col; case (col)
        4'h0: LD_MEM8_REG8(REG_HL, REG_B, ALU_OP_NOP);              // LD (HL), B
        4'h1: LD_MEM8_REG8(REG_HL, REG_C, ALU_OP_NOP);              // LD (HL), C
        4'h2: LD_MEM8_REG8(REG_HL, REG_D, ALU_OP_NOP);              // LD (HL), D
        4'h3: LD_MEM8_REG8(REG_HL, REG_E, ALU_OP_NOP);              // LD (HL), E
        4'h4: LD_MEM8_REG8(REG_HL, REG_H, ALU_OP_NOP);              // LD (HL), H
        4'h5: LD_MEM8_REG8(REG_HL, REG_L, ALU_OP_NOP);              // LD (HL), L
        4'h6: HALT();                                               // HALT
        4'h7: LD_MEM8_REG8(REG_HL, REG_A, ALU_OP_NOP);              // LD (HL), A
        4'h8: LD_REG8_REG8(REG_A, REG_B);                           // LD A, B
        4'h9: LD_REG8_REG8(REG_A, REG_C);                           // LD A, C
        4'hA: LD_REG8_REG8(REG_A, REG_D);                           // LD A, D
        4'hB: LD_REG8_REG8(REG_A, REG_E);                           // LD A, E
        4'hC: LD_REG8_REG8(REG_A, REG_H);                           // LD A, H
        4'hD: LD_REG8_REG8(REG_A, REG_L);                           // LD A, L
        4'hE: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_NOP);   // LD A, (HL)
        4'hF: LD_REG8_REG8(REG_A, REG_A);                           // LD A, A
        default: unkown_opcode();
    endcase endtask 

    task ROW8; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_A, REG_B, ALU_OP_ADD);                    // ADD A, B
        4'h1: ALU_OP8(REG_A, REG_C, ALU_OP_ADD);                    // ADD A, C
        4'h2: ALU_OP8(REG_A, REG_D, ALU_OP_ADD);                    // ADD A, D
        4'h3: ALU_OP8(REG_A, REG_E, ALU_OP_ADD);                    // ADD A, E
        4'h4: ALU_OP8(REG_A, REG_H, ALU_OP_ADD);                    // ADD A, H
        4'h5: ALU_OP8(REG_A, REG_L, ALU_OP_ADD);                    // ADD A, L
        4'h6: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_ADD);   // ADD A, (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_ADD);                    // ADD A, A
        4'h8: ALU_OP8(REG_A, REG_B, ALU_OP_ADC);                    // ADC A, B
        4'h9: ALU_OP8(REG_A, REG_C, ALU_OP_ADC);                    // ADC A, C
        4'hA: ALU_OP8(REG_A, REG_D, ALU_OP_ADC);                    // ADC A, D
        4'hB: ALU_OP8(REG_A, REG_E, ALU_OP_ADC);                    // ADC A, E
        4'hC: ALU_OP8(REG_A, REG_H, ALU_OP_ADC);                    // ADC A, H
        4'hD: ALU_OP8(REG_A, REG_L, ALU_OP_ADC);                    // ADC A, L
        4'hE: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_ADC);   // ADC A, (HL)
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_ADC);                    // ADC A, A
        default: unkown_opcode();
    endcase endtask 

    task ROW9; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_A, REG_B, ALU_OP_SUB);                    // SUB B
        4'h1: ALU_OP8(REG_A, REG_C, ALU_OP_SUB);                    // SUB C
        4'h2: ALU_OP8(REG_A, REG_D, ALU_OP_SUB);                    // SUB D
        4'h3: ALU_OP8(REG_A, REG_E, ALU_OP_SUB);                    // SUB E
        4'h4: ALU_OP8(REG_A, REG_H, ALU_OP_SUB);                    // SUB H
        4'h5: ALU_OP8(REG_A, REG_L, ALU_OP_SUB);                    // SUB L
        4'h6: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_SUB);   // SUB (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_SUB);                    // SUB A
        4'h8: ALU_OP8(REG_A, REG_B, ALU_OP_SBC);                    // SBC A, B
        4'h9: ALU_OP8(REG_A, REG_C, ALU_OP_SBC);                    // SBC A, C
        4'hA: ALU_OP8(REG_A, REG_D, ALU_OP_SBC);                    // SBC A, D
        4'hB: ALU_OP8(REG_A, REG_E, ALU_OP_SBC);                    // SBC A, E
        4'hC: ALU_OP8(REG_A, REG_H, ALU_OP_SBC);                    // SBC A, H
        4'hD: ALU_OP8(REG_A, REG_L, ALU_OP_SBC);                    // SBC A, L
        4'hE: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_SBC);   // SBC A, (HL)
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_SBC);                    // SBC A, A
        default: unkown_opcode();
    endcase endtask 

    task ROWA; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_A, REG_B, ALU_OP_AND);                    // AND B
        4'h1: ALU_OP8(REG_A, REG_C, ALU_OP_AND);                    // AND C
        4'h2: ALU_OP8(REG_A, REG_D, ALU_OP_AND);                    // AND D
        4'h3: ALU_OP8(REG_A, REG_E, ALU_OP_AND);                    // AND E
        4'h4: ALU_OP8(REG_A, REG_H, ALU_OP_AND);                    // AND H
        4'h5: ALU_OP8(REG_A, REG_L, ALU_OP_AND);                    // AND L
        4'h6: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_AND);   // AND (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_AND);                    // AND A
        4'h8: ALU_OP8(REG_A, REG_B, ALU_OP_XOR);                    // XOR B
        4'h9: ALU_OP8(REG_A, REG_C, ALU_OP_XOR);                    // XOR C
        4'hA: ALU_OP8(REG_A, REG_D, ALU_OP_XOR);                    // XOR D
        4'hB: ALU_OP8(REG_A, REG_E, ALU_OP_XOR);                    // XOR E
        4'hC: ALU_OP8(REG_A, REG_H, ALU_OP_XOR);                    // XOR H
        4'hD: ALU_OP8(REG_A, REG_L, ALU_OP_XOR);                    // XOR L
        4'hE: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_XOR);   // XOR (HL)
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_XOR);                    // XOR A
        default: unkown_opcode();
    endcase endtask 

    task ROWB; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_A, REG_B, ALU_OP_OR);                     // OR B
        4'h1: ALU_OP8(REG_A, REG_C, ALU_OP_OR);                     // OR C
        4'h2: ALU_OP8(REG_A, REG_D, ALU_OP_OR);                     // OR D
        4'h3: ALU_OP8(REG_A, REG_E, ALU_OP_OR);                     // OR E
        4'h4: ALU_OP8(REG_A, REG_H, ALU_OP_OR);                     // OR H
        4'h5: ALU_OP8(REG_A, REG_L, ALU_OP_OR);                     // OR L
        4'h6: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_OR);    // OR (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_OR);                     // OR A
        4'h8: ALU_OP8(REG_A, REG_B, ALU_OP_CP);                     // CP B
        4'h9: ALU_OP8(REG_A, REG_C, ALU_OP_CP);                     // CP C
        4'hA: ALU_OP8(REG_A, REG_D, ALU_OP_CP);                     // CP D
        4'hB: ALU_OP8(REG_A, REG_E, ALU_OP_CP);                     // CP E
        4'hC: ALU_OP8(REG_A, REG_H, ALU_OP_CP);                     // CP H
        4'hD: ALU_OP8(REG_A, REG_L, ALU_OP_CP);                     // CP L
        4'hE: LD_REG8_MEM(REG_A, REG_HL, ALU_OP_NOP, ALU_OP_CP);    // CP (HL)
        4'hF: ALU_OP8(REG_A, REG_A, ALU_OP_CP);                     // CP A
        default: unkown_opcode();
    endcase endtask 

    task ROWC; input logic [3:0] col; case (col)
        4'h0: RET_CC(/*condition=*/!flags.Z);                       // RET NZ
        4'h1: POP(REG_BC);                                          // POP BC
        4'h2: JMP_CC(/*condition=*/!flags.Z);                       // JP NZ, a16
        4'h3: JMP_CC(/*condition=*/1);                              // JP a16
        4'h4: CALL_CC(/*condition=*/!flags.Z);                      // CALL NZ, a16
        4'h5: PUSH(REG_B, REG_C);                                   // PUSH BC
        4'h6: ALU_OP8_IMM(REG_A, ALU_OP_ADD);                       // ADD A, d8
        4'h7: RST(8'h00);                                           // RST 00H
        4'h8: RET_CC(/*condition=*/flags.Z);                        // RET Z
        4'h9: RET(0);                                               // RET
        4'hA: JMP_CC(/*condition=*/flags.Z);                        // JP Z, a16
        4'hB: PREFIX_CB();                                          // PREFIX CB
        4'hC: CALL_CC(/*condition=*/flags.Z);                       // CALL Z, a16
        4'hD: CALL_CC(/*condition=*/1);                             // CALL a16
        4'hE: ALU_OP8_IMM(REG_A, ALU_OP_ADC);                       // ADC A, d8
        4'hF: RST(8'h08);                                           // RST 08H
        default: begin
            unkown_opcode();
        end
    endcase endtask 

    task ROWD; input logic [3:0] col; case (col)
        4'h0: RET_CC(/*condition=*/!flags.C);                       // RET NC
        4'h1: POP(REG_DE);                                          // POP DE
        4'h2: JMP_CC(/*condition=*/!flags.C);                       // JP NC, a16
        //h3: illegal opcode 
        4'h4: CALL_CC(/*condition=*/!flags.C);                      // CALL NC, a16
        4'h5: PUSH(REG_D, REG_E);                                   // PUSH DE
        4'h6: ALU_OP8_IMM(REG_A, ALU_OP_SUB);                       // SUB A, d8
        4'h7: RST(8'h10);                                           // RST 10H
        4'h8: RET_CC(/*condition=*/flags.C);                        // RET C
        4'h9: RET(1);                                               // RETI
        4'hA: JMP_CC(/*condition=*/flags.C);                        // JP C, a16
        //hB: illegal opcode 
        4'hC: CALL_CC(/*condition=*/flags.C);                       // CALL C, a16
        //hD: illegal opcode
        4'hE: ALU_OP8_IMM(REG_A, ALU_OP_SBC);                       // SBC A, d8
        4'hF: RST(8'h18);                                           // RST 18H
        default: unkown_opcode();
    endcase endtask 

    task ROWE; input logic [3:0] col; case (col)
        4'h0: LD_HRAM_REG_IMM(REG_A);                               // LDH (a8), A
        4'h1: POP(REG_HL);                                          // POP HL
        4'h2: LD_HRAM_REG_REG(REG_A, REG_C);                        // LD (C), A
        //h3: illegal opcode
        //h4: illegal opcode
        4'h5: PUSH(REG_H, REG_L);                                   // PUSH HL
        4'h6: ALU_OP8_IMM(REG_A, ALU_OP_AND);                       // AND A, d8
        4'h7: RST(8'h20);                                           // RST 20H
        4'h8: OFFSET_SP();                                          // ADD SP, r8
        4'h9: JMP_HL();                                             // JMP (HL)
        4'hA: LD_MEM8_REG8_IMMADDR(REG_A);                          // LD (a16), A
        //hB: illegal opcode
        //hC: illegal opcode
        //hD: illegal opcode
        4'hE: ALU_OP8_IMM(REG_A, ALU_OP_XOR);                       // XOR A, d8
        4'hF: RST(8'h28);                                           // RST 28H
        default: unkown_opcode();
    endcase endtask 

    task ROWF; input logic [3:0] col; case (col)
        4'h0: LD_REG_HRAM_IMM(REG_A);                               // LDH A, (a8)
        4'h1: POP(REG_AF);                                          // POP AF
        4'h2: LD_REG_HRAM_REG(REG_A, REG_C);                        // LD A, (C)
        4'h3: SET_IME(0);                                           // DI
        //h4: illegal opcode
        4'h5: PUSH(REG_A, REG_F);                                   // PUSH AF
        4'h6: ALU_OP8_IMM(REG_A, ALU_OP_OR);                        // AND OR, d8
        4'h7: RST(8'h30);                                           // RST 30H
        4'h8: OFFSET_SP_INTO_HL();                                  // LD HL, SP+r8
        4'h9: LD_REG16_REG16(REG_SP, REG_HL);                       // LD SP, HL
        4'hA: LD_REG8_IMMADDR(REG_A);                               // LD A, (a16)
        4'hB: SET_IME(1);                                           // IE
        //hC: illegal opcode
        //hD: illegal opcode
        4'hE: ALU_OP8_IMM(REG_A, ALU_OP_CP);                        // CP d8
        4'hF: RST(8'h38);                                           // RST 38H
        default: unkown_opcode();
    endcase endtask 

    task CB_ROW0; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_B, REG_B, ALU_OP_ROT_LC);                 // RLC B
        4'h1: ALU_OP8(REG_C, REG_C, ALU_OP_ROT_LC);                 // RLC C
        4'h2: ALU_OP8(REG_D, REG_D, ALU_OP_ROT_LC);                 // RLC D
        4'h3: ALU_OP8(REG_E, REG_E, ALU_OP_ROT_LC);                 // RLC E
        4'h4: ALU_OP8(REG_H, REG_H, ALU_OP_ROT_LC);                 // RLC H
        4'h5: ALU_OP8(REG_L, REG_L, ALU_OP_ROT_LC);                 // RLC L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_LC, 0);               // RLC (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_LC);                 // RLC A
        4'h8: ALU_OP8(REG_B, REG_B, ALU_OP_ROT_RC);                 // RRC B
        4'h9: ALU_OP8(REG_C, REG_C, ALU_OP_ROT_RC);                 // RRC C
        4'ha: ALU_OP8(REG_D, REG_D, ALU_OP_ROT_RC);                 // RRC D
        4'hb: ALU_OP8(REG_E, REG_E, ALU_OP_ROT_RC);                 // RRC E
        4'hc: ALU_OP8(REG_H, REG_H, ALU_OP_ROT_RC);                 // RRC H
        4'hd: ALU_OP8(REG_L, REG_L, ALU_OP_ROT_RC);                 // RRC L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_RC, 0);               // RRC (HL)
        4'hf: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_RC);                 // RRC A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW1; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_B, REG_B, ALU_OP_ROT_L);                  // RL B
        4'h1: ALU_OP8(REG_C, REG_C, ALU_OP_ROT_L);                  // RL C
        4'h2: ALU_OP8(REG_D, REG_D, ALU_OP_ROT_L);                  // RL D
        4'h3: ALU_OP8(REG_E, REG_E, ALU_OP_ROT_L);                  // RL E
        4'h4: ALU_OP8(REG_H, REG_H, ALU_OP_ROT_L);                  // RL H
        4'h5: ALU_OP8(REG_L, REG_L, ALU_OP_ROT_L);                  // RL L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_L, 0);                // RL (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_L);                  // RL A
        4'h8: ALU_OP8(REG_B, REG_B, ALU_OP_ROT_R);                  // RR B
        4'h9: ALU_OP8(REG_C, REG_C, ALU_OP_ROT_R);                  // RR C
        4'ha: ALU_OP8(REG_D, REG_D, ALU_OP_ROT_R);                  // RR D
        4'hb: ALU_OP8(REG_E, REG_E, ALU_OP_ROT_R);                  // RR E
        4'hc: ALU_OP8(REG_H, REG_H, ALU_OP_ROT_R);                  // RR H
        4'hd: ALU_OP8(REG_L, REG_L, ALU_OP_ROT_R);                  // RR L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_R, 0);                // RR (HL)
        4'hf: ALU_OP8(REG_A, REG_A, ALU_OP_ROT_R);                  // RR A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW2; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_B, REG_B, ALU_OP_SLA);                    // SLA B
        4'h1: ALU_OP8(REG_C, REG_C, ALU_OP_SLA);                    // SLA C
        4'h2: ALU_OP8(REG_D, REG_D, ALU_OP_SLA);                    // SLA D
        4'h3: ALU_OP8(REG_E, REG_E, ALU_OP_SLA);                    // SLA E
        4'h4: ALU_OP8(REG_H, REG_H, ALU_OP_SLA);                    // SLA H
        4'h5: ALU_OP8(REG_L, REG_L, ALU_OP_SLA);                    // SLA L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_SLA, 0);                  // SLA (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_SLA);                    // SLA A
        4'h8: ALU_OP8(REG_B, REG_B, ALU_OP_SRA);                    // SRA B
        4'h9: ALU_OP8(REG_C, REG_C, ALU_OP_SRA);                    // SRA C
        4'ha: ALU_OP8(REG_D, REG_D, ALU_OP_SRA);                    // SRA D
        4'hb: ALU_OP8(REG_E, REG_E, ALU_OP_SRA);                    // SRA E
        4'hc: ALU_OP8(REG_H, REG_H, ALU_OP_SRA);                    // SRA H
        4'hd: ALU_OP8(REG_L, REG_L, ALU_OP_SRA);                    // SRA L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_SRA, 0);                  // SRA (HL)
        4'hf: ALU_OP8(REG_A, REG_A, ALU_OP_SRA);                    // SRA A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW3; input logic [3:0] col; case (col)
        4'h0: ALU_OP8(REG_B, REG_B, ALU_OP_SWAP);                   // SWAP B
        4'h1: ALU_OP8(REG_C, REG_C, ALU_OP_SWAP);                   // SWAP C
        4'h2: ALU_OP8(REG_D, REG_D, ALU_OP_SWAP);                   // SWAP D
        4'h3: ALU_OP8(REG_E, REG_E, ALU_OP_SWAP);                   // SWAP E
        4'h4: ALU_OP8(REG_H, REG_H, ALU_OP_SWAP);                   // SWAP H
        4'h5: ALU_OP8(REG_L, REG_L, ALU_OP_SWAP);                   // SWAP L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_SWAP, 0);                 // SWAP (HL)
        4'h7: ALU_OP8(REG_A, REG_A, ALU_OP_SWAP);                   // SWAP A
        4'h8: ALU_OP8(REG_B, REG_B, ALU_OP_SRL);                    // SRL B
        4'h9: ALU_OP8(REG_C, REG_C, ALU_OP_SRL);                    // SRL C
        4'ha: ALU_OP8(REG_D, REG_D, ALU_OP_SRL);                    // SRL D
        4'hb: ALU_OP8(REG_E, REG_E, ALU_OP_SRL);                    // SRL E
        4'hc: ALU_OP8(REG_H, REG_H, ALU_OP_SRL);                    // SRL H
        4'hd: ALU_OP8(REG_L, REG_L, ALU_OP_SRL);                    // SRL L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_SRL, 0);                  // SRL (HL)
        4'hf: ALU_OP8(REG_A, REG_A, ALU_OP_SRL);                    // SRL A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW4; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 0);               // BIT 0, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 0);               // BIT 0, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 0);               // BIT 0, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 0);               // BIT 0, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 0);               // BIT 0, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 0);               // BIT 0, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 0);             // BIT 0, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 0);               // BIT 0, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 1);               // BIT 1, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 1);               // BIT 1, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 1);               // BIT 1, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 1);               // BIT 1, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 1);               // BIT 1, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 1);               // BIT 1, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 1);             // BIT 1, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 1);               // BIT 1, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW5; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 2);               // BIT 2, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 2);               // BIT 2, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 2);               // BIT 2, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 2);               // BIT 2, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 2);               // BIT 2, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 2);               // BIT 2, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 2);             // BIT 2, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 2);               // BIT 2, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 3);               // BIT 3, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 3);               // BIT 3, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 3);               // BIT 3, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 3);               // BIT 3, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 3);               // BIT 3, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 3);               // BIT 3, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 3);             // BIT 3, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 3);               // BIT 3, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW6; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 4);               // BIT 4, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 4);               // BIT 4, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 4);               // BIT 4, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 4);               // BIT 4, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 4);               // BIT 4, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 4);               // BIT 4, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 4);             // BIT 4, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 4);               // BIT 4, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 5);               // BIT 5, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 5);               // BIT 5, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 5);               // BIT 5, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 5);               // BIT 5, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 5);               // BIT 5, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 5);               // BIT 5, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 5);             // BIT 5, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 5);               // BIT 5, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW7; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 6);               // BIT 6, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 6);               // BIT 6, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 6);               // BIT 6, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 6);               // BIT 6, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 6);               // BIT 6, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 6);               // BIT 6, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 6);             // BIT 6, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 6);               // BIT 6, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_TEST, 7);               // BIT 7, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_TEST, 7);               // BIT 7, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_TEST, 7);               // BIT 7, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_TEST, 7);               // BIT 7, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_TEST, 7);               // BIT 7, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_TEST, 7);               // BIT 7, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_TEST, 7);             // BIT 7, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_TEST, 7);               // BIT 7, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW8; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 0);                // RES 0, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 0);                // RES 0, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 0);                // RES 0, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 0);                // RES 0, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 0);                // RES 0, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 0);                // RES 0, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 0);              // RES 0, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 0);                // RES 0, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 1);                // RES 1, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 1);                // RES 1, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 1);                // RES 1, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 1);                // RES 1, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 1);                // RES 1, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 1);                // RES 1, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 1);              // RES 1, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 1);                // RES 1, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROW9; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 2);                // RES 2, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 2);                // RES 2, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 2);                // RES 2, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 2);                // RES 2, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 2);                // RES 2, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 2);                // RES 2, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 2);              // RES 2, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 2);                // RES 2, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 3);                // RES 3, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 3);                // RES 3, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 3);                // RES 3, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 3);                // RES 3, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 3);                // RES 3, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 3);                // RES 3, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 3);              // RES 3, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 3);                // RES 3, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWA; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 4);                // RES 4, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 4);                // RES 4, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 4);                // RES 4, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 4);                // RES 4, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 4);                // RES 4, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 4);                // RES 4, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 4);              // RES 4, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 4);                // RES 4, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 5);                // RES 5, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 5);                // RES 5, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 5);                // RES 5, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 5);                // RES 5, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 5);                // RES 5, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 5);                // RES 5, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 5);              // RES 5, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 5);                // RES 5, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWB; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 6);                // RES 6, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 6);                // RES 6, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 6);                // RES 6, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 6);                // RES 6, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 6);                // RES 6, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 6);                // RES 6, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 6);              // RES 6, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 6);                // RES 6, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_RES, 7);                // RES 7, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_RES, 7);                // RES 7, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_RES, 7);                // RES 7, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_RES, 7);                // RES 7, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_RES, 7);                // RES 7, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_RES, 7);                // RES 7, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_RES, 7);              // RES 7, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_RES, 7);                // RES 7, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWC; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 0);                // SET 0, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 0);                // SET 0, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 0);                // SET 0, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 0);                // SET 0, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 0);                // SET 0, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 0);                // SET 0, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 0);              // SET 0, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 0);                // SET 0, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 1);                // SET 1, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 1);                // SET 1, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 1);                // SET 1, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 1);                // SET 1, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 1);                // SET 1, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 1);                // SET 1, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 1);              // SET 1, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 1);                // SET 1, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWD; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 2);                // SET 2, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 2);                // SET 2, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 2);                // SET 2, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 2);                // SET 2, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 2);                // SET 2, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 2);                // SET 2, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 2);              // SET 2, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 2);                // SET 2, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 3);                // SET 3, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 3);                // SET 3, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 3);                // SET 3, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 3);                // SET 3, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 3);                // SET 3, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 3);                // SET 3, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 3);              // SET 3, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 3);                // SET 3, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWE; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 4);                // SET 4, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 4);                // SET 4, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 4);                // SET 4, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 4);                // SET 4, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 4);                // SET 4, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 4);                // SET 4, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 4);              // SET 4, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 4);                // SET 4, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 5);                // SET 5, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 5);                // SET 5, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 5);                // SET 5, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 5);                // SET 5, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 5);                // SET 5, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 5);                // SET 5, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 5);              // SET 5, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 5);                // SET 5, A
        default: unkown_opcode();
    endcase endtask

    task CB_ROWF; input logic [3:0] col; case (col)
        4'h0: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 6);                // SET 6, B
        4'h1: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 6);                // SET 6, C
        4'h2: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 6);                // SET 6, D
        4'h3: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 6);                // SET 6, E
        4'h4: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 6);                // SET 6, H
        4'h5: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 6);                // SET 6, L
        4'h6: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 6);              // SET 6, (HL)
        4'h7: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 6);                // SET 6, A
        4'h8: ALU_OP8_BIT(REG_B, ALU_OP_BIT_SET, 7);                // SET 7, B
        4'h9: ALU_OP8_BIT(REG_C, ALU_OP_BIT_SET, 7);                // SET 7, C
        4'ha: ALU_OP8_BIT(REG_D, ALU_OP_BIT_SET, 7);                // SET 7, D
        4'hb: ALU_OP8_BIT(REG_E, ALU_OP_BIT_SET, 7);                // SET 7, E
        4'hc: ALU_OP8_BIT(REG_H, ALU_OP_BIT_SET, 7);                // SET 7, H
        4'hd: ALU_OP8_BIT(REG_L, ALU_OP_BIT_SET, 7);                // SET 7, L
        4'he: ALU_OP8_MEM8(REG_HL, ALU_OP_BIT_SET, 7);              // SET 7, (HL)
        4'hf: ALU_OP8_BIT(REG_A, ALU_OP_BIT_SET, 7);                // SET 7, A
        default: unkown_opcode();
    endcase endtask

    `include "instruction_parser.sv"

endmodule