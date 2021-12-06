`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2021 06:05:03 PM
// Design Name: 
// Module Name: mode_3_fsm
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
module mode_3_fsm(
    input wire clk, 
    input wire rst, 
    input wire start,
    output logic done_out,
    // DATA BUS, 0x8000 - 0x9FFF 
    input  wire  [7:0]  vram_dout,
    output logic [15:0] vram_a,
    output logic [7:0]  vram_din,
    output logic        vram_wr, 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    output logic [7:0]  oam_din,
    output logic        oam_wr, 
    //SPRITE QUEUE
    input wire [47:0] sprite_queue [9:0],
    // REGISTERS
    input wire [7:0] LCDC,
    input wire [7:0] SCX,
    input wire [7:0] SCY, 
    input wire [7:0] LY,
    input wire [7:0] WX,
    input wire [7:0] WY,
    input wire [7:0] BGP,
    input wire [7:0] OBP0,
    input wire [7:0] OBP1,
    //PIXEL_OUT
    output logic [1:0] pixel_out,
    output logic [14:0] lcd_addr,
    output logic lcd_write,
    //DEBUG
    output logic [7:0] h_count,
    output logic [11:0] mode_3_cycles
    );
    parameter MAX_X = 160;
    //Pixel Fetcher FSM 
    logic pixel_fetcher_fsm_start, pixel_fetcher_fsm_done;
    logic [7:0] bg_pixel_x_to_fifo, sprite_pixel_x_to_fifo;
    logic sprite_on_curr_tile;
   
    //BG WINDOW FIFO 
    logic [5:0] fifo_bg_window_data_in, fifo_bg_window_data_out;
    logic fifo_bg_window_empty, fifo_bg_window_full;
    logic fifo_bg_window_wr_en, fifo_bg_window_rd_en;
    logic fifo_bg_window_valid, fifo_bg_window_empty_almost;
    logic fifo_bg_window_has_8;
    
    // SPRITE FIFO 
    logic [5:0] fifo_sprite_data_in, fifo_sprite_data_out;
    logic fifo_sprite_empty, fifo_sprite_full;
    logic fifo_sprite_wr_en, fifo_sprite_rd_en;
    logic fifo_sprite_valid, fifo_sprite_empty_almost;
    logic fifo_sprite_has_8;
 
    
    //INIT
    fetcher_fsm uut(
        .clk(clk), .rst(pixel_fetcher_fsm_start), .start(pixel_fetcher_fsm_start),.done_out(pixel_fetcher_fsm_done),
        //INPUT REGISTERS
        .LCDC(LCDC), .LY(LY),.SCX(SCX),.SCY(SCY),.WX(WX),.WY(WY),
        //INPUTS FROM FIFOs 
        .bg_window_fifo_empty(fifo_bg_window_empty_almost),
        //OUTPUTS TO FIFOs
        .sprite_fifo_write(fifo_sprite_wr_en), .bg_window_fifo_write(fifo_bg_window_wr_en),
        .sprite_pixel_out(fifo_sprite_data_in), .bg_window_pixel_out(fifo_bg_window_data_in),  
        //VRAM DATA BUS, 0x8000 - 0x9FFF 
        .vram_dout(vram_dout), .vram_a(vram_a), .vram_din(vram_din), .vram_wr(vram_wr), 
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout), .oam_a(oam_a), .oam_din(oam_din), .oam_wr(oam_wr),
        //INPUT FOR SPRITE
        .sprite_queue(sprite_queue),
        //DEBUG
        .bg_pixel_x_to_fifo(bg_pixel_x_to_fifo),
        .sprite_pixel_x_to_fifo(sprite_pixel_x_to_fifo),
        .sprite_on_curr_tile(sprite_on_curr_tile)
    );   
        
    fifo fifo_bg_window(
          .clk(clk), .srst(start),
          .wr_en(fifo_bg_window_wr_en), .rd_en(fifo_bg_window_rd_en), 
          .din(fifo_bg_window_data_in), .dout(fifo_bg_window_data_out), 
          .full(fifo_bg_window_full),.empty(fifo_bg_window_empty),             
          .almost_empty(fifo_bg_window_empty_almost), .valid(fifo_bg_window_valid),
          //Might Not be Needed
          .prog_full(fifo_bg_window_has_8)             
    );
    
    fifo fifo_sprite(
          .clk(clk), .srst(start),
          .wr_en(fifo_sprite_wr_en), .rd_en(fifo_sprite_rd_en), 
          .din(fifo_sprite_data_in), .dout(fifo_sprite_data_out), 
          .full(fifo_sprite_full),.empty(fifo_sprite_empty),             
          .almost_empty(fifo_sprite_empty_almost), .valid(fifo_sprite_valid),
          //Might Not be Needed
          .prog_full(fifo_sprite_has_8)             
    );
       
        
//        renderer render(
//            .v_count(LY),.h_count(h_count),
//            .BGP(BGP),.OBP0(OBP0), .OBP1(OBP1),
//            .bg__window_pixel_in(fifo_bg_window_data_out), .valid_in(fifo_bg_window_valid),            
//            .pixel_out(pixel_out),.lcd_addr_out(lcd_addr),.write_out(lcd_write) 
       
//        );
        
        //MODE 3 FSM LOGICs
        typedef enum {init, rendering_tiles, wait_for_bg, wait_for_sprite, wait_for_empty, done} states;
        states state;
        
       

        always_ff @(posedge clk) begin
            if(rst || start) begin 
                pixel_fetcher_fsm_start <=  1;           
                fifo_bg_window_rd_en <= 0;
                fifo_sprite_rd_en <= 0;
                done_out <= 0;  
                
                sprite_on_curr_tile <= 0;
                
                state <= rendering_tiles;
            end else begin  
                if(state == rendering_tiles) begin   
                   pixel_fetcher_fsm_start <=  0;    
                   if(sprite_on_curr_tile) begin
                        //&& !fifo_bg_window_wr_en && !fifo_sprite_wr_en
                        fifo_bg_window_rd_en <= 0;
                        fifo_sprite_rd_en <= 0;    
                        state <= wait_for_bg;
                    end else if (h_count >= MAX_X - 1) begin
                        done_out  <= 1;   
                        fifo_bg_window_rd_en <= 0;
                        fifo_sprite_rd_en <= 0;       
                        state <= done;
                    end else begin 
                        fifo_bg_window_rd_en <= 1;
                    end 
          
                end else if (state == wait_for_bg) begin
                    if(fifo_bg_window_has_8) begin                    
                        state <= wait_for_sprite;       
                    end
                end else if (state == wait_for_sprite) begin
                    if(fifo_sprite_has_8) begin
                        fifo_bg_window_rd_en <= 1;
                        fifo_sprite_rd_en <= 1; 
                        state <= wait_for_empty;       
                    end 
                end else if (state == wait_for_empty) begin
                    if (fifo_sprite_empty_almost && fifo_bg_window_empty_almost) begin
                        state <= rendering_tiles;
                    end
                end else if (state == done) begin
                    done_out <= 0;
                end   
             end 
        end 
        always_ff @(posedge clk) begin
            if(rst || start) begin
                h_count <= 0;
            end else begin
                if (fifo_bg_window_valid) begin
                    h_count <= h_count + 1;
                end 
            end 
        end 
        always_ff @(posedge clk) begin
            if(rst || start) begin
                mode_3_cycles <= 0;
            end else begin
                if(h_count < MAX_X) begin
                    mode_3_cycles <= mode_3_cycles + 1;
                end 
            end 
        end 
 endmodule


module renderer(
        //LCD Logic
        input wire [7:0] h_count, 
        input wire [7:0] v_count, 
        input wire [5:0] pixel_in,
        output logic [1:0] pixel_out,
        //LCD RAM 
        input wire valid_in,
        output logic [14:0] lcd_addr_out, 
        output logic write_out
    );
    

    
    always_comb begin
        lcd_addr_out  = h_count + 160*v_count;
        write_out = valid_in;
        pixel_out = pixel_in[5:4];
    end 
endmodule
`default_nettype wire