`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2021 06:29:43 PM
// Design Name: 
// Module Name: pixel_queue
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


module pixel_queue(
    input wire clk_in,rst_in, start_in,
    input wire [7:0][5:0] pixel_row_in,
    
    output logic [5:0] pixel_to_fifo_out,
    output logic done_out ,
    output logic [2:0] pixel_count_out
    );
    parameter MAX_COUNT = 8;

    assign pixel_to_fifo_out = pixel_row_in[MAX_COUNT - 1 - pixel_count_out];
    always_ff @(posedge clk_in) begin
        if(rst_in || start_in) begin
            pixel_count_out <= 0;
            done_out <= 0;
        end else begin 
            if(!done_out) begin
                if(pixel_count_out == MAX_COUNT - 1) begin
                   done_out <= 1;
                   pixel_count_out <= 0;
                end else begin
                    pixel_count_out <= pixel_count_out + 1;
                end  
            end
        end 
    end 
endmodule
