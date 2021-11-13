`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2021 04:42:47 PM
// Design Name: 
// Module Name: OAM_Search
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


module oam_search_fsm(
    //input wires 
    input wire clk_in, rst_in, start_in,
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    output logic [7:0]  oam_din,
    output logic        oam_rd,
    output logic        oam_wr, 
    //Registers
    input reg [7:0] LCDC,
    input reg [7:0] LY,
    //Output Sprites 2 bytes 10 elements 
    output logic [15:0] obj_queue_out [9:0],
    output logic done_out, 
    //Debug
    output logic [3:0] index,
    output logic [15:0] curr_addr,
    output logic [1:0] rd_count,
    output logic [6:0] count
    );
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9C;
    parameter SPRITE_COUNT = 10;
    
    typedef enum {idle, start, reading_oam, done} states;
    states state;
    logic [4:0] sprite_height;
    
    assign oam_a = curr_addr; 
    always_comb begin
        oam_din = 8'hFF;
        oam_rd = 1;
        oam_wr = 1;
    end 
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            count <= 0;
            state <= idle;
            done_out <= 0;
        end else begin 
            if(state == idle )begin 
                if (start_in) begin
                    done_out <= 0;
                    state <= start;
                end
            end else if (state == start) begin 
                curr_addr <= OAM_START;
                count <= 0;
                rd_count <= 0;
                for(int i = 0; i < 10; i++) begin obj_queue_out[i] <= 0; end
                index <= 0;
                sprite_height <= (LCDC[2]) ? 16 : 8; 
                state <= reading_oam;
            end else if (state == reading_oam) begin 
                if(rd_count == 1) begin 
                    if(curr_addr == OAM_END) begin 
                        state <= done;
                    end else begin 
                        curr_addr <= curr_addr + 16'h4;
                    end 
                    if((oam_dout - 16 > LY || oam_dout - 16 > LY - sprite_height) && index < SPRITE_COUNT - 1) begin                     obj_queue_out[index] <= curr_addr; //Start Addr for sprite
                        index <= index + 1;
                    end 
                    rd_count <= 0;
                 end else begin
                    rd_count <= rd_count + 1;
                 end 
            end else if (state == done) begin 
                done_out <= 1;
                state <= idle;
            end
            if (state != idle) begin 
                if (count == 80) begin 
                    count <= 0;
                end else begin
                    count <= count + 1;
                end 
            end
        end 
    end 
//    typedef enum {idle, start, oam_wait, oam_receive, done} states;
//    states state; 
//    logic [4:0] sprite_height;
   
//    assign oam_a = curr_addr;
//    always_ff @(posedge clk_in) begin 
//        if(rst_in) begin 
//            index <= 0;
//            for(int i = 0; i < 10; i++) begin 
//                obj_queue_out[i] <= 0;
//            end   
//            count <= 0;
//            oam_rd <= 0;
//            state <= start;
//        end else begin 
//            if (state == start) begin 
//                oam_rd <= 1;
//                curr_addr <= OAM_START;
//                index <= 0;
//                ram_count <= 0;
//                state <= oam_wait;
//                count <= 0;
//                sprite_height <= (LCDC[2]) ? 16 : 8; 
//            end else if (state == oam_wait) begin
//                if(ram_count == 1) begin 
//                    ram_count <= 0;
//                    state <= oam_receive; 
//                end else begin 
//                    state <= oam_wait;
//                    ram_count <= ram_count + 1;
//                end 
//            end else if (state == oam_receive) begin 
//                if((oam_dout - 16 > LY || oam_dout - 16 > LY - sprite_height) && index < SPRITE_COUNT - 1) begin 
//                    obj_queue_out[index] <= curr_addr; //Start Addr for sprite
//                    index <= index + 1;
//                end 
//                if(curr_addr > OAM_END)begin
//                    state <= done;
//                end else begin 
//                    curr_addr <= curr_addr + 16'h4; 
//                    ram_count <= 0;
//                    state <= oam_wait;
//                end      
//            end else if (state == done) begin 
//                if(start_in) begin 
//                    state <= start;
//                end 
//            end 
//            if(count == 80) begin 
//                count <= 0;
//            end else begin 
//                count <= count + 1;
//            end
//        end 
//    end
endmodule
