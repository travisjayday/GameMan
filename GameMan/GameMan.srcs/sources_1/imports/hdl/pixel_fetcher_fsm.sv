`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 09:22:10 PM
// Design Name: 
// Module Name: Pixel_Fetcher_FSM
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

module pixel_fetcher_fsm (
    // Data Bus, 0x8000 - 0x9FFF 
    input  wire  [7:0]  ram_dout,
    output logic [15:0] ram_a,
    output logic [7:0]  ram_din,
    output logic        ram_rd,
    output logic        ram_wr, 
    // Registers
    input reg [7:0] lcdc, stat
    
    
    
    
    );
     
endmodule
