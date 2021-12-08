
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2021 06:59:03 PM
// Design Name: 
// Module Name: fetcher_fsm
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
module fetcher_fsm(
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
    // REGISTERS
    input wire [7:0] LCDC, 
    input wire [7:0] SCX, 
    input wire [7:0] SCY, 
    input wire [7:0] LY, 
    input wire [7:0] WX, 
    input wire [7:0] WY,
    //OAM QUEUE 
    //{16'b Addr, 8'bY, 8'bX, 8'bTile Index, 8'bFlags}
    input wire [9:0][47:0] sprite_queue ,
    //INPUT FROM FIFO
    input wire bg_window_fifo_empty,
    input wire sprite_fifo_empty,
    //OUTPUT TO FIFOs
    output logic sprite_fifo_write,
    output logic bg_window_fifo_write,
    output logic [5:0] bg_window_pixel_out,
    output logic [5:0] sprite_pixel_out,
    //DEBUG
    output logic [7:0] bg_pixel_x_to_fifo,
    output logic [7:0] sprite_pixel_x_to_fifo
    );   

    
    
    /*PARAMS*/
    parameter INIT_CYCLES = 4;
    parameter GET_TILE_CYCLES = 2; 
    parameter GET_TILE_DATA_LOW_CYCLES = 2;
    parameter GET_TILE_DATA_HIGH_CYCLES = 2;
    parameter SLEEP_CYCLES = 1;
    
    parameter OAM_START = 16'hFE00;
    parameter OAM_END = 16'hFE9C;
    
    parameter PIXELS_PER_TILE = 8;
    parameter MAX_SPRITE = 10;
    parameter MAX_X = 160;
    ///////////////////////////////////////////////////////////////////////////////////////            
    /*BG WINDOW PIXEL FSM STATE LOGIC */
    typedef enum {idle, init, get_tile, get_tile_data_low, get_tile_data_high, sleep, push, 
                  sprite_get_tile, sprite_get_tile_data_low, sprite_get_tile_data_high, sprite_sleep, sprite_push, done} states;
    states state;
    logic [3:0] state_count;
    ///////////////////////////////////////////////////////////////////////////////////////            
    /*BG WINDOW PIXEL FSM LOGIC */
    logic [7:0] fetcherX, fetcherY, fetcherX_next, fetcherY_next;
    logic [7:0] tile_0_data, tile_1_data;              
    logic [7:0] tilemapX; // [0, 14)
    logic current_tile_in_window;
    logic current_tile_almost_in_window;
    logic valid_bg_window_row;
   
    ///////////////////////////////////////////////////////////////////////////////////////
    /*BG WINDOW PIXEL LOGIC */
    logic [7:0][5:0] pixel_row_bg_window;
    logic [7:0] LX; //same as Tile Map X but starts after pixel row is valid
    logic [7:0] SLX;
    logic [2:0] bg_window_pixel_index; 
    logic [2:0] sprite_pixel_index;
      
    ///////////////////////////////////////////////////////////////////////////////////////
    /*SPRITE PIXEL FSM LOGIC */
    logic [7:0][5:0] pixel_row_sprite;
    (* ASYNC_REG = "TRUE" *) reg [9:0][7:0][5:0] pixel_rows_sprite;
    (* ASYNC_REG = "TRUE" *) reg [9:0][51:0] sprites_on_curr_tile ;
    logic sprite_on_curr_tile;
    logic [7:0] sprite_tile_0_data, sprite_tile_1_data;   
    logic [3:0] sprite_index, sprite_i; 
    logic valid_sprite_row;
    logic [15:0] fetcher_vram_out;
    ///////////////////////////////////////////////////////////////////////////////////////
    /*TEMP VARIABLES */

    logic [2:0] sprite_shift;    
    assign sprite_shift = sprites_on_curr_tile[sprite_index][51:49];
    sprite_fetcher_vram_a get_vram_a(.LCDC(LCDC), .LY(LY),
            .sprite_queue_in(sprites_on_curr_tile), .index(sprite_i),
            .vram_a_out(fetcher_vram_out)
            );
       
    ///////////////////////////////////////////////////////////////////////////////////////
    always_comb begin 
        current_tile_in_window = (WX - 7 <= ((tilemapX) << 3) && WX - 7 + MAX_X >= ((tilemapX )<< 3)) && (WY <= LY);
        current_tile_almost_in_window = (WX - 7 <= ((tilemapX + 2) << 3) && WX - 7 + MAX_X >= ((tilemapX  + 2)<< 3)) && (WY <= LY);
    
        fetcherX = (LCDC[5] && current_tile_in_window) ?  (tilemapX) - (WX >> 3) : ((SCX >> 3) + tilemapX) & 8'h1F;
        fetcherY = (LCDC[5] && current_tile_in_window) ?  LY - WY : (SCY + LY) & 8'd255;
        
        fetcherX_next = (LCDC[5] && current_tile_almost_in_window) ?  (tilemapX + 2) - (WX >> 3) : ((SCX >> 3) + tilemapX + 1) & 8'h1F;
        fetcherY_next = (LCDC[5] && current_tile_almost_in_window) ?  LY - WY : (SCY + LY) & 8'd255;
        
        
    end 
    
    always_ff @(posedge clk)  begin
        if(rst || start) begin
            //OUPUTS 
            
            done_out <= 0;          
            //INTERNAL LOGIC            
            tile_0_data <= 0;
            tile_1_data <= 0;
            tilemapX <= 0;
            LX <= 0;
            valid_bg_window_row <=0;
            sprite_index <= 0;
            sprite_i <= 0;
            valid_sprite_row <= 0;
            for (int i = 0;i < 10 ;i++) begin
                for (int j  =0;j < 8; j++) begin
                    pixel_rows_sprite[i][j] <= {6'b0};
                end 
            end
            //VRAM
            if (LCDC[5] && (WX - 7 <= 0 && WX - 7 + MAX_X >= 0) && (WY <= LY)) begin 
                vram_a <= ((LCDC[6]) ? 16'h9C00 : 16'h9800) + (WX >> 3)  + (((LY - WY) >> 3) << 5);
            end else if( LCDC[0]) begin
                vram_a <= ((LCDC[3]) ? 16'h9C00 : 16'h9800) + (SCX >> 3)  + (((SCY  + LY) >> 3) << 5);
            end      
      
            //STATE LOGIC
            state_count  <= 0;
            state <= init;   
        end else begin
            if (state == init) begin
                    if(state_count == INIT_CYCLES - 1) begin             
                        if(LCDC[4]) begin
                            vram_a <= 16'h8000 + {4'b0, vram_dout ,4'b0} + ((fetcherY[2:0]) << 1);
                        end else begin
                            if(vram_dout >= 128) begin
                                vram_a <=  16'h8800 + ((vram_dout - 128) << 4) + ((fetcherY[2:0]) << 1);
                            end else begin
                                vram_a <=  16'h9000 + ((vram_dout) << 4 ) + ((fetcherY[2:0]) << 1);
                            end 
                        end
                        state_count <= 0;
                        state <= get_tile;   
                    end else begin 
                        state_count <= state_count + 1; 
                    end 
            end else if (state == get_tile) begin
                    if (state_count == GET_TILE_CYCLES - 1) begin                        
                        state_count <= 0; 
                        state <= get_tile_data_low;
                    end else begin ;
                        if(LCDC[4]) begin
                            vram_a <= 16'h8000 + {4'b0, vram_dout ,4'b0} + ((fetcherY[2:0]) << 1);
                        end else begin
                            if(vram_dout >= 128) begin
                                vram_a <=  16'h8800 + ((vram_dout - 128) << 4) + ((fetcherY[2:0]) << 1);
                            end else begin
                                vram_a <=  16'h9000 + ((vram_dout) << 4 ) + ((fetcherY[2:0]) << 1);
                            end 
                        end
                       
                        state_count <= state_count + 1;
                    end
            end else if (state == get_tile_data_low) begin
                    if (state_count == GET_TILE_DATA_LOW_CYCLES - 1) begin  
                        tile_0_data <= vram_dout;
                        state_count <= 0;
                        state <= get_tile_data_high; 
                    end else begin  
                        vram_a <= vram_a + 1;
                        state_count <= state_count + 1;
                    end   
            end else if (state == get_tile_data_high) begin
                    if (state_count == GET_TILE_DATA_HIGH_CYCLES - 1) begin  
                        tile_1_data <= vram_dout;
                        if (!(sprite_on_curr_tile && LCDC[1])) begin 
                            if (LCDC[5] && current_tile_almost_in_window) begin 
                                vram_a <= ((LCDC[6]) ? 16'h9C00 : 16'h9800) + fetcherX_next + ((fetcherY_next >> 3) << 5);
                            end else if(LCDC[0]) begin
                                vram_a <= ((LCDC[3]) ? 16'h9C00 : 16'h9800) + fetcherX_next + ((fetcherY_next >> 3) << 5);
                            end                            
                        end
                        state_count <= 0;
                        state <= sleep; 
                    end else begin  
                         
                        state_count <= state_count + 1;
                    end 
            end else if (state == sleep) begin
                    if (state_count == SLEEP_CYCLES - 1) begin  
                        state_count <= 0;
                        
                        state <= push; 
                    end else begin  
                        state_count <= state_count + 1;
                    end 
            end else if (state == push) begin
                    if (bg_window_fifo_empty) begin
                        valid_sprite_row <= 0;
                        valid_bg_window_row <= (sprite_on_curr_tile) ? 0 : 1;
                        state_count <= 0;
                        
                        for(int i = 0; i < 8; i++) begin 
                            pixel_row_bg_window[i] <= (LCDC[0]) ? {tile_1_data[i],tile_0_data[i],3'b0, 1'b0} : 6'b0;
                        end
                        if (sprite_on_curr_tile && LCDC[1]) begin 
                            sprite_index <= 0;
                            sprite_i <= 0;
                            vram_a <= fetcher_vram_out;
                            for (int i = 0;i < 10 ;i++) begin
                                for (int j  =0;j < 8; j++) begin
                                    pixel_rows_sprite[i][j] <= {6'b0};
                                end 
                            end
                            state <= sprite_get_tile;
                        end else begin 
                            
                            if(tilemapX > (MAX_X >> 3) - 1)  begin
                                valid_bg_window_row <= 0;
                                done_out <= 1;
                                state <= done;
                            end else begin 
                                tilemapX <= tilemapX + 1;
                                state <= get_tile;
                            end 
                        end 
                        
                    end else begin
                        valid_bg_window_row <= 0;
                        valid_sprite_row <= 0;
                        state <= push;
                    end 
            end else if (state == sprite_get_tile) begin 
                    if(state_count == 1) begin
                        state_count <= 0;
                        
                        state <= sprite_get_tile_data_low;
                    end else begin
                        state_count <= state_count + 1;
                    end 
            
            end else if (state == sprite_get_tile_data_low) begin
                    if(state_count == 1) begin
                        state_count <= 0;
                        sprite_tile_0_data <= vram_dout;
                        state <= sprite_get_tile_data_high;
                    end else begin
                        state_count <= state_count + 1;
                        vram_a <= vram_a + 1;
                    end 
                    
            end else if (state == sprite_get_tile_data_high) begin
                    if(state_count == 1) begin
                        state_count <= 0;
                        sprite_tile_1_data <= vram_dout;
                        state <= sprite_sleep;
                        if (! (sprites_on_curr_tile[sprite_index + 1][47:32] >= OAM_START &&  sprites_on_curr_tile[sprite_index + 1][47:32] < OAM_END) ) begin
                            if (LCDC[5] && current_tile_almost_in_window) begin 
                                vram_a <= ((LCDC[6]) ? 16'h9C00 : 16'h9800) + fetcherX_next + ((fetcherY_next >> 3) << 5);
                            end else if(LCDC[0]) begin
                                vram_a <= ((LCDC[3]) ? 16'h9C00 : 16'h9800) + fetcherX_next + ((fetcherY_next >> 3) << 5);
                            end
                            
                            sprite_i <= 0;
                        end else begin
                            sprite_i <= sprite_i  + 1;
                        end 
                    end else begin
                        state_count <= state_count + 1;
                       
                    end
            end else if (state == sprite_sleep )begin 
                    if (state_count == 0) begin  
                        state_count <= 0;
                        state <= sprite_push; 

                    end else begin  
                        state_count <= state_count + 1;
                        
                        
                    end 
            end else if(state == sprite_push)  begin 
                    valid_bg_window_row <= 0;
                    state_count <= 0;
                          
                    if(sprites_on_curr_tile[sprite_index][5]) begin 
                        for(int i = 0; i < 8 ; i++) begin 
                            if(sprites_on_curr_tile[sprite_index][48]) begin
                                if (7 - i >= sprite_shift) begin
                                    pixel_rows_sprite[sprite_index][i] <= {6'b0};
                                end else begin 
                                    pixel_rows_sprite[sprite_index][i] <=  {sprite_tile_1_data[(7 - i) + (8 - sprite_shift)],sprite_tile_0_data[(7 - i) + (8 - sprite_shift)], 2'b0 ,sprites_on_curr_tile[sprite_index][4] , sprites_on_curr_tile[sprite_index][7]};
                                end        
                            end else begin 
                                if (7 - i < sprite_shift) begin 
                                    pixel_rows_sprite[sprite_index][i] <= {6'b0};
                                end else begin 
                                     pixel_rows_sprite[sprite_index][i] <=  {sprite_tile_1_data[(7 - sprite_shift) - i],sprite_tile_0_data[(7 - sprite_shift) - i], 2'b0 ,sprites_on_curr_tile[sprite_index][4] , sprites_on_curr_tile[sprite_index][7]};                                  
                                end
                            end 
                        end
                    end else begin
                        for(int i = 0; i < 8; i++) begin 
                            if(sprites_on_curr_tile[sprite_index][48]) begin
                                if (7 - i >= sprite_shift) begin
                                    pixel_rows_sprite[sprite_index][i] = 0;
                                end else begin 
                                    pixel_rows_sprite[sprite_index][i] <=  {sprite_tile_1_data[ i - (8 - sprite_shift) ],sprite_tile_0_data[ i - (8 - sprite_shift) ], 2'b0 ,sprites_on_curr_tile[sprite_index][4] , sprites_on_curr_tile[sprite_index][7]};
                                end          
                            end else begin 
                                if (7 - i < sprite_shift ) begin
                                    pixel_rows_sprite[sprite_index][i] <= {6'b0};
                                end else begin 
                                    pixel_rows_sprite[sprite_index][i] <=  {sprite_tile_1_data[i + sprite_shift],sprite_tile_0_data[i + sprite_shift], 2'b0 ,sprites_on_curr_tile[sprite_index][4] , sprites_on_curr_tile[sprite_index][7]};
                                end    
                            end
                        end
                    end 
    
    
                    if ( sprites_on_curr_tile[sprite_index + 1][47:32] >= OAM_START &&  sprites_on_curr_tile[sprite_index + 1][47:32] < OAM_END) begin 
                        sprite_index <= sprite_index + 1;
                        
                        vram_a <= fetcher_vram_out;
                        state <= sprite_get_tile;
                    end else begin 
                        sprite_index <= 0;
                        valid_sprite_row <= 1;
                        valid_bg_window_row <= 1;
                        if(tilemapX > (MAX_X >> 3) - 1)  begin
                            done_out <= 1;
                            state <= done;
                        end else begin 
                            
                            tilemapX <= tilemapX + 1;
                            state <= get_tile;
                        end 
                    end 
                          
            end else if (state == done) begin
                    done_out <= 0;
            end      
            //CURRENT BG WINDOW PIXEL BEING OUTPUTED BY FSM     
            if(valid_bg_window_row) begin
                LX <= LX + 1; 
            end 
        end
    end  
    ////////////////  ////////////////  ////////////////  ////////////////  ////////////////  ////////////////
    ////SPRITE RENDER 
    always_ff @(posedge clk) begin
        if (start || rst) begin
      
             sprite_pixel_out <= 0;
             sprite_fifo_write <= 0;
             sprite_pixel_index <= 0;
             sprite_pixel_x_to_fifo <= 0;
        end else begin
            if(valid_sprite_row) begin 
                if(LX >> 3 == 0) begin    
                    sprite_pixel_index <= sprite_pixel_index + 1;                                   
                    if(sprite_pixel_index >= SCX[2:0]) begin            
                        sprite_fifo_write <= 1;
                        sprite_pixel_x_to_fifo <= (sprite_fifo_write) ? sprite_pixel_x_to_fifo + 1 : 0;
                        sprite_pixel_out <= pixel_row_sprite[PIXELS_PER_TILE - 1 - sprite_pixel_index];
                    end 
                 end else if (LX >> 3 > 0 && LX >> 3 < 20) begin
                    sprite_fifo_write <= 1; 
                    sprite_pixel_index <= sprite_pixel_index + 1; 
                    sprite_pixel_x_to_fifo <= bg_pixel_x_to_fifo;
                    sprite_pixel_out <= pixel_row_sprite[PIXELS_PER_TILE - 1 - sprite_pixel_index];
                 end 
            end else if (LX >> 3 == 20 && sprite_fifo_write) begin
                    sprite_pixel_index <= sprite_pixel_index + 1;
                    sprite_pixel_x_to_fifo <= bg_pixel_x_to_fifo;
                    if(sprite_pixel_index < SCX[2:0]) begin
                        sprite_fifo_write <= 1; 
                        sprite_pixel_out <= pixel_row_sprite[PIXELS_PER_TILE - 1 - sprite_pixel_index];
                    end else begin 
                        sprite_fifo_write <= 0;
                    end
            end else begin 
                    sprite_fifo_write <= 0;                  
            end
        end
    end
    ////SCX FOR BACKGROUND PIXELS 
    //Handles Rendering with SCX % 8 > 0
    always_ff @(posedge clk) begin
        if(rst || start) begin
            bg_window_pixel_out <= 0;
            bg_window_pixel_index <= 0;
            bg_window_fifo_write <= 0;   
            bg_pixel_x_to_fifo <= 0; 
        end else begin  
               if(valid_bg_window_row) begin 
                    if(LX >> 3 == 0) begin    
                        bg_window_pixel_index <= bg_window_pixel_index + 1;                                   
                        if(bg_window_pixel_index >= SCX[2:0]) begin            
                            bg_window_fifo_write <= 1;
                            bg_pixel_x_to_fifo <= (bg_window_fifo_write) ? bg_pixel_x_to_fifo + 1 : 0;
                            bg_window_pixel_out <= pixel_row_bg_window[PIXELS_PER_TILE - 1 - bg_window_pixel_index];
                        end 
                     end else if (LX >> 3 > 0 && LX >> 3 < 20) begin
                        bg_window_fifo_write <= 1; 
                        bg_window_pixel_index <= bg_window_pixel_index + 1; 
                        bg_pixel_x_to_fifo <= bg_pixel_x_to_fifo + 1;  
                        bg_window_pixel_out <= pixel_row_bg_window[PIXELS_PER_TILE - 1 - bg_window_pixel_index];
                     end 
                end else if (LX >> 3 == 20 && bg_window_fifo_write) begin
                        bg_window_pixel_index <= bg_window_pixel_index + 1;
                        bg_pixel_x_to_fifo <= bg_pixel_x_to_fifo + 1;
                        if(bg_window_pixel_index < SCX[2:0]) begin
                            bg_window_fifo_write <= 1; 
                            bg_window_pixel_out <= pixel_row_bg_window[PIXELS_PER_TILE - 1 - bg_window_pixel_index];
                        end else begin 
                            bg_window_fifo_write <= 0;
                        end
                end else begin 
                        bg_window_fifo_write <= 0;                  
                end 
        end 
    end 
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Gets Queue of Sprites on Current Tile 
    logic [51:0] temp;
    
    
    always_comb begin
        for(int i = 0; i < MAX_SPRITE; i++) begin
           if (((tilemapX + 1) << 3) <= sprite_queue[i][23:16] && ((tilemapX + 2)  << 3) > sprite_queue[i][23:16])  begin
               
                sprites_on_curr_tile[i] = { (sprite_queue[i][23:16] & 8'h07), 1'b0, sprite_queue[i][47:0]};
           end else if ((tilemapX << 3) < sprite_queue[i][23:16] && ((tilemapX +1) << 3) >= sprite_queue[i][23:16]) begin
                
                sprites_on_curr_tile[i] = { (sprite_queue[i][23:16] & 8'h07), 1'b1, sprite_queue[i][47:0]};
           end else begin
                sprites_on_curr_tile[i] = 0;
           end  
        end     
//        for (int i = 0; i < MAX_SPRITE; i++) begin
//            for (int j = 0; j < MAX_SPRITE; j++) begin
//                if (sprites_on_curr_tile[i][23:16] > sprites_on_curr_tile[j][23:16]) begin
//                    temp = sprites_on_curr_tile[i];
//                    sprites_on_curr_tile[i] = sprites_on_curr_tile[j];
//                    sprites_on_curr_tile[j] = temp;
//                end 
//            end 
//        end 
        for (int i = 0; i < MAX_SPRITE; i++) begin
            for (int j = 0; j < MAX_SPRITE; j++) begin
                if (sprites_on_curr_tile[j] == 0 && sprites_on_curr_tile[j + 1] != 0) begin
                    temp = sprites_on_curr_tile[j];
                    sprites_on_curr_tile[j] = sprites_on_curr_tile[j + 1];
                    sprites_on_curr_tile[j + 1] = temp;
                end 
            end 
        end 
        
        sprite_on_curr_tile = (sprites_on_curr_tile[0] || sprites_on_curr_tile[1] || sprites_on_curr_tile[2] || sprites_on_curr_tile[3] || sprites_on_curr_tile[4] 
                            || sprites_on_curr_tile[5] || sprites_on_curr_tile[7] || sprites_on_curr_tile[8] || sprites_on_curr_tile[9]);
        
    end
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //SPRITE PIXEL ROW LOGIC 
    always_comb begin
       for(int i = 0; i < 8; i++) begin            
            if( pixel_rows_sprite[0][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[0][i];
            end else if( pixel_rows_sprite[1][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[1][i];
            end else if( pixel_rows_sprite[2][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[2][i];
            end else if( pixel_rows_sprite[3][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[3][i];
            end else if( pixel_rows_sprite[4][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[4][i];
            end else if( pixel_rows_sprite[5][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[5][i];
            end else if( pixel_rows_sprite[6][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[6][i];
            end else if( pixel_rows_sprite[7][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[7][i];
            end else if( pixel_rows_sprite[8][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[8][i];
            end else if( pixel_rows_sprite[9][i][5:4]) begin
                pixel_row_sprite[i] = pixel_rows_sprite[9][i];
            end else begin 
                pixel_row_sprite[i] = {6'b0};
            end 
      end
    end 


//UNUSED PORTS 
assign oam_wr = 0;
assign vram_wr = 0;
assign oam_din = 0;
assign vram_din = 0;
assign oam_a = 0;
//Debug Ports
logic [7:0] bg_tile_x;
assign bg_tile_x = LX >> 3;
logic [7:0] sprite_tile_y;
assign sprite_tile_y = (LY - (sprites_on_curr_tile[sprite_index][31:24] - 16));

endmodule
module sprite_queue_shift_down_pipeline (
        input wire clk, 
        input wire start, 
        input wire rst, 
        output logic done_out,
        input wire [9:0][51:0] queue_in,
        output logic [9:0][51:0] queue_out
    );
    typedef enum {stage_0, stage_1, stage_2, stage_3, stage_4, stage_5, stage_6, done} states;
    states state;
    
    always_ff @(posedge clk) begin
        if(start || rst) begin
            queue_out = '{default:'0};
            state <= stage_0;
        end else begin
            if (state == stage_0) begin
                
            end 
            
        end 
    end 
    
endmodule
module sprite_fetcher_vram_a(
    input wire [7:0] LCDC,
    input wire [7:0] LY,
    input wire [9:0][51:0]sprite_queue_in ,
    input wire [3:0] index, 
    output logic [15:0] vram_a_out
);
always_comb begin
    if(LCDC[2]) begin
            if(sprite_queue_in[index][6]) begin
                if( 0 <= (LY - (sprite_queue_in[index][31:24] - 16)) && (LY - (sprite_queue_in[index][31:24] - 16)) < 7) begin
                    vram_a_out = 16'h8000 + ((sprite_queue_in[index][15:8] + 1) << 4) + (( 7 - (LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);
                end else begin 
                    vram_a_out = 16'h8000 + ((sprite_queue_in[index][15:8]) << 4) + ((7 - (LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);
                end 
            end else begin
                if( 0 <= (LY - (sprite_queue_in[index][31:24] - 16)) && (LY - (sprite_queue_in[index][31:24] - 16)) < 7) begin
                    vram_a_out = 16'h8000 + ((sprite_queue_in[index][15:8]) << 4) + (((LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);
                end begin 
                    vram_a_out = 16'h8000 + ((sprite_queue_in[index][15:8] + 1) << 4) + (((LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);
                end 
            end 
        end else begin
            if(sprite_queue_in[index][6]) begin
                vram_a_out = 16'h8000 + (sprite_queue_in[index][15:8] << 4) + (( 7 - (LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);                
            end else begin
                vram_a_out = 16'h8000 + (sprite_queue_in[index][15:8] << 4) + (( (LY - (sprite_queue_in[index][31:24] - 16)) & 8'h07) << 1);
            end 
        end 
    end 
endmodule



`default_nettype wire
