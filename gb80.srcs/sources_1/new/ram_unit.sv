`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2021 04:07:26 PM
// Design Name: 
// Module Name: ram_unit
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


module ram_unit(
    input wire clk, 
    bram_if.slave in);

    bram_32k_rom wram(
        .addra(in.addr_select),
        .clka(clk), 
        .dina(in.write_value),
        .douta(in.read_out),
        .wea(in.write_enable)
        );
endmodule
