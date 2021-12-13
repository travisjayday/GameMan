`timescale 1ns / 1ps
`default_nettype none

module ppu_top_level(
   input wire clk_100mhz,
   input wire btnu,
   input wire btnc,
   input wire btnl,
   input wire btnr,
   input wire btnd,

   output logic[3:0] vga_r,
   output logic[3:0] vga_b,
   output logic[3:0] vga_g,
   output logic vga_hs,
   output logic vga_vs,
   output logic [15:0] led
   );
    parameter DEBOUNCE_COUNT = 100000;
    logic vclock;
    logic ppu_start, clk_4mhz, _100_mhz_out, clk_50mhz;
    
    clk_wiz_0 vclock_gen(.clk_in1(clk_100mhz), .clk_out1(vclock));
    
    clk_wiz_1 main_clock_gen(.clk_in1(vclock), .clk_out1(clk_4mhz));
    
    

    logic [9:0] hcount;
    logic [9:0] vcount;     
    logic hsync;
    logic vsync;
    logic blank;

    vga vg_ape(.vclock_in(vclock),.hcount_out(hcount),.vcount_out(vcount),

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


   
    //clk_gen _clk_gen(.clk_in(clk_100mhz),.clk_out(clk_4mhz));
    //OUTPUTS
    logic ppu_hsync, ppu_vsync;
    logic [7:0] ppu_vcount, ppu_hcount;
    logic [1:0] pixel_out;
    logic [15:0] lcd_addr;
    logic lcd_write;
    //VRAM DATA BUS, 0x8000 - 0x9FFF 
    logic [7:0]  vram_dout;
    logic [15:0] vram_a;
    logic [7:0]  vram_din;
    logic        vram_wr; 
    //OAM Data Bus, 0xFE00 - 0xFE9F 
    logic [7:0]  oam_dout;
    logic [15:0] oam_a;
    logic [7:0]  oam_din;
    logic        oam_wr; 
    //CPU R/W REGISTERS 
    logic [7:0]  mmio_dout;
    logic [15:0] mmio_a;
    logic [7:0]  mmio_din;
    logic        mmio_wr;
    

    logic frame_advance;
    debounce #(.DEBOUNCE_COUNT(DEBOUNCE_COUNT)) db0 (.reset_in(btnu), .clock_in(clk_4mhz), .noisy_in(btnc),.clean_out(frame_advance));
    

    logic scroll_left, scroll_right;
    debounce #(.DEBOUNCE_COUNT(DEBOUNCE_COUNT)) db1 (.reset_in(btnc), .clock_in(clk_4mhz), .noisy_in(btnl),.clean_out(scroll_left));
    debounce #(.DEBOUNCE_COUNT(DEBOUNCE_COUNT)) db2 (.reset_in(btnc), .clock_in(clk_4mhz), .noisy_in(btnr),.clean_out(scroll_right));
    
    
    logic scroll_up, scroll_down;
    debounce #(.DEBOUNCE_COUNT(DEBOUNCE_COUNT)) db3 (.reset_in(btnc), .clock_in(clk_4mhz), .noisy_in(btnu),.clean_out(scroll_up));
    debounce #(.DEBOUNCE_COUNT(DEBOUNCE_COUNT)) db4 (.reset_in(btnc), .clock_in(clk_4mhz), .noisy_in(btnd),.clean_out(scroll_down));
    
    
    ppu uut(
        .clk(clk_4mhz), .rst(btnc), .start(btnc),
        //LCD Logic
        .hsync(ppu_hsync), .vsync(ppu_vsync),
        .h_count(ppu_hcount), .v_count(ppu_vcount), 
        .pixel_out(pixel_out),
        //SCREEN BUFFER
        .lcd_a(lcd_addr), .lcd_wr(lcd_write),
        //VRAM DATA BUS, 0x8000 - 0x9FFF 
        .vram_dout(vram_dout), .vram_a(vram_a), .vram_din(vram_din),
        //OAM Data Bus, 0xFE00 - 0xFE9F 
        .oam_dout(oam_dout), .oam_a(oam_a), .oam_din(oam_din), 
        //CPU R/W REGISTERS 
        .mmio_dout(mmio_dout), .mmio_a(mmio_a), .mmio_din(mmio_din), .mmio_wr(mmio_wr)
    );
    
    bram_vram unit_vram(
        .addra(vram_a[12:0]),
        .clka(clk_4mhz), 
        .dina(vram_din),
        .wea(0),
        .douta(vram_dout)
        );
      
    bram_oam unit_oam(
        .addra(oam_a[7:0]),
        .clka(clk_4mhz), 
        .dina(oam_din),
        .wea(0),
        .douta(oam_dout)
        );
     logic [7:0] scrollY, scrollX;
     logic [31:0] btn_count;
     always_ff @(posedge clk_4mhz) begin
        
        if(btnc) begin

            scrollY <= 0;
            scrollX <= 0;
        end else if (scroll_up ) begin
            if (btn_count >= 4_194_304/8) begin 
                mmio_wr <= 1;
                mmio_din <= scrollY;
                mmio_a <= 16'hFF42;
                scrollY <= scrollY + 1;
                btn_count <= 0;
             end else begin 
                btn_count <= btn_count + 1;
             end 
        end else if (scroll_down ) begin
            if (btn_count >= 4_194_304/8) begin 
                mmio_wr <= 1;
                mmio_din <= scrollY;
                mmio_a <= 16'hFF42;
                scrollY <= scrollY - 1;
                btn_count <= 0;
             end else begin 
                btn_count <= btn_count + 1;
             end 
        end else if (scroll_right ) begin
            if (btn_count >= 4_194_304/8) begin 
                mmio_wr <= 1;
                mmio_din <= scrollX;
                mmio_a <= 16'hFF43;
                scrollX <= scrollX + 1;
                btn_count <= 0;
             end else begin 
                btn_count <= btn_count + 1;
             end 
        end else if (scroll_left) begin
            if (btn_count >= 4_194_304/8) begin 
                mmio_wr <= 1;
                mmio_din <= scrollX;
                mmio_a <= 16'hFF43;
                scrollX <= scrollX - 1;
                btn_count <= 0;
             end else begin 
                btn_count <= btn_count + 1;
             end 
        end else begin
            mmio_wr <= 0;
        end 
     end 
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // PPU AHMAD END
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    logic [14:0] addrb;
    assign addrb = addr_valid ? addr : 15'd0; 
    
    
    ram_lcd lcd(            .addra(lcd_addr[14:0]),
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
    
    assign red   = 1 ? { ~pixel_data, ~pixel_data } : 4'd0;
    assign green = 1 ? { ~pixel_data, ~pixel_data } : 4'd0;
    assign blue  = 1 ? { ~pixel_data, ~pixel_data } : 4'd0;
    
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

//module vga(input wire vclock_in,
//           input wire rst,
//            output logic [9:0] hcount_out,    // pixel number on current line
//            output logic [9:0] vcount_out,     // line number
//            output logic vsync_out, hsync_out,
//            output logic blank_out);

//   parameter DISPLAY_WIDTH  = 640;      // display width
//   parameter DISPLAY_HEIGHT = 480;       // number of lines

//   parameter  H_FP = 16;                 // horizontal front porch
//   parameter  H_SYNC_PULSE = 96;        // horizontal sync
//   parameter  H_BP = 48;                // horizontal back porch

//   parameter  V_FP = 10;                  // vertical front porch
//   parameter  V_SYNC_PULSE = 2;          // vertical sync 
//   parameter  V_BP = 33;                 // vertical back porch

//   logic hblank,vblank;
//   logic hsyncon,hsyncoff,hreset,hblankon;
//   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
//   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1)); 
//   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1)); 
//   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1)); 

//   logic vsyncon,vsyncoff,vreset,vblankon;
//   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1)); 
//   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1)); 
//   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));
//   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); 

//   // sync and blanking
//   logic next_hblank,next_vblank;
//   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
//   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
//   always_ff @(posedge vclock_in) begin
//       if (rst) begin
//            hcount_out <= 0;
//            hblank <= 0;
//            hsync_out <= 0;
            
//            vcount_out <= 0;
//            vblank <= 0;
//            vsync_out <= 0;
            
//            blank_out <= 1;
//       end else begin
//          hcount_out <= hreset ? 0 : hcount_out + 1;
//          hblank <= next_hblank;
//          hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low
    
//          vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
//          vblank <= next_vblank;
//          vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low
    
//          blank_out <= next_vblank | (next_hblank & ~hreset);
//       end
//   end
//endmodule

module debounce (input wire reset_in, clock_in, noisy_in,
                 output logic clean_out);
   parameter DEBOUNCE_COUNT = 1000000;
   logic [19:0] count;
   logic new_input;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == DEBOUNCE_COUNT) clean_out <= new_input;
     else count <= count+1;


endmodule

`default_nettype wire


