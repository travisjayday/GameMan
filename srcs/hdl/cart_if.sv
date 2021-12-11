`timescale 1ns / 1ps
`default_nettype none

module cart_if(
                    input wire clk,
                    input wire rst,
                    mem_if.slave rom_if,
                    
                    output logic clk_out,
                    output logic n_rst_out,
                    output logic n_write_enable_out,
                    output logic n_read_enable_out,
                    output logic n_cs_out,
                    output logic [15:0] addr_out,
                    inout wire   [7:0] data_out
                    );
                    
    //clk_divider #(.DIVIDER(2)) cart_clock (.clk_in(clk),.rst_in(rst),.clk_out(clk_out));
                    
    assign clk_out = 1;
    
    always_comb begin
        n_rst_out = ~rst;                                 // carteidge is active low reset
        addr_out = rom_if.addr_select;
        n_read_enable_out = rom_if.write_enable;      // no need to invert due to cartride being active low
        n_write_enable_out = ~rom_if.write_enable;    // invert because cartridge is active low.
        n_cs_out = ~(16'hA000 <= rom_if.addr_select && rom_if.addr_select < 16'hC000); // cs is active when the cpu is accessing the external ram (i think)        
        rom_if.read_out = data_out;
    end
    
    assign data_out = rom_if.write_enable ? rom_if.write_value : 8'bz;
                    
endmodule //cart_if

module clk_divider #(parameter DIVIDER = 500)(
              input wire         clk_in,
              input wire         rst_in,
              output logic       clk_out
              );


    logic[$clog2(DIVIDER)-1:0] periodic_counter = 'b0; 
   
    always_ff @(posedge clk_in)begin
        if (rst_in) begin
            periodic_counter <= 'b0;
            clk_out <= 0;
        end else begin
            if (periodic_counter >= DIVIDER-1)begin
                periodic_counter <= 'b0;
                clk_out <= ~clk_out;
            end else begin
                periodic_counter <= periodic_counter + 'b1;
            end
        end
    end

endmodule //clk_divider

`default_nettype wire