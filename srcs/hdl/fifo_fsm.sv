`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2021 11:36:19 PM
// Design Name: 
// Module Name: fifo_fsm
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


module fifo_fsm(
        input wire clk_in, rst_in,
        input wire [5:0] pixel_in,
        input wire rd_en, // Pop
        input wire wr_en, //write 
        output logic [5:0] pixel_out
    );
endmodule
