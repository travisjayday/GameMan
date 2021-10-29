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
            decoded_action.act = CPU_NOP;
            decoded_action.src = 0; 
            decoded_action.dst = 0; 
            decoded_action.arg = 0; 
        end else begin
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
                default: unkown_opcode();
            endcase
        end
    end

    task unkown_opcode(); 
    begin
        // check if inst != 0xXX
        if (inst !== 8'hxx) begin
            $display("Encountered unkown instruction: %x", inst);
            decoded_action.act <= CPU_DIE;
        end
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
        4'h7: RL_REG8(REG_A,/*carry*/1,/*rst_zflag*/1);             // RLCA
        4'h8: LD_MEM16_REG16(REG_SP);                               // LD (a16), SP
        4'h9: ADD16(REG_HL, REG_BC);                                // ADD HL, BC
        4'hA: LD_REG8_MEM(REG_A, REG_BC, ALU_OP_NOP, ALU_OP_NOP);   // LD A, (BC)
        4'hB: INCDEC16(REG_BC, ALU_OP_DEC16);                       // DEC BC
        4'hC: INC8(REG_C);                                          // INC C
        4'hD: DEC8(REG_C);                                          // DEC C
        4'hE: LD_REG8_IMM(REG_C);                                   // LD C, d8
        4'hF: RR_REG8(REG_A,/*carry*/1,/*rst_zflag*/1);             // RRCA
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
        4'h7: RL_REG8(REG_A,/*carry*/0,/*rst_zflag*/1);             // RLA
        4'h8: JR_CC(/*condition=*/1);                               // JR r8
        4'h9: ADD16(REG_HL, REG_DE);                                // ADD HL, DE
        4'hA: LD_REG8_MEM(REG_A, REG_DE, ALU_OP_NOP, ALU_OP_NOP);   // LD A, (DE)
        4'hB: INCDEC16(REG_DE, ALU_OP_DEC16);                       // DEC DE
        4'hC: INC8(REG_E);                                          // INC E
        4'hD: DEC8(REG_E);                                          // DEC E
        4'hE: LD_REG8_IMM(REG_E);                                   // LD E, d8
        4'hF: RR_REG8(REG_A,/*carry*/0,/*rst_zflag*/1);             // RRA
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
        4'h4: INCDEC_MEM8(REG_HL, ALU_OP_INC8);                     // INC (HL)
        4'h5: INCDEC_MEM8(REG_HL, ALU_OP_DEC8);                     // DEC (HL)
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
        // TODO: HALT
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

    `include "instruction_parser.sv"

endmodule