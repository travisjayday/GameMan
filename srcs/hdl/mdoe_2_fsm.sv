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
`default_nettype none

module mode_2_fsm(
    //input wires 
    input wire clk,
    input wire rst, 
    input wire start,
    output logic done_out, 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    output logic [7:0]  oam_din,
    output logic        oam_wr, 
    //Registers
    input wire [7:0] LCDC,
    input wire [7:0] LY,
    //Output Sprites 2 bytes 10 elements 
    output logic [47:0] sprite_queue_out [9:0]
    );
    parameter MODE_2_CYCLES = 80;
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9C;
    parameter SPRITE_COUNT = 10;
    
  
    typedef enum {idle, get_y, get_x, get_tile_index, get_flags, done} states;
    states state;

    logic oam_y_start;
    logic oam_y_done;
    logic [15:0] oam_y_a;
    
    logic [47:0] oam_y_sprite_queue [9:0];
    fetch_oam_y #(.OAM_START(OAM_START), .OAM_END(OAM_END), .SPRITE_COUNT(SPRITE_COUNT)) oam_y(
        .clk(clk), .rst(rst), .start(oam_y_start),.done_out(oam_y_done),
        .LCDC(LCDC), .LY(LY),
        .oam_dout(oam_dout), .oam_a(oam_y_a),
        .sprite_queue(oam_y_sprite_queue)
    );
    
    logic oam_x_start;
    logic oam_x_done;
    logic [15:0] oam_x_a;
    logic [47:0] oam_x_sprite_queue [9:0];
    fetch_oam_x #(.OAM_START(OAM_START), .OAM_END(OAM_END), .SPRITE_COUNT(SPRITE_COUNT)) oam_x(
        .clk(clk), .rst(oam_x_start), .start(oam_x_start),.done_out(oam_x_done),
        .oam_dout(oam_dout), .oam_a(oam_x_a), 
        .sprite_queue_in(oam_y_sprite_queue), .sprite_queue_out(oam_x_sprite_queue)
    ); 
    
    logic oam_tile_index_start;
    logic oam_tile_index_done;
    logic [15:0] oam_tile_index_a;
    logic [47:0] oam_tile_index_sprite_queue [9:0];
    fetch_oam_tile_index #(.OAM_START(OAM_START), .OAM_END(OAM_END), .SPRITE_COUNT(SPRITE_COUNT)) oam_tile_index(
        .clk(clk), .rst(oam_tile_index_start), .start(oam_tile_index_start),.done_out(oam_tile_index_done),
        .oam_dout(oam_dout), .oam_a(oam_tile_index_a), 
        .sprite_queue_in(oam_x_sprite_queue), .sprite_queue_out(oam_tile_index_sprite_queue)
    ); 
    
    
    logic oam_flags_start;
    logic oam_flags_done;
    logic [15:0] oam_flags_a;
    logic [47:0] oam_flags_sprite_queue [9:0];
    fetch_oam_flags #(.OAM_START(OAM_START), .OAM_END(OAM_END), .SPRITE_COUNT(SPRITE_COUNT)) oam_flags(
        .clk(clk), .rst(oam_flags_start), .start(oam_flags_start),.done_out(oam_flags_done),
        .oam_dout(oam_dout), .oam_a(oam_flags_a), 
        .sprite_queue_in(oam_tile_index_sprite_queue), .sprite_queue_out(sprite_queue_out)
    ); 
     

    always_comb begin
        if(rst || start) begin
            oam_a = 0;
        end else if(state == get_y) begin
            oam_a = oam_y_a;
        end else if (state == get_x) begin 
            oam_a = oam_x_a;
        end else if (state == get_tile_index) begin
            oam_a = oam_tile_index_a;
        end else if (state == get_flags) begin
            oam_a = oam_flags_a;
        end         
    end 

    always_ff @(posedge clk) begin
        if(rst || start) begin
            for(int i = 0; i < SPRITE_COUNT; i++) begin oam_y_sprite_queue[i] <= 0; end 
            for(int i = 0; i < SPRITE_COUNT; i++) begin oam_x_sprite_queue[i] <= 0; end 
            for(int i = 0; i < SPRITE_COUNT; i++) begin oam_tile_index_sprite_queue[i] <= 0; end 
            for(int i = 0; i < SPRITE_COUNT; i++) begin oam_flags_sprite_queue[i] <= 0; end 
            
            oam_y_done <= 0;
            oam_y_a <= 0;
            oam_y_start <= 1;
            
            oam_x_start <= 0;
            oam_x_a <= 0;
            oam_x_done <= 0;
            
            oam_tile_index_start <= 0;
            oam_tile_index_a <= 0;
            oam_tile_index_done <= 0;
            
            oam_flags_start <= 0;
            oam_flags_a <= 0;
            oam_flags_done <= 0;
        
            done_out <= 0;
            state <= get_y;
        end else begin 
            if(state == get_y) begin
                oam_y_start <= 0;              
                if(oam_y_done) begin          
                    oam_x_start <= 1;
                    state <= get_x;       
                end 
            end else if (state == get_x) begin             
                oam_x_start <= 0;
                if(oam_x_done) begin
                    oam_tile_index_start <= 1;                   
                    state <= get_tile_index;
                end 
            end else if (state == get_tile_index) begin 
                oam_tile_index_start <= 0;
                if(oam_tile_index_done) begin                  
                    oam_flags_start <= 1;
                    state <= get_flags;
                end  
            end else if (state == get_flags) begin 
                oam_flags_start <= 0;               
                if(oam_flags_done) begin
                    done_out <= 1;
                    state <= done;
                end  
            end else if (state == done) begin
                done_out <= 0;
            end 
        end 
    end 
    //UNUSED PORTS    
    assign   oam_din = 0;
    assign   oam_wr = 0;
endmodule

module fetch_oam_y (
    //input wires 
    input wire clk,
    input wire rst, 
    input wire start,
    output logic done_out, 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    //Registers
    input wire [7:0] LCDC,
    input wire [7:0] LY,
    //Output Sprites 6 bytes 10 elements {Addr, Y, X, TILE_INDEX, FLAGS}
    output logic [47:0] sprite_queue [9:0]
    );
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9C;
    parameter SPRITE_COUNT = 10;
        
    typedef enum {idle, read, done} states;
    states state;
    
    logic [7:0] sprite_height;
    logic [3:0] index; 
    logic valid, valid_delay, valid_rd;
    
    always_ff @(posedge clk) begin
        if(rst || start) begin
            oam_a <= OAM_START;
            for(int i = 0; i < SPRITE_COUNT; i++) begin sprite_queue[i] <= 0; end 
            sprite_height <= (LCDC[2]) ? 16 : 8; 
            done_out <= 0;
            valid <= 1;
            index <= 0;
            state <= read;  
        end else begin 
            if(state == read) begin
                valid_delay <= valid;
                valid_rd <= valid_delay;
                if(valid_rd) begin 
                    if((oam_dout - 16 <= LY && oam_dout - 16 + sprite_height > LY) && index < SPRITE_COUNT) begin                     
                        sprite_queue[index] <= {oam_a - 16'h8, oam_dout, 8'b0, 8'b0, 8'b0}; 
                        index <= index + 1;
                    end     
                end else if (!valid_rd && !(oam_a >= OAM_START && oam_a < OAM_END)) begin
                        done_out <= 1;
                end 
                if(oam_a >= OAM_START && oam_a < OAM_END ) begin
                    oam_a <= oam_a + 16'h4;              
                end else begin
                    valid <= 0;
                end 
            end else if (state == done) begin
                done_out <= 0;
            end 
        end 
    end 
endmodule    

module fetch_oam_x (
    input wire clk, 
    input wire rst, 
    input wire start, 
    output logic done_out,
    input wire [47:0] sprite_queue_in [9:0],
    output logic [47:0] sprite_queue_out [9:0],
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a 
    );
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9F;
    parameter SPRITE_COUNT = 10;
    
    logic valid, valid_delay, valid_rd;
    logic [3:0] index, rd_index; 
    logic [1:0] done_count;
    always_comb begin
        if(start || rst) begin
            valid = 1;
        end else if (!(oam_a >= OAM_START && oam_a < OAM_END)) begin 
            valid = 0;
        end 
    end 
    typedef enum {idle, read, done} states;
    states state;
    always_ff @(posedge clk) begin
         if(rst || start) begin
            index <= 1; 
            rd_index <= 0;
            done_out <= 0;
            done_count <= 0;
            for(int i = 0; i < 10; i++) begin sprite_queue_out[i] <= 0; end
            oam_a <= sprite_queue_in[0][47:32] + 16'h1;
            state <= read;
         end else begin 
            if(state == read) begin
                valid_delay <= valid;
                valid_rd <= valid_delay;       
                if(valid_rd) begin
                    sprite_queue_out[rd_index] <= {sprite_queue_in[rd_index][47:24], oam_dout, 8'b0, 8'b0};
                    if(rd_index < SPRITE_COUNT) begin
                        rd_index <= rd_index+ 1;
                    end 
                end else if (!valid_rd && !(oam_a >= OAM_START && oam_a < OAM_END)) begin
                        done_out <= 1; 
                        state <= done;
                end
                if(oam_a >= OAM_START && oam_a < OAM_END) begin
                    oam_a <= sprite_queue_in[index][47:32] + 16'h1;                
                    if (index < SPRITE_COUNT) begin 
                        index <= index + 1;
                    end 
                end else begin
                    valid <= 0;
                end  
            end else if (state == done) begin
                done_out <= 0;
            end            
         end 
    end
endmodule 

module fetch_oam_tile_index (
    input wire clk, 
    input wire rst, 
    input wire start, 
    output logic done_out,
    input wire [47:0] sprite_queue_in [9:0],
    output logic [47:0] sprite_queue_out [9:0],
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a 
    );
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9F;
    parameter SPRITE_COUNT = 10;
    
    logic valid, valid_delay, valid_rd;
    logic [3:0] index, rd_index; 
    logic [1:0] done_count;
    always_comb begin
        if(start || rst) begin
            valid = 1;
        end else if (!(oam_a >= OAM_START && oam_a < OAM_END)) begin 
            valid = 0;
        end 
    end 
    typedef enum {idle, read, done} states;
    states state;
    always_ff @(posedge clk) begin
         if(rst || start) begin
            index <= 1; 
            rd_index <= 0;
            done_out <= 0;
            done_count <= 0;
            for(int i = 0; i < 10; i++) begin sprite_queue_out[i] <= 0; end
            oam_a <= sprite_queue_in[0][47:32] + 16'h2;
            state <= read;
         end else begin 
            if(state == read) begin
                valid_delay <= valid;
                valid_rd <= valid_delay;       
                if(valid_rd) begin
                    sprite_queue_out[rd_index] <= {sprite_queue_in[rd_index][47:16], oam_dout, 8'b0};
                    if(rd_index < SPRITE_COUNT) begin
                        rd_index <= rd_index+ 1;
                    end 
                end else if (!valid_rd && !(oam_a >= OAM_START && oam_a < OAM_END)) begin
                        done_out <= 1; 
                        state <= done;
                end
                if(oam_a >= OAM_START && oam_a < OAM_END) begin
                    oam_a <= sprite_queue_in[index][47:32] + 16'h2;                
                    if (index < SPRITE_COUNT) begin 
                        index <= index + 1;
                    end 
                end else begin
                    valid <= 0;
                end  
            end else if (state == done) begin
                done_out <= 0;
            end            
         end 
    end
endmodule 

module fetch_oam_flags (
    input wire clk, 
    input wire rst, 
    input wire start, 
    output logic done_out,
    input wire [47:0] sprite_queue_in [9:0],
    output logic [47:0] sprite_queue_out [9:0],
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a 
    );
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9F;
    parameter SPRITE_COUNT = 10;
    
    logic valid, valid_delay, valid_rd;
    logic [3:0] index, rd_index; 
    logic [1:0] done_count;
    always_comb begin
        if(start || rst) begin
            valid = 1;
           
        end else if (!(oam_a >= OAM_START && oam_a < OAM_END)) begin 
            valid = 0;
        end 
    end 
    typedef enum {idle, read, done} states;
    states state;
    always_ff @(posedge clk) begin
         if(rst || start) begin
            index <= 1; 
            rd_index <= 0;
            done_out <= 0;
            done_count <= 0;
            for(int i = 0; i < 10; i++) begin sprite_queue_out[i] <= 0; end
            oam_a <= sprite_queue_in[0][47:32] + 16'h3;
            state <= read;
         end else begin 
            if(state == read) begin
                valid_delay <= valid;
                valid_rd <= valid_delay;       
                if(valid_rd) begin
                    sprite_queue_out[rd_index] <= {sprite_queue_in[rd_index][47:8], oam_dout};
                    if(rd_index < SPRITE_COUNT) begin
                        rd_index <= rd_index+ 1;
                    end 
                end else if (!valid_rd && !(oam_a >= OAM_START && oam_a < OAM_END)) begin
                        done_out <= 1; 
                        state <= done;
                end
                if(oam_a >= OAM_START && oam_a < OAM_END) begin
                    oam_a <= sprite_queue_in[index][47:32] + 16'h3;                
                    if (index < SPRITE_COUNT) begin 
                        index <= index + 1;
                    end 
                end else begin
                    valid <= 0;
                end  
            end else if (state == done) begin
                done_out <= 0;
            end            
         end 
    end
endmodule

`default_nettype wire