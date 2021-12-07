`timescale 1ns / 1ps
`default_nettype none

module top_level import cpu_defs::*;(
    input wire clk_100mhz, 
    input wire [7:0] je,
    input wire [15:0] sw,
    output logic [7:0] led
    );


mem_if con_if();

controller con_on_je (
    .clk(clk_100mhz),
    .je(je),
    .con_if(con_if)
    );
    
    assign con_if.write_value = sw[7:0] ;
    assign con_if.addr_select = 16'hFF00;
    assign con_if.write_enable = sw[8];
    assign led = con_if.read_out;
    
    
endmodule


module controller(
    input wire clk,
    input wire [7:0] je,
    mem_if.slave con_if
    ); 
    
    logic [3:0] d_pad;
    logic [3:0] face;
    logic [3:0] d_pad_and_face;
    logic [1:0] sel;
    
    assign d_pad = je[3:0]; // right, left, up, down
    assign face = je[7:4];  // a, b, select, start
    assign d_pad_and_face = d_pad & face;
    
    
        
    always_ff @(posedge clk) begin 
        if (con_if.addr_select == 16'hFF00) begin 
        
            if (con_if.write_enable) begin
            
                sel <= con_if.write_value[5:4];
                
            end else begin 
                
                con_if.read_out[7:4] <= { 2'b11 , sel };
                
                case(sel)
                    2'b11: con_if.read_out[3:0] <= 4'b1111;                      
                    2'b10: con_if.read_out[3:0] <= d_pad;                      
                    2'b01: con_if.read_out[3:0] <= face;
                    2'b00: con_if.read_out[3:0] <= d_pad_and_face;
                endcase
                
            end
        end
    end
endmodule

`default_nettype wire
