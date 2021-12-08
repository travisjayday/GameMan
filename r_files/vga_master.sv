`timescale 1ns / 1ps
`default_nettype none

module vga_master(
   input wire clk_100mhz,
   input wire rst,
   output logic[3:0] vga_r,
   output logic[3:0] vga_b,
   output logic[3:0] vga_g,
   output logic vga_hs,
   output logic vga_vs,
   
   output logic [14:0] addrb,
   output logic clkb,
   input wire [1:0] doutb
    );
    parameter RED   = 4'b0111;
    parameter GREEN = 4'b1111;
    parameter BLUE  = 4'b0001;
    
    logic vclock;
    clk_wiz_0 _100mhz_to_65mhz(.reset(rst),.clk_in1(clk_100mhz), .clk_out1(vclock));
    
    logic [9:0] hcount;
    logic [9:0] vcount;     
    logic hsync;
    logic vsync;
    logic blank;
    
    vga vg_ape(.rst(rst),.vclock_in(vclock),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    logic [7:0] x;
    logic [7:0] y;
    
    logic [11:0] hcount_10;
    assign hcount_10 = hcount * 3;
    
    logic [11:0] vcount_10;
    assign vcount_10 = vcount * 3;
    
    assign x = (hcount_10 - 160) / 10;
    assign y = (vcount_10 - 0) / 10;
    
    logic [14:0] addr;
    
    assign addr = (160 * y) + x;
    
    logic addr_valid;
    assign addr_valid = (hcount < 587) && (hcount > 52)  && (vcount < 480);
    
    assign addrb = addr_valid? addr:'d0;
    
    logic [1:0] pixel_data;
    logic [1:0] pixel_black;
   
    logic pixel_valid;
    assign pixel_valid = (hcount < 587) && (hcount > 53)  && (vcount < 480);
                            
    assign pixel_data = pixel_valid ? pixel_black : 2'b11;

    
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;
    
    logic strength;
    assign strength = ~pixel_data;
    
    logic [5:0] red_out, green_out, blue_out;
    
    assign red_out   = RED   * strength;
    assign green_out = GREEN * strength;
    assign blue_out  = BLUE  * strength;
        
    assign red   = red_out[5:2];
    assign green = green_out[5:2];
    assign blue  = blue_out[5:2];
    
    logic b,hs,vs;
    logic [11:0] rgb;
    
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