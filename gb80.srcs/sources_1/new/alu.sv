
/*module alu_m import cpu_defs::*;(
    input wire rst, 
    output flags_s flags
);*/

/* Make sure to intialize flags register to zero */
always_comb begin
    if (rst) begin 
        flags.Z = 0; 
        flags.N = 0;
        flags.H = 0;
        flags.C = 0;
    end
end

/* Combinationally execute 8 bit ALU operations */
function [7:0] alu_op8; 
    input alu_op_t op;      // operation
    input wire[7:0] dst;    // value of current output (value of register that will be written to )
    input wire[7:0] src;    // src (constant may come from register)
    logic[7:0] out;         // output to be written to dst
    begin 
        case (op) 
            ALU_OP_ADD: begin
                {flags.C, out} = dst + src; 
                flags.Z = out == 0? 1 : 0; 
                flags.N = 0; 
                // Lazy computation of half carry flag (see https://robdor.com/2016/08/10/gameboy-emulator-half-carry-flag/)
                // Also for ADC see https://www.reddit.com/r/EmuDev/comments/knm196/gameboy_half_carry_flag_during_subtract_operation/ghp37be/
                flags.H = (((dst & 4'hf) + (src & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_SUB: begin
                {flags.C, out} = dst - src;
                flags.Z = out == 0? 1 : 0; 
                flags.N = 1;
                flags.H = (((dst & 4'hf) - (src & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_OR: begin
                out = dst | src; 
                flags.Z = out == 0? 1 : 0; 
                flags.N = 0; flags.H = 0; flags.C = 0; 
            end
            ALU_OP_ROT_LC: begin
                out = { dst[6:0], dst[7] };
                flags.Z = src == 1? 0 : out == 0; 
                flags.N = 0; flags.H = 0; 
                flags.C = dst[7];
            end
            ALU_OP_ROT_L: begin
                out = { dst[6:0], flags.C };
                flags.Z = src == 1? 0 : out == 0; 
                flags.N = 0; flags.H = 0; 
                flags.C = dst[7];
            end
            ALU_OP_ROT_RC: begin
                out = { dst[0], dst[7:1] };
                flags.Z = src == 1? 0 : out == 0; 
                flags.N = 0; flags.H = 0; 
                flags.C = dst[0];
            end
            ALU_OP_ROT_R: begin
                out = { flags.C, dst[7:1] }; 
                flags.Z = src == 1? 0 : out == 0; 
                flags.N = 0; flags.H = 0; 
                flags.C = dst[0];
            end
        endcase
        alu_op8 = out; 
    end
endfunction

/* Handle 16 bit oeprations */
function [15:0] alu_op16; 
    input alu_op_t op;       // 16 bit operation
    input wire[15:0] dst;    // value of current output (value of register that will be written to )
    input wire[15:0] src;    // src (constant may come from register)
    logic[15:0] out;         // output written to dst
    begin 
        case (op)
            ALU_OP_INC16: begin
                out = dst + 1; 
            end
            ALU_OP_DEC16: begin
                out = dst - 1; 
            end
            ALU_OP_ADD: begin
                {flags.C, out} = dst + src; 
                flags.N = 0; 
                flags.H = (((dst[15:8] & 4'hf) + (src[15:8] & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
        endcase
        alu_op16 = out;
    end
endfunction

//endmodule