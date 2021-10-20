`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2021 12:52:30 PM
// Design Name: 
// Module Name: mem_region
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


module mem_m#(parameter MEM_SIZE=512)
    (
        input wire clk, 
        input wire rst,
        input wire [7:0] addr_select,
        input wire wr_select, 
        output logic [7:0] rd_out,
        input wire [7:0] wr_in
    );

    logic [7:0] ram [MEM_SIZE - 1 : 0];

    always_ff @(posedge clk) begin
        if (rst) begin
            //ram <= '{default:'0};
        end else begin
            // this ram always reads by default
            // and writes if wr_select goes high
            if (!wr_select) begin
                if (addr_select >= MEM_SIZE) 
                    $display("Memory read out of bound: 0x%x", addr_select);
                rd_out <= ram[addr_select];
            end else begin
                if (addr_select >= MEM_SIZE) 
                    $display("Memory write out of bound: 0x%x <- 0x%x", addr_select, wr_in);
                ram[addr_select] <= wr_in;
            end
        end 
    end
endmodule
