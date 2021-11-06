
/*module alu_m import cpu_defs::*;(
    input wire rst, 
    output flags_s flags
);*/

/* Combinationally execute 8 bit ALU operations */
function [11:0] alu_op8; 
    input alu_op_t op;      // operation
    input wire[7:0] dst;    // value of current output (value of register that will be written to )
    input wire[7:0] src;    // src (constant may come from register)
    logic[7:0] out;         // output to be written to dst
    logic[7:0] tmp;         // used for temp var in computations
    flags_s f;              // new flags
    begin 
        f = flags;
        case (op) 
            ALU_OP_NOP: begin
                out = src; 
            end
            ALU_OP_ADD: begin
                {f.C, out} = dst + src; 
                f.Z = out == 0? 1 : 0; 
                f.N = 0; 
                // Lazy computation of half carry flag (see https://robdor.com/2016/08/10/gameboy-emulator-half-carry-flag/)
                // Also for ADC see https://www.reddit.com/r/EmuDev/comments/knm196/gameboy_half_carry_flag_during_subtract_operation/ghp37be/
                f.H = (((dst & 4'hf) + (src & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_ADC: begin
                f.H = (((dst & 4'hf) + (src & 4'hf) + f.C) & 8'h10) == 8'h10 ? 1 : 0;
                {f.C, out} = dst + src + f.C; 
                f.Z = out == 0? 1 : 0; 
                f.N = 0; 
            end
            ALU_OP_INC8: begin
                out = dst + 1; 
                f.Z = out == 0? 1 : 0;
                f.N = 0; 
                f.H = (((dst & 4'hf) + (1 & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_DEC8: begin
                out = dst - 1; 
                f.Z = out == 0? 1 : 0;
                f.N = 1; 
                f.H = (((dst & 4'hf) - (1 & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_SUB: begin
                {f.C, out} = dst - src;
                f.Z = out == 0? 1 : 0; 
                f.N = 1;
                f.H = (((dst & 4'hf) - (src & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_OP_SBC: begin
                f.H = (((dst & 4'hf) - (src & 4'hf) - f.C) & 8'h10) == 8'h10 ? 1 : 0;
                {f.C, out} = dst - src - f.C; // = dst - (src + f.C)
                f.Z = out == 0? 1 : 0; 
                f.N = 1;
            end
            ALU_OP_AND: begin
                out = dst & src;
                f.Z = out == 0? 1 : 0;
                f.N = 0; f.H = 1; f.C = 0; 
            end
            ALU_OP_XOR: begin
                out = dst ^ src;
                f.Z = out == 0? 1 : 0;
                f.N = 0; f.H = 0; f.C = 0; 
            end
            ALU_OP_OR: begin
                out = dst | src; 
                f.Z = out == 0? 1 : 0; 
                f.N = 0; f.H = 0; f.C = 0; 
            end
            ALU_OP_CP: begin
                // subtract without writing back to register
                {f.C, tmp} = dst - src;
                f.Z = tmp == 0? 1 : 0; 
                f.N = 1;
                f.H = (((dst & 4'hf) - (src & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
                out = dst; 
            end
            ALU_OP_ROT_LCA: begin
                out = { dst[6:0], dst[7] };
                f.Z = 0; f.N = 0; f.H = 0; 
                f.C = dst[7];
            end
            ALU_OP_ROT_LA: begin
                out = { dst[6:0], f.C };
                f.Z = 0; f.N = 0; f.H = 0; 
                f.C = dst[7];
            end
            ALU_OP_ROT_LC: begin
                out = { dst[6:0], dst[7] };
                f.Z = out == 0; f.N = 0; f.H = 0; 
                f.C = dst[7];
            end
            ALU_OP_ROT_L: begin
                out = { dst[6:0], f.C };
                f.Z = out == 0; f.N = 0; f.H = 0; 
                f.C = dst[7];
            end
            ALU_OP_ROT_RCA: begin
                out = { dst[0], dst[7:1] };
                f.Z = 0; f.N = 0; f.H = 0; 
                f.C = dst[0];
            end
            ALU_OP_ROT_RA: begin
                out = { f.C, dst[7:1] }; 
                f.Z = 0; f.N = 0; f.H = 0; 
                f.C = dst[0];
            end
            ALU_OP_ROT_RC: begin
                out = { dst[0], dst[7:1] };
                f.Z = out == 0; 
                f.N = 0; f.H = 0; 
                f.C = dst[0];
            end
            ALU_OP_ROT_R: begin
                out = { f.C, dst[7:1] }; 
                f.Z = out == 0; 
                f.N = 0; f.H = 0; 
                f.C = dst[0];
            end
            ALU_OP_DAA: begin
                // See https://ehaskins.com/2018-01-30%20Z80%20DAA/ for explain
                tmp = 0; 
                if (f.H || (!f.N && (src & 4'hf) > 9)) begin
                    tmp |= 8'h06; 
                end
                if (f.C || (!f.N && src > 8'h99)) begin
                    tmp |= 8'h60; 
                    f.C = 1; 
                end else begin
                    f.C = 0; 
                end
                out = f.N ? src - tmp : src + tmp;  
                f.Z = out == 0? 1 : 0;
                f.H = 0; 
            end
            ALU_OP_CPL: begin
                out = ~src;
                f.H = 1; 
                f.N = 1; 
            end
            ALU_OP_CF: begin
                // src == 0 --> SCF; src == 1; !CCF
                f.C = src == 1? 1 : !f.C; 
                f.N = 0;
                f.H = 0; 
                out = 0; 
            end
            ALU_OP_SLA: begin
                {f.C, out} = { dst, 1'b0 };
                f.Z = out == 0; f.N = 0; f.H = 0; 
            end
            ALU_OP_SRA: begin
                out = { dst[7], dst[7:1] };
                f.Z = out == 0; f.C = 0; f.N = 0; f.H = 0; 
            end
            ALU_OP_SRL: begin
                out = { 1'b0, dst[7:1] };
                f.Z = out == 0; f.C = 0; f.N = 0; f.H = 0; 
            end
            ALU_OP_SWAP: begin
                out = { dst[3:0], dst[7:4] };
                f.Z = out == 0;  
                f.N = 0; f.H = 0; f.C = 0;
            end
            ALU_OP_BIT_TEST: begin
                f.N = 0; 
                f.H = 1; 
                f.Z = dst[src] == 0;
                out = dst;
            end
            ALU_OP_BIT_RES: begin
                dst[src] = 0;
                out = dst;
            end
            ALU_OP_BIT_SET: begin
                dst[src] = 1;
                out = dst;
            end
            default: begin
                $display("ALU8 trying to exec unkowon action");
                $finish();
            end
        endcase
        alu_op8 = {f, out}; 
    end
endfunction

/* Handle 16 bit oeprations */
function [19:0] alu_op16; 
    input alu_op_t op;       // 16 bit operation
    input wire[15:0] dst;    // value of current output (value of register that will be written to )
    input wire[15:0] src;    // src (constant may come from register)
    logic[15:0] out;         // output written to dst
    logic[7:0] tmp;
    flags_s f; 
    begin 
        f = flags;
        case (op)
            ALU_OP_NOP: begin
                out = dst;
            end
            ALU_OP_INC16: begin
                out = dst + 1; 
            end
            ALU_OP_DEC16: begin
                out = dst - 1; 
            end
            ALU_OP_ADD: begin
                {f.C, out} = dst + src; 
                f.N = 0; 
                f.H = (((dst[15:8] & 4'hf) + (src[15:8] & 4'hf)) & 8'h10) == 8'h10 ? 1 : 0;
            end
            ALU_SIGNED_OFFSET8: begin
                f.Z = 0;
                f.N = 0; 
                if (src < 128) begin
                    out = dst + {8'b0, src[7:0]}; 
                    {f.C, tmp} = dst[7:0] + src[7:0];
                    f.H = (((dst & 4'hf) + (src & 4'hf)) & 16'h10) == 16'h10 ? 1 : 0;
                end else begin
                    out = dst - (256 - src[7:0]); 
                    {f.C, tmp} = dst[7:0] + src[7:0];
                    f.H = (((dst & 4'hf) + (src & 4'hf)) & 16'h10) == 16'h10 ? 1 : 0;
                end
            end
        endcase
        alu_op16 = {f, out};
    end
endfunction

//endmodule