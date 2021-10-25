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
        input wire [15:0] addr_select,       // address to interact with
        input wire wr_select,               // 1 -> write to address; 0 -> read from address
        output logic [7:0] rd_out,          // output (read value)
        output logic rd_out_isvalid,
        input wire [7:0] wr_value,          // input (value to write to addres)
        input wire start 
    );

    logic [7:0] ram [MEM_SIZE - 1 : 0];
    logic [7:0] cycles_since_start; 

    always_ff @(posedge clk) begin
        if (rst) begin
            //ram <= '{default:'0};
            rd_out_isvalid <= 0; 
        end else begin
            if (start) begin
                cycles_since_start <= 0; 
                rd_out_isvalid <= 0; 
            end else if (cycles_since_start == 2) begin
                if (!wr_select) begin
                    if (addr_select >= MEM_SIZE) 
                        $display("Memory read out of bound: 0x%x", addr_select);
                    rd_out <= ram[addr_select];
                    rd_out_isvalid <= 1; 
                end else begin
                    if (addr_select >= MEM_SIZE) 
                        $display("Memory write out of bound: 0x%x <- 0x%x", addr_select, wr_value);
                    ram[addr_select] <= wr_value;
                    rd_out_isvalid <= 0; 
                end
            end else begin
                cycles_since_start <= cycles_since_start + 1; 
            end
        end 
    end
endmodule
