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
    input wire clk, 
    input wire rst, 
    input wire start,
    //LCD Logic
    output logic hsync, 
    output logic vsync,
    output logic [7:0] h_count, 
    output logic [7:0] v_count, 
    output logic [1:0] pixel_out,
    //SCREEN BUFFER
    output logic [15:0] lcd_a,
    output logic lcd_wr,
    //VRAM DATA BUS, 0x8000 - 0x9FFF 
    input  wire  [7:0]  vram_dout,
    output logic [15:0] vram_a,
    output logic [7:0]  vram_din,
    output logic        vram_wr, 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    input  wire  [7:0]  oam_dout,
    output logic [15:0] oam_a,
    output logic [7:0]  oam_din,
    output logic        oam_wr,
    //CPU R/W REGISTERS 
    output logic [7:0]  mmio_dout,
    input wire   [15:0] mmio_a,
    input wire   [7:0]  mmio_din,
    input wire          mmio_wr,
    //STAT INTERUPT LINE
    output logic stat_interrupt,
    output logic vblank_interrupt
    );
    logic [7:0] LCDC, STAT, SCX, SCY, WX, WY, LY, LYC, DMA, BGP, OBP0, OBP1;
    //OAM SEARCH FSM / MODE 2 FSM LOGIC:
    logic mode_2_start, mode_2_done;
    logic [11:0] mode_2_cycles;
    logic [9:0][47:0] mode_2_sprite_queue ;
    
    //MODE 3 FSM /Pixel Fetcher FSM LOGIC:
    logic mode_3_start, mode_3_done;
    logic [11:0] mode_3_cycles;
    
    logic [15:0] mode_2_oam_a;
    logic [7:0] mode_2_oam_dout, mode_2_oam_din;
    logic mode_2_oam_wr;
    
    mode_2_fsm mode_2(
        .clk(clk), .rst(mode_2_start), .start(mode_2_start),.done_out(mode_2_done),
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout), .oam_a(mode_2_oam_a), .oam_din(mode_2_oam_din), .oam_wr(mode_2_oam_wr), 
        //Registers
        .LCDC(LCDC), .LY(LY),
        //Output Sprites 2 bytes 10 elements 
        .sprite_queue_out(mode_2_sprite_queue), .mode_2_cycles(mode_2_cycles)
    ); 
    
   
   logic [15:0] mode_3_oam_a, mode_3_vram_a;
   logic [7:0] mode_3_oam_din, mode_3_vram_din;
   logic mode_3_oam_wr, mode_3_vram_wr;  
   mode_3_fsm mode_3(
        .clk(clk), .rst(mode_3_start), .start(mode_3_start),.done_out(mode_3_done),
          //VRAM DATA BUS, 0x8000 - 0x9FFF  
        .vram_dout(vram_dout), .vram_a(mode_3_vram_a), .vram_din(mode_3_vram_din), .vram_wr(mode_3_vram_wr), 
         //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout), .oam_a(mode_3_oam_a), .oam_din(mode_3_oam_din), .oam_wr(mode_3_oam_wr),
        //Registers
        .LCDC(LCDC), .LY(LY),  .SCX(SCX),  .SCY(SCY),  .WX(WX), .WY(WY), .BGP(BGP), .OBP0(OBP0),.OBP1(OBP1),
        //Sprite_queue
        .sprite_queue(mode_2_sprite_queue),
        //OUTPUTS
        .pixel_out(pixel_out),.lcd_wr(lcd_wr),.lcd_a(lcd_a),
        //Debug
        .mode_3_cycles(mode_3_cycles),.h_count(h_count)
    ); 
       
    parameter SCANLINE_CLOCK = 456;
    parameter MAX_SCANLINE = 144;
    
    typedef enum {MODE_2, MODE_3, MODE_0, MODE_1} states;
    states state;
        
    logic [8:0] mode_2_3_time;
    logic [8:0] hsync_count; 
    assign v_count = LY;
    
    logic v_interrupt;
    always_ff @(posedge clk) begin 
        if(rst || start) begin   
            LY <= 0;
            hsync <= 0;
            vsync <= 0;
            hsync_count <= 0;
            mode_2_3_time <= 0;
            mode_2_start <= 1;
            v_interrupt <= 0;
            state <= MODE_2;
        end else begin
            if(LCDC[7]) begin 
                 if (state == MODE_2) begin
                    mode_2_start <= 0;
                    if(mode_2_done) begin                       
                        mode_2_3_time <= mode_2_3_time + mode_2_cycles + 2;
                        mode_3_start <= 1;
                        state <= MODE_3;
                    end 
                end else if (state == MODE_3) begin
                    mode_3_start <= 0;
                    if(mode_3_done) begin
                        mode_2_3_time <= mode_2_3_time + mode_3_cycles + 3;
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
                            v_interrupt <= 1;
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
                        LY <= 0;
                        hsync <= 0;
                        vsync <= 0;
                        hsync_count <= 0;
                        mode_2_3_time <= 0;

                        mode_2_start <= 1;
                        state <= MODE_2;
                    end else begin
                        vsync <= 1;
                        v_interrupt <= 0;
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
    end 
    //MMIO
    always_comb begin 
        if(!mmio_wr) begin 
             case(mmio_a) 
                16'hFF40: mmio_dout = LCDC;
                16'hFF41: mmio_dout = LCDC[7] ? STAT : { STAT[7:2] , 2'b0};
                16'hFF42: mmio_dout = SCY;
                16'hFF43: mmio_dout = SCX;
                16'hFF44: mmio_dout = LY;
                16'hFF45: mmio_dout = LYC;
                16'hFF46: mmio_dout = DMA;
                16'hFF47: mmio_dout = BGP;
                16'hFF48: mmio_dout = OBP0;
                16'hFF49: mmio_dout = OBP1;
                16'hFF4A: mmio_dout = WX;
                16'hFF4B: mmio_dout = WY;
            endcase
        end else begin
            mmio_dout = 0;
        end 
    end 
    always_ff @(posedge clk) begin 
        if (rst) begin                   
                LCDC <= 8'hD3;                    
                STAT[6:3] <= 0;
                SCY <= 8'h00;
                SCX <= 0;
                LYC <= 0;
                DMA <= 0;
                BGP <= 8'hE4;
                OBP0 <= 8'hE4;
                OBP1 <= 8'hC4;
                WX <= 8'h00;
                WY <= 8'h00;
        end else begin 
            if(mmio_wr) begin 
                case(mmio_a) 
                    16'hFF40: LCDC <= mmio_din;
                    16'hFF41: STAT[6:3] <= mmio_din[6:3];
                    16'hFF42: SCY <= mmio_din;
                    16'hFF43: SCX <= mmio_din;
                    16'hFF44: LY <= LY; //Cant wr to this addr
                    16'hFF45: LYC <= mmio_din;
                    16'hFF47: BGP <= mmio_din;
                    16'hFF48: OBP0 <= mmio_din;
                    16'hFF49: OBP1 <= mmio_din;
                    16'hFF4A: WX <= mmio_din;
                    16'hFF4B: WY <= mmio_din;
                    
                endcase
            end 
        end         
     end 
     //ppu timings
     logic [31:0] count_time;
     always_ff @(posedge clk) begin
        if (start || rst) begin 
            count_time <= 0;        
        end else begin           
            if (count_time >= 70224) begin
                count_time <= 0;
            end else begin 
                count_time <= count_time + 1;
            end 
             
        end  
     end 
       /* Interrupt Logic */

    // interrupt triggers (active high)
    logic interrupt_lyc, interrupt_mode2, interrupt_mode1, interrupt_mode0; 

    // OR interrupt triggers if they are enabled to create Statline
    assign stat_interrupt = (interrupt_lyc   & STAT[6]) | 
                            (interrupt_mode2 & STAT[5]) | 
                            (interrupt_mode1 & STAT[4]) | 
                            (interrupt_mode0 & STAT[3]);
    assign vblank_interrupt = interrupt_mode1;
    // Ask Ahmad?
    states last_state; 
    always @(posedge clk) begin last_state <= state; end
    assign interrupt_mode0 = last_state != MODE_0 && state == MODE_0;  
    assign interrupt_mode1 = last_state != MODE_1 && state == MODE_1;
    assign interrupt_mode2 = last_state != MODE_2 && state == MODE_2;
    assign interrupt_lyc = LY == LYC? 1 : 0;
    assign STAT[2] = (LY == LYC);
    assign STAT[7] = 1;
    always_comb begin
        case(state)
            MODE_0 : begin
                        STAT[1:0] = 2'b00; 
                        oam_a = 16'hFFFF;
                        vram_a = 16'hFFFF;
                     end
            MODE_1 : begin 
                        oam_a = 16'hFFFF;
                        vram_a = 16'hFFFF;
                        STAT[1:0] = 2'b01;
                     end 
            MODE_2 : begin 
                        oam_a = mode_2_oam_a;
                        vram_a = 16'hFFFF;
                        STAT[1:0] = 2'b10;
                     end
            MODE_3 : begin 
                        oam_a = mode_3_oam_a;
                        vram_a = mode_3_vram_a;
                        STAT[1:0] = 2'b11;
                     end
        endcase 
    end 
    
endmodule
`default_nettype wire