`timescale 1ns / 1ps
`default_nettype none

module ppu_top_level(
   input wire clk_100mhz,
   input wire [4:0] sw,
   output logic[3:0] vga_r,
   output logic[3:0] vga_b,
   output logic[3:0] vga_g,
   output logic vga_hs,
   output logic vga_vs,
   //output logic led16_r,
   //output logic led16_g,
   //output logic led16_b,
   output logic [15:0] led
   );
    
    logic vclock;
    clk_wiz_0 clkdivider(.reset(1'b0),.clk_in1(clk_100mhz), .clk_out1(vclock));
    
    logic [9:0] hcount;
    logic [9:0] vcount;     
    logic hsync;
    logic vsync;
    logic blank;
    
    vga vg_ape(.rst(sw[3]),.vclock_in(vclock),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    logic [7:0] x;
    logic [7:0] y;
    
    logic [11:0] hcount_10;
    assign hcount_10 = hcount * 3;
    
    logic [11:0] vcount_10;
    assign vcount_10 = vcount * 3;
    
    assign x = (hcount_10 - 160) / 10;
    assign y = (vcount_10) / 10;
    
    logic [14:0] addr;
    
    assign addr = (160 * y) + x;
    
    logic addr_valid;
    assign addr_valid = (hcount < 587) && (hcount > 54) && (vcount > 0) && (vcount < 480);
    
    logic [1:0] pixel_data;
    logic [1:0] pixel_black;
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // PPU AHMAD START
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //INPUTS 
    logic rst_in, start_in, clk_4mhz;
    assign clk_4mhz = vclock;
    //clk_gen _clk_gen(.clk_in(clk_100mhz),.clk_out(clk_4mhz));
    //clk_wiz_1 clk_ppu(.clk_in1(vclock), .clk_out1(clk_4mhz));
    //clk_divider clk_ppu_4(.clk_in(clk_8mhz), .rst_in(sw[3]), .clk_out(clk_4mhz));
    //OUTPUTS
    logic [1:0] pixel_out;
    logic [14:0] lcd_addr;
    logic lcd_write;
    //VRAM DATA BUS, 0x8000 - 0x9FFF 
    logic [7:0]  vram_dout;
    logic [15:0] vram_a;
    logic [7:0]  vram_din;
    logic        vram_rd;
    logic        vram_wr; 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    logic [7:0]  oam_dout;
    logic [15:0] oam_a;
    logic [7:0]  oam_din;
    logic        oam_rd;
    logic        oam_wr; 
    //CPU R/W REGISTERS 
    logic [7:0]  mmio_dout;
    logic [15:0] mmio_a;
    logic [7:0]  mmio_din;
    logic        mmio_rd;
    logic        mmio_wr;
    //DEBUG
    logic [4:0] state_ppu;
    ppu uut(
        .clk_in(clk_4mhz), .rst_in(rst_in), .start_in(start_in),
        //LCD Logic
        .pixel_out(pixel_out),
        //SCREEN BUFFER
        .lcd_addr(lcd_addr),
        .lcd_write(lcd_write),
        //VRAM DATA BUS, 0x8000 - 0x9FFF 
        .vram_dout(vram_dout), .vram_a(vram_a), .vram_din(vram_din), .vram_rd(vram_rd), .vram_wr(vram_wr), 
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout), .oam_a(oam_a), .oam_din(oam_din), .oam_rd(oam_rd), .oam_wr(oam_wr), 
        //CPU R/W REGISTERS 
        .mmio_dout(mmio_dout), .mmio_a(mmio_a), .mmio_din(mmio_din), .mmio_rd(mmio_rd), .mmio_wr(mmio_wr),
        //DEBUG
        .state_out(state_ppu)
        );
    
    bram_vram unit_vram(
        .addra(vram_a[12:0]),
        .clka(clk_4mhz), 
        .dina(vram_din),
        .wea(vram_wr),
        .douta(vram_dout)
        );
      
    bram_oam unit_oam(
        .addra(oam_a[7:0]),
        .clka(clk_4mhz), 
        .dina(oam_din),
        .wea(oam_wr),
        .douta(oam_dout)
        );
        
    logic [14:0] addra;
    always_ff @(posedge clk_4mhz) begin
        if(sw[3]) begin
            rst_in <= 1;
            //addra <= 0; 
        end else begin
            rst_in <= 0;
            //addra <= addra + 1;
        end 
    end 
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // PPU AHMAD END
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    logic [14:0] addrb;
    assign addrb = addr_valid ? addr : 15'd0; 
    
    
    assign led = state_ppu;
    
    ram_lcd lcd(            .addra(lcd_addr),
                            .clka(clk_4mhz),
                            .dina(pixel_out),
                            .wea(lcd_write),
                            .addrb(addrb),
                            .clkb(vclock),
                            .doutb(pixel_black)
                            );
                          
                    
    assign pixel_data = addr_valid ? pixel_black : 2'b11;

    logic b,hs,vs;
    logic [11:0] rgb;
    
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;
    
    //assign {led16_r,led16_g,led16_b} = sw[2:0];
    
    assign red   = sw[2] ? { ~pixel_data, ~pixel_data } : 4'd0;
    assign green = sw[1] ? { ~pixel_data, ~pixel_data } : 4'd0;
    assign blue  = sw[0] ? { ~pixel_data, ~pixel_data } : 4'd0;
    
    always_ff @(posedge vclock) begin
        hs <= hsync;
        vs <= vsync;
        b <= blank;
        rgb <= {red, green, blue};
    end

    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

endmodule

module vga(input wire vclock_in,
           input wire rst,
            output logic [9:0] hcount_out,    // pixel number on current line
            output logic [9:0] vcount_out,     // line number
            output logic vsync_out, hsync_out,
            output logic blank_out);

   parameter DISPLAY_WIDTH  = 640;      // display width
   parameter DISPLAY_HEIGHT = 480;       // number of lines

   parameter  H_FP = 16;                 // horizontal front porch
   parameter  H_SYNC_PULSE = 96;        // horizontal sync
   parameter  H_BP = 48;                // horizontal back porch

   parameter  V_FP = 10;                  // vertical front porch
   parameter  V_SYNC_PULSE = 2;          // vertical sync 
   parameter  V_BP = 33;                 // vertical back porch

   logic hblank,vblank;
   logic hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1)); 
   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1)); 
   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1)); 

   logic vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1)); 
   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1)); 
   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));
   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); 

   // sync and blanking
   logic next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always_ff @(posedge vclock_in) begin
       if (rst) begin
            hcount_out <= 0;
            hblank <= 0;
            hsync_out <= 0;
            
            vcount_out <= 0;
            vblank <= 0;
            vsync_out <= 0;
            
            blank_out <= 1;
       end else begin
          hcount_out <= hreset ? 0 : hcount_out + 1;
          hblank <= next_hblank;
          hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low
    
          vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
          vblank <= next_vblank;
          vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low
    
          blank_out <= next_vblank | (next_hblank & ~hreset);
       end
   end
endmodule


`default_nettype wire