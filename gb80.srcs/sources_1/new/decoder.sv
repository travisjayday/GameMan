module decoder_m import cpu_defs::*; (
    input wire clk, 
    input wire rst,
    input wire[7:0] inst,
    output decoded_action_s decoded_action
);
    logic[4:0] cycles_left;
    logic[7:0] current_inst; 
    
    logic [7:0] active_inst;
    assign active_inst = cycles_left == 0? inst : current_inst;

    always_ff @(posedge clk) begin
        if (rst) begin
            cycles_left <= 0;
        end else begin
            // Switch on the current executing instruction 
            case (active_inst[7:4]) 
                4'h0: parse_row0(active_inst[3:0]);
                4'h1: parse_row1(active_inst[3:0]);
                4'h3: parse_row3(active_inst[3:0]);
                4'h4: parse_row4(active_inst[3:0]);
                default: unkown_opcode();
            endcase
        end
    end

    task unkown_opcode(); 
    begin
        // check if inst != 0xXX
        if (!$isunknown(inst)) begin
            $display("Encountered unkown instruction: %x", inst);
            decoded_action.act <= DIE;
        end
    end
    endtask 

    task parse_row0; input logic [3:0] col; 
    case (col)
        4'h0: NOP();
        4'h1: LD_REG16_IMM(REG_B, REG_C);           // LD BC, d16
        4'h2: LD_MEM8_IMM(REG_A, REG_BC);           // LD (BC), A
        4'h4: INC8(REG_B);                          // INC B 
        4'h6: LD_REG8_IMM(REG_B);                   // LD B, d8
        4'hE: LD_REG8_IMM(REG_C);                   // LD C, d8
        default: unkown_opcode();
    endcase endtask 

    task parse_row1; input logic [3:0] col; case (col)
        4'h0: NOP();                            // STOP 0
        4'h1: LD_REG16_IMM(REG_D, REG_E);           // LD DE, d16
        default: unkown_opcode();
    endcase endtask 

    task parse_row3; input logic [3:0] col; case (col)
        4'hE: LD_REG8_IMM(REG_A);               // LD A, d8
        default: unkown_opcode();
    endcase endtask 

    task parse_row4; input logic [3:0] col; case (col)
        4'h0: LD_REG8_REG8(REG_B, REG_B);       // LD B, B
        4'h1: LD_REG8_REG8(REG_B, REG_C);       // LD B, C
        4'h2: LD_REG8_REG8(REG_B, REG_D);       // LD B, D
        default: unkown_opcode();
    endcase endtask 

    `include "instruction_parser.sv"

endmodule