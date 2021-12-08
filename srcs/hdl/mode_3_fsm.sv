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
//        //OAM Data Bus, 0xFE00 - 0xFE9F 
//        input  wire  [7:0]  oam_dout,
//        output logic [15:0] oam_a,
//        output logic [7:0]  oam_din,
//        output logic        oam_wr, 
        //SPRITE QUEUE
        input wire [9:0][47:0] sprite_queue ,
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
        output logic [15:0] lcd_a,
        output logic lcd_wr,
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
        fetcher_fsm fetcher(
            .clk(clk), .rst(pixel_fetcher_fsm_start), .start(pixel_fetcher_fsm_start),.done_out(pixel_fetcher_fsm_done),
            //INPUT REGISTERS
            .LCDC(LCDC), .LY(LY),.SCX(SCX),.SCY(SCY),.WX(WX),.WY(WY),
            //INPUTS FROM FIFOs 
            .bg_window_fifo_empty(fifo_bg_window_empty_almost),.sprite_fifo_empty(fifo_sprite_empty_almost),
            //OUTPUTS TO FIFOs
            .sprite_fifo_write(fifo_sprite_wr_en), .bg_window_fifo_write(fifo_bg_window_wr_en),
            .sprite_pixel_out(fifo_sprite_data_in), .bg_window_pixel_out(fifo_bg_window_data_in),  
            //VRAM DATA BUS, 0x8000 - 0x9FFF 
            .vram_dout(vram_dout), .vram_a(vram_a), .vram_din(vram_din), .vram_wr(vram_wr), 
            //OAM Data Bus, 0xFE00 - 0xFE9F 
            //.oam_dout(oam_dout), .oam_a(oam_a), .oam_din(oam_din), .oam_wr(oam_wr),
            //INPUT FOR SPRITE
            .sprite_queue(sprite_queue),
            //DEBUG
            .bg_pixel_x_to_fifo(bg_pixel_x_to_fifo),.sprite_pixel_x_to_fifo(sprite_pixel_x_to_fifo)
        );   
        
        fifo fifo_bg_window(
              .clk(clk), .srst(start),
              .wr_en(fifo_bg_window_wr_en), .rd_en(fifo_bg_window_rd_en), 
              .din(fifo_bg_window_data_in), .dout(fifo_bg_window_data_out), 
              .full(fifo_bg_window_full),.empty(fifo_bg_window_empty),             
              .almost_empty(fifo_bg_window_empty_almost), .valid(fifo_bg_window_valid)        
        );
    
        fifo fifo_sprite(
              .clk(clk), .srst(start),
              .wr_en(fifo_sprite_wr_en), .rd_en(fifo_sprite_rd_en), 
              .din(fifo_sprite_data_in), .dout(fifo_sprite_data_out), 
              .full(fifo_sprite_full),.empty(fifo_sprite_empty),             
              .almost_empty(fifo_sprite_empty_almost), .valid(fifo_sprite_valid)         
        );
       
        
        renderer render(
            .v_count(LY),.h_count(h_count),
            .BGP(BGP),.OBP0(OBP0), .OBP1(OBP1),
            .bg_window_pixel_in(fifo_bg_window_data_out),.sprite_pixel_in(fifo_sprite_data_out),
            .bg_window_valid_in(fifo_bg_window_valid),.sprite_valid_in(fifo_sprite_valid),            
            .pixel_out(pixel_out),.lcd_addr_out(lcd_a),.write_out(lcd_wr) 
       
        );
        
        //MODE 3 FSM LOGICs
        typedef enum {idle,rendering_tiles, done} states;
        states state;
        always_ff @(posedge clk) begin
            if(start || rst) begin 
                fifo_bg_window_rd_en <= 0;
                fifo_sprite_rd_en <= 0;
                pixel_fetcher_fsm_start <=  1;   
                done_out <= 0;
                state <= rendering_tiles;
            end else begin
                pixel_fetcher_fsm_start <=  0;
                if(state == rendering_tiles) begin 
                     if(fifo_bg_window_wr_en && fifo_sprite_wr_en) begin
                        fifo_bg_window_rd_en <= 1;
                        fifo_sprite_rd_en <= 1;
                     end else if (fifo_bg_window_wr_en) begin
                        fifo_bg_window_rd_en <= 1;
                        fifo_sprite_rd_en <= 0;
                     end 
                     if (h_count == MAX_X - 1) begin
                        done_out  <= 1;   
                        fifo_bg_window_rd_en <= 0;
                        fifo_sprite_rd_en <= 0;       
                        state <= done;
                     end
                end else if (state == done) begin
                    done_out  <= 0;
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
        input wire [5:0] bg_window_pixel_in,
        input wire [5:0] sprite_pixel_in,
        input wire bg_window_valid_in,
        input wire sprite_valid_in,
        input wire [7:0] BGP,
        input wire [7:0] OBP0,
        input wire [7:0] OBP1,
        //LCD RAM  
        input wire [7:0] h_count, 
        input wire [7:0] v_count, 
        output logic [15:0] lcd_addr_out, 
        output logic write_out,
        //pixel_out
        output logic [1:0] pixel_out
    );
    always_comb begin
        lcd_addr_out  = h_count + 160*v_count;
        write_out = bg_window_valid_in || sprite_valid_in;
        if (sprite_valid_in && bg_window_valid_in) begin
            case(bg_window_pixel_in[5:4]) 
                2'd0 : begin  //index 0 
                            if (BGP[1:0] > 0 && sprite_pixel_in[0]) begin
                                pixel_out = BGP[1:0];
                            end else begin
                                if (sprite_pixel_in[1]) begin
                                    case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[1:0];
                                        2'd1 : pixel_out = OBP1[3:2];
                                        2'd2 : pixel_out = OBP1[5:4];
                                        2'd3 : pixel_out = OBP1[7:6];
                                    endcase 
                                end else begin
                                     case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[1:0];
                                        2'd1 : pixel_out = OBP0[3:2];
                                        2'd2 : pixel_out = OBP0[5:4];
                                        2'd3 : pixel_out = OBP0[7:6];
                                    endcase 
                                end
                            end             
                        end
                2'd1 : begin 
                           if (BGP[3:2] > 0 && sprite_pixel_in[0]) begin
                                pixel_out = BGP[3:2];
                            end else begin
                                if (sprite_pixel_in[1]) begin
                                    case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[3:2];
                                        2'd1 : pixel_out = OBP1[3:2];
                                        2'd2 : pixel_out = OBP1[5:4];
                                        2'd3 : pixel_out = OBP1[7:6];
                                    endcase 
                                end else begin
                                     case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[3:2];
                                        2'd1 : pixel_out = OBP0[3:2];
                                        2'd2 : pixel_out = OBP0[5:4];
                                        2'd3 : pixel_out = OBP0[7:6];
                                    endcase 
                                end
                            end  
                       end
                2'd2 : begin
                            if (BGP[5:4] > 0 && sprite_pixel_in[0]) begin
                                pixel_out = BGP[5:4];
                            end else begin
                                if (sprite_pixel_in[1]) begin
                                    case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[5:4];
                                        2'd1 : pixel_out = OBP1[3:2];
                                        2'd2 : pixel_out = OBP1[5:4];
                                        2'd3 : pixel_out = OBP1[7:6];
                                    endcase 
                                end else begin
                                     case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[5:4];
                                        2'd1 : pixel_out = OBP0[3:2];
                                        2'd2 : pixel_out = OBP0[5:4];
                                        2'd3 : pixel_out = OBP0[7:6];
                                    endcase 
                                end
                            end  
                       end
                2'd3 : begin 
                            if (BGP[7:6] > 0 && sprite_pixel_in[0]) begin
                                pixel_out = BGP[7:6];
                            end else begin
                                if (sprite_pixel_in[1]) begin
                                    case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[7:6];
                                        2'd1 : pixel_out = OBP1[3:2];
                                        2'd2 : pixel_out = OBP1[5:4];
                                        2'd3 : pixel_out = OBP1[7:6];
                                    endcase 
                                end else begin
                                     case(sprite_pixel_in[5:4]) 
                                        2'd0 : pixel_out = BGP[7:6];
                                        2'd1 : pixel_out = OBP0[3:2];
                                        2'd2 : pixel_out = OBP0[5:4];
                                        2'd3 : pixel_out = OBP0[7:6];
                                    endcase 
                                end
                            end   
                       end                 
            endcase
        end else if (bg_window_valid_in) begin
            case(bg_window_pixel_in[5:4])
                 2'd0 : pixel_out = BGP[1:0]; 
                 2'd1 : pixel_out = BGP[3:2];
                 2'd2 : pixel_out = BGP[5:4];
                 2'd3 : pixel_out = BGP[7:6];
            endcase 
        end else begin
            pixel_out = 0;
        end 
    end 
endmodule
`default_nettype wire