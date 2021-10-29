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
        end else begin
            // Switch on the first hex number of current executing instruction 
            case (active_inst[7:4]) 
                4'h0: ROW0(active_inst[3:0]);
                4'h1: ROW1(active_inst[3:0]);
                4'h2: ROW2(active_inst[3:0]);
                4'h3: ROW3(active_inst[3:0]);
                4'h4: ROW4(active_inst[3:0]);
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
        4'h1: LD_REG16_IMM(REG_B, REG_C);                   // LD BC, d16
        4'h2: LD_MEM8_REG8(REG_BC, REG_A, ALU_OP_NOP);      // LD (BC), A
        4'h3: INCDEC16(REG_BC, ALU_OP_INC16);               // INC BC
        4'h4: INC8(REG_B);                                  // INC B 
        4'h5: DEC8(REG_B);                                  // DEC B 
        4'h6: LD_REG8_IMM(REG_B);                           // LD B, d8
        4'h7: RL_REG8(REG_A,/*carry*/1,/*rst_zflag*/1);     // RLCA
        4'h8: LD_MEM16_REG16(REG_SP);                       // LD (a16), SP
        4'h9: ADD16(REG_HL, REG_BC);                        // ADD HL, BC
        4'hA: LD_REG8_MEM(REG_A, REG_BC);                   // LD A, (BC)
        4'hB: INCDEC16(REG_BC, ALU_OP_DEC16);               // DEC BC
        4'hC: INC8(REG_C);                                  // INC C
        4'hD: DEC8(REG_C);                                  // DEC C
        4'hE: LD_REG8_IMM(REG_C);                           // LD C, d8
        4'hF: RR_REG8(REG_A,/*carry*/1,/*rst_zflag*/1);     // RRCA
        default: unkown_opcode();
    endcase endtask 

    task ROW1; input logic [3:0] col; case (col)
        4'h0: DO_DIE();                                     // STOP 0
        4'h1: LD_REG16_IMM(REG_D, REG_E);                   // LD DE, d16
        4'h2: LD_MEM8_REG8(REG_DE, REG_A, ALU_OP_NOP);      // LD (DE), A
        4'h3: INCDEC16(REG_DE, ALU_OP_INC16);               // INC DE
        4'h4: INC8(REG_D);                                  // INC D
        4'h5: DEC8(REG_D);                                  // DEC D
        4'h6: LD_REG8_IMM(REG_D);                           // LD D, d8
        4'h7: RL_REG8(REG_A,/*carry*/0,/*rst_zflag*/1);     // RLA
        4'h8: JR_CC(/*condition=*/1);                       // JR r8
        4'h9: ADD16(REG_HL, REG_DE);                        // ADD HL, DE
        4'hA: LD_REG8_MEM(REG_A, REG_DE);                   // LD A, (DE)
        4'hB: INCDEC16(REG_DE, ALU_OP_DEC16);               // DEC DE
        4'hC: INC8(REG_E);                                  // INC E
        4'hD: DEC8(REG_E);                                  // DEC E
        4'hE: LD_REG8_IMM(REG_E);                           // LD E, d8
        4'hF: RR_REG8(REG_A,/*carry*/0,/*rst_zflag*/1);     // RRA
        default: unkown_opcode();
    endcase endtask 

    task ROW2; input logic [3:0] col; case (col)
        4'h0: JR_CC(/*condition=*/!flags.Z);                // JR NZ, r8
        4'h1: LD_REG16_IMM(REG_H, REG_L);                   // LD HL, d16
        4'h2: LD_MEM8_REG8(REG_HL, REG_A, ALU_OP_INC16);    // LD (HL+), A
        4'h3: INCDEC16(REG_HL, ALU_OP_INC16);               // INC HL
        4'h4: INC8(REG_H);                                  // INC H 
        4'h5: DEC8(REG_H);                                  // DEC H
        4'h6: LD_REG8_IMM(REG_H);                           // LD H, d8
        4'h8: JR_CC(/*condition=*/flags.Z);                 // JR Z, r8
        4'hE: LD_REG8_IMM(REG_L);                           // LD L, d8
        default: unkown_opcode();
    endcase endtask 

    task ROW3; input logic [3:0] col; case (col)
        4'h1: LD_REG16_IMM(REG_S, REG_P);                   // LD SP, d16
        4'h2: LD_MEM8_REG8(REG_HL, REG_A, ALU_OP_DEC16);    // LD (HL-), A
        4'hE: LD_REG8_IMM(REG_A);                           // LD A, d8
        default: unkown_opcode();
    endcase endtask 

    task ROW4; input logic [3:0] col; case (col)
        4'h0: LD_REG8_REG8(REG_B, REG_B);                   // LD B, B
        4'h1: LD_REG8_REG8(REG_B, REG_C);                   // LD B, C
        4'h2: LD_REG8_REG8(REG_B, REG_D);                   // LD B, D
        default: unkown_opcode();
    endcase endtask 

    `include "instruction_parser.sv"

endmodule