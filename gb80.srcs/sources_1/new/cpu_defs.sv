`timescale 1ns / 1ps

/* 
    Memory Interface
    A good way to abstract any kind of memory action. 
*/
interface mem_if ();
    logic [15:0] addr_select;
    logic [7:0] write_value;
    logic [7:0] read_out;
    logic write_enable;

    // Perspective of the CPU
    modport master (
        output addr_select,
        output write_value, 
        output write_enable,
        input read_out
    );

    // Perspective of the MMU or BRAM
    modport slave (
        input addr_select,
        input write_value,
        input write_enable,
        output read_out
    );

endinterface

package cpu_defs;

    /* Register definitions */
    typedef struct {
        logic [15:0] AF; 
        logic [15:0] BC; 
        logic [15:0] DE; 
        logic [15:0] HL; 
        logic [15:0] SP; 
        logic [15:0] PC; 
        logic [15:0] WZ;    // Hidden temp reg 
    } reg_file_s; 

    /* Register selection names. Essentially keys to reegister dict */
    typedef enum { 
        REG_AF, REG_BC, REG_DE, REG_HL, REG_SP, REG_PC, 
        REG_A, REG_B, REG_C, REG_D, REG_E, REG_H, REG_L, REG_UNKOWN,
        REG_S, REG_P,           // exist internally
        REG_W, REG_Z, REG_WZ    // hidden
    } reg_select_t;

    /* CPU FSM states */
    typedef enum {
        FETCH,      // Fetch instruction from ROM[PC]
        DECODE,     // Decode opcode into decoded_action_s (Executable action)
        EXECUTE,    // Execute the action
        FLOW        // Modify PC and prepare to fetch new instruction
    } cpu_state_t;

    /* An general / catagorical action the CPU FSM can execute */
    typedef enum {
        CPU_NOP, CPU_DIE,

        /* Reg Ops */
        WRITE_REG16_IMM, WRITE_REG8_IMM, WRITE_REG8_REG8, 

        /* Write Mem Ops */
        WRITE_MEM8_REG8, 
        WRITE_MEM8_REG8_WZ, 
        WRITE_MEM8_REG8_ALU, 
        WRITE_MEM8_IMM,

        /* Read Mem Ops */
        READ_MEM8, 

        /* ALU Ops */ 
        ALU_IMM8, ALU_REG16, ALU_REG8,  
        
        /* Flow ops */
        FLOW_JR
    } action_t;

    /* A categorical CPU action with additional arguments and 
       parameters generated by an instruction opcode. 
       Output of the decoder.
    */
    typedef struct packed {
        action_t act;
        logic[7:0] src;
        logic[7:0] dst;
        logic[7:0] arg;
        logic next_pc; 
    } decoded_action_s;

    /* CPU ALU Flags register bits */
    typedef struct packed {
        logic Z;        // Zero flag
        logic N;        // Negative flag
        logic H;        // Half-Carry flag
        logic C;        // Carry flag
    } flags_s; 

    /* ALU Operations. Categorical actions the ALU can perform */
    typedef enum {
        ALU_OP_ADD, ALU_OP_ADC, 
        ALU_OP_SUB, ALU_OP_SBC,  
        ALU_OP_INC8, ALU_OP_DEC8,
        ALU_OP_INC16, ALU_OP_DEC16, ALU_OP_NOP,
        ALU_OP_AND, ALU_OP_XOR, ALU_OP_OR, ALU_OP_CP,

        /* Misc */
        ALU_OP_DAA, ALU_OP_CPL, ALU_OP_CF,

        /* For special ops that rotate A */
        ALU_OP_ROT_LC, ALU_OP_ROT_L, ALU_OP_ROT_RC, ALU_OP_ROT_R
    } alu_op_t;

endpackage
