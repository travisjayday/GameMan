`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2021 01:35:22 PM
// Design Name: 
// Module Name: cpu_defs
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


interface bram_if ();
    logic [15:0] addr_select;
    logic [7:0] write_value;
    logic [7:0] read_out;
    logic write_enable;

    modport master (
        output addr_select,
        output write_value, 
        output write_enable,
        input read_out
    );

    modport slave (
        input addr_select,
        input write_value,
        input write_enable,
        output read_out
    );

endinterface

package cpu_defs;

    typedef struct {
        /* Register definitions */
        logic [15:0] AF; 
        logic [15:0] BC; 
        logic [15:0] DE; 
        logic [15:0] HL; 
        logic [15:0] SP; 
        logic [15:0] PC; 
    } reg_file_s; 


    typedef enum 
    { 
        REG_AF, REG_BC, REG_DE, REG_HL, REG_SP, REG_PC, 
        REG_A, REG_B, REG_C, REG_D, REG_E, REG_H, REG_L, REG_UNKOWN 
    } reg_select_t;


    typedef enum {
        WRITE_REG16_IMM, WRITE_REG8_IMM, WRITE_REG8_REG8, 
        WRITE_MEM8_IMM, READ_MEM8, 
        ALU_IMM8, ALU_REG8, CPU_NOP, CPU_DIE
    } action;

    typedef enum {
        FETCH, DECODE, EXECUTE, FLOW
    } cpu_state_t;

    typedef struct packed {
        action act;
        logic[7:0] src;
        logic[7:0] dst;
        logic[7:0] arg;
        logic next_pc; 
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
