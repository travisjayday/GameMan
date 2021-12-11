module mmio_joypad_m import cpu_defs::*;(
    input wire clk,
    input wire rst,
    input wire [7:0] je,
    mem_if.slave req
    );

    logic [3:0] d_pad;
    logic [3:0] face;
    logic [3:0] d_pad_and_face;
    logic [1:0] sel;

    assign d_pad = je[3:0]; // right, left, up, down
    assign face = je[7:4];  // a, b, select, start
    assign d_pad_and_face = d_pad & face;

    logic [7:0] out_reg;

    /* Ouput for register */
    always_comb begin
        out_reg[7:4] = { 2'b11 , sel };
        case(sel)
            2'b11: out_reg[3:0] = 4'b1111;                      
            2'b10: out_reg[3:0] = d_pad;                      
            2'b01: out_reg[3:0] = face;
            2'b00: out_reg[3:0] = d_pad_and_face;
        endcase

        if (req.addr_select == 16'hFF00) begin
            req.read_out = out_reg;
        end else begin
            req.read_out = 8'hFF;
        end
    end

    /* 0xFF00 - Joypad (R/W) */
    logic [2:0] sel_we_hi; 
    always_ff @(posedge clk) begin
        if (rst) begin
            sel <= 0; 
            sel_we_hi <= 0;
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (sel_we_hi == 1) begin
                sel <= req.write_value[5:4];
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF00) 
                sel_we_hi <= sel_we_hi + 1;  
            else                  
                sel_we_hi <= 0; 
        end
    end
endmodule
