`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2021 05:51:56 PM
// Design Name: 
// Module Name: ppu
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
module ppu(
    input wire clk_in, 
    input wire rst_in, 
    input wire start_in,
    //LCD Logic
    output logic hsync, 
    output logic vsync,
    output logic [7:0] h_count, 
    output logic [7:0] v_count, 
    output logic [1:0] pixel_out,
    //SCREEN BUFFER
    output logic [14:0] lcd_addr,
    output logic lcd_write,
    //VRAM DATA BUS, 0x8000 - 0x9FFF 
    input  wire  [7:0]  vram_dout,
    output logic [15:0] vram_a,
    output logic [7:0]  vram_din,
    output logic        vram_rd,
    output logic        vram_wr, 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    output logic [7:0]  oam_din,
    output logic        oam_rd,
    output logic        oam_wr,
    //CPU R/W REGISTERS 
    output logic [7:0]  mmio_dout,
    input wire   [15:0] mmio_a,
    input wire   [7:0]  mmio_din,
    input wire          mmio_rd,
    input wire          mmio_wr,
    //STAT INTERUPT LINE
    output logic stat_interrupt,
    output logic vblank_interrupt,
    //DEBUG    
    output logic [4:0] state_out
    );
    logic [7:0] LCDC, STAT, SCX, SCY, WX, WY, LY, LYC;

    //OAM SEARCH FSM / MODE 2 FSM LOGIC:
    logic mode_2_start, mode_2_done;
    logic [7:0] mode_2_time;
    logic [15:0] mode_2_sprite_queue [9:0];
    
    //MODE 3 FSM /Pixel Fetcher FSM LOGIC:
    logic mode_3_start, mode_3_done;
    logic [8:0] mode_3_time;
    logic [7:0] x_process;
    
    oam_search_fsm mode_2(
        .clk_in(clk_in), .rst_in(mode_2_start), .start_in(mode_2_start),
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout),
        .oam_a(oam_a),
        .oam_din(oam_din),
        .oam_rd(oam_rd),
        .oam_wr(oam_wr), 
        //Registers
        .LCDC(LCDC),
        .LY(LY),
        //Output Sprites 2 bytes 10 elements 
        .obj_queue_out(mode_2_sprite_queue),
        .done_out(mode_2_done),
        .count(mode_2_time)
        ); 
        
    mode_3_fsm mode_3(
        .clk_in(clk_in), .rst_in(mode_3_start), .start_in(mode_3_start),
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .vram_dout(vram_dout),
        .vram_a(vram_a),
        .vram_din(vram_din),
        .vram_rd(vram_rd),
        .vram_wr(vram_wr), 
        //Registers
        .LCDC(LCDC),
        .LY(LY), 
        .SCX(SCX), 
        .SCY(SCY),  
        .WX(WX), 
        .WY(WY),
        .LX(x_process),
        .LX_R(h_count),
        //OUTPUTS
        .pixel_out(pixel_out), 
        .done_out(mode_3_done),
        .lcd_write(lcd_write),
        .lcd_addr(lcd_addr),
        .MODE_3_TIME(mode_3_time)
        
        );  
       
    parameter SCANLINE_CLOCK = 456;
    parameter MAX_SCANLINE = 144;
    
    typedef enum {idle = 3'b100, MODE_2 =3'b010, MODE_3 = 3'b011, MODE_0 = 3'b000, MODE_1=3'b001} states;
    states state;
    

    
    logic [8:0] mode_2_3_time;
    logic [8:0] hsync_count; 
    assign state_out = state;
    assign v_count = LY;
    
    /*INTERUPT LOGIC*/
    logic v_blank_int, h_blank_int, oam_search_int;
    assign LCDC[2] = LY == LYC;
     
    always_ff @(posedge clk_in) begin 
        if(rst_in || start_in) begin   
            STAT <= 0;    
            LY <= 0;
            hsync <= 0;
            vsync <= 0;
            mode_2_3_time <= 0;
            mode_2_start <= 0;
            hsync_count <= 0;
            state <= idle;
        end else begin
            if (state == idle) begin 
                if(LCDC[7]) begin
                    mode_2_start <= 1;
                    state <= MODE_2;
                end 
            end else if (state == MODE_2) begin
                mode_2_start <= 0;
                if(mode_2_done) begin                       
                    mode_2_3_time <= mode_2_3_time + mode_2_time;
                    mode_3_start <= 1;
                    state <= MODE_3;
                end 
            end else if (state == MODE_3) begin
                mode_3_start <= 0;
                if(mode_3_done) begin
                    mode_2_3_time <= mode_2_3_time + mode_3_time;
                    hsync <= 1;
                    state <= MODE_0;
                end 
            end else if (state == MODE_0) begin
                if (hsync_count > SCANLINE_CLOCK - mode_2_3_time - 1 ) begin
                    hsync <= 0; 
                    hsync_count <= 0;
                    mode_2_3_time <= 0;
                    if(LY + 1 > MAX_SCANLINE - 1) begin 
                        vsync <= 1;
                        hsync_count <= 0;
                        state <= MODE_1;
                    end else begin 
                        LY <= LY + 1;
                        mode_2_start <= 1;
                        mode_2_3_time <= 0;
                        state <= MODE_2;
                    end 
                end else begin
                    hsync <= 1;
                    hsync_count  <= hsync_count + 1;
                end     
            end else if (state == MODE_1) begin
                if(LY + 1 > MAX_SCANLINE + 10 - 1) begin 
                    vsync <= 0;
                    state <= idle;
                end else begin
                    vsync <= 1;
                    if(hsync_count >= SCANLINE_CLOCK - 1 ) begin
                        hsync_count <= 0;
                        LY <= LY + 1;
                    end else begin 
                        hsync_count <= hsync_count + 1;
                    end
                end 
            end 
              
        end 
    end 
    //MMIO
    always_comb begin 
        if(mmio_rd && !mmio_wr) begin 
             case(mmio_a) 
                16'hFF40: mmio_dout = LCDC;
                16'hFF41: mmio_dout = STAT;
                16'hFF42: mmio_dout = SCY;
                16'hFF43: mmio_dout = SCX;
                16'hFF44: mmio_dout = LY;
                16'hFF45: mmio_dout = LYC;
                16'hFF4A: mmio_dout = WX;
                16'hFF4B: mmio_dout = WY;
            endcase
        end 
    end 
    always_ff @(posedge clk_in) begin 
        if (rst_in) begin 
                LCDC <= 8'b1101_0001;
                SCX <= 0;
                SCY <= 0;
                WX <= 0;
                WY <= 0;
                LYC <= 0;
        end else begin 
            if(mmio_wr && !mmio_rd) begin 
                case(mmio_a) 
                    16'hFF40: LCDC <= mmio_din;
                    16'hFF41: STAT <= mmio_din;
                    16'hFF42: SCY <= mmio_din;
                    16'hFF43: SCX <= mmio_din;
                    16'hFF45: LYC <= mmio_din;
                    16'hFF4A: WX <= mmio_din;
                    16'hFF4B: WY <= mmio_din;
                endcase
            end 
        end         
     end 
     logic [31:0] count_time;
     always_ff @(posedge clk_in) begin
        if (start_in || rst_in) begin 
            count_time <= 0;
            
        end else begin
            if(state != idle) begin
                if (count_time >= 70224) begin
                    count_time <= 0;
                end else begin 
                    count_time <= count_time + 1;
                end 
            end 
        end  
     end 


    /* Interrupt Logic */

    // interrupt triggers (active high)
    logic interrupt_lyc, interrupt_mode2, interrupt_mode1, interrupt_mode0; 

    // OR interrupt triggers if they are enabled to create Statline
    assign stat_interrupt = (interrupt_lyc   & LCDC[6]) | 
                            (interrupt_mode2 & LCDC[5]) | 
                            (interrupt_mode1 & LCDC[4]) | 
                            (interrupt_mode0 & LCDC[3]);
    assign vblank_interrupt = interrupt_mode1;
    // Ask Ahmad?
    states last_state; 
    always @(posedge clk_in) begin last_state <= state; end
    assign interrupt_mode0 = last_state != MODE_0 && state == MODE_0;  
    assign interrupt_mode1 = last_state != MODE_1 && state == MODE_1;
    assign interrupt_mode2 = last_state != MODE_2 && state == MODE_2;
    assign interrupt_lyc = LY == LYC? 1 : 0;

endmodule
`default_nettype wire