module mmio_apu_m(
    input wire clk, 
    input wire rst,
    mem_if.slave req,
    input logic [31:0] sys_counter,
    output logic pwm_val
    );

    /* MMIO Regs */
    /* Channel 1: Square wave with Sweep & Envelope */
    logic [7:0] reg_nr10;               // 0xFF10
    logic [7:0] reg_nr11;               // 0xFF11
    logic [7:0] reg_nr12;               // 0xFF12
    logic [7:0] reg_nr13;               // 0xFF13
    logic [7:0] reg_nr14;               // 0xFF14
    /* Channel 2: Square wave with Envelope */
    logic [7:0] reg_nr21;               // 0xFF16
    logic [7:0] reg_nr22;               // 0xFF17
    logic [7:0] reg_nr23;               // 0xFF18
    logic [7:0] reg_nr24;               // 0xFF19
    /* Channel 3: Wave from RAM */
    logic [7:0] reg_nr30;               // 0xFF1A
    logic [7:0] reg_nr31;               // 0xFF1B
    logic [7:0] reg_nr32;               // 0xFF1C
    logic [7:0] reg_nr33;               // 0xFF1D
    logic [7:0] reg_nr34;               // 0xFF1E
    logic [7 * 16:0] reg_wave;          // 0xFF30 - 0xFF3F
    /* Channel 4: White Noise with Envelope */
    logic [7:0] reg_nr41;               // 0xFF20
    logic [7:0] reg_nr42;               // 0xFF21
    logic [7:0] reg_nr43;               // 0xFF22
    logic [7:0] reg_nr44;               // 0xFF23
    /* Sound Control Regs */
    logic [7:0] reg_nr50;               // 0xFF24
    logic [7:0] reg_nr51;               // 0xFF25
    logic [7:0] reg_nr52;               // 0xFF26


    /* Ouput for each register */
    always_comb begin
        case (req.addr_select) 
            16'hFF16: req.read_out = reg_nr21 | 8'b00111111;    
            16'hFF17: req.read_out = reg_nr22;
            16'hFF18: req.read_out = reg_nr23 | 8'b11111111;
            16'hFF19: req.read_out = reg_nr24 | 8'b10111111;

            16'hFF24: req.read_out = reg_nr50;
            16'hFF25: req.read_out = reg_nr51;
            16'hFF26: req.read_out = reg_nr52 | 8'b01110000;
            default:  req.read_out = 8'haa;
        endcase
    end

    logic[3:0] ch1_out;
    logic[3:0] ch2_out;
    logic[3:0] ch3_out;
    logic[3:0] ch4_out;

    assign ch1_out = 0;
    assign ch3_out = 0;
    assign ch4_out = 0;

    logic[5:0] out_L_num;
    logic[5:0] out_R_num; 
    logic[5:0] out_L_den;
    logic[5:0] out_R_den; 

    /* DAC Sound Logic */
    always_comb begin
        logic[5:0] tmp_R;
        logic[5:0] tmp_L;
        tmp_R = 0;
        tmp_L = 0;
        if (reg_nr52[7]) begin
            if (reg_nr51[0]) tmp_R += ch1_out;
            if (reg_nr51[1]) tmp_R += ch2_out;
            if (reg_nr51[2]) tmp_R += ch3_out;
            if (reg_nr51[3]) tmp_R += ch4_out;
            if (reg_nr51[4]) tmp_L += ch1_out;
            if (reg_nr51[5]) tmp_L += ch2_out;
            if (reg_nr51[6]) tmp_L += ch3_out;
            if (reg_nr51[7]) tmp_L += ch4_out;
            out_L_num = tmp_L;
            out_R_num = tmp_R;
            out_L_den = reg_nr51[4] + reg_nr51[5] + reg_nr51[6] + reg_nr51[7];
            out_R_den = reg_nr51[0] + reg_nr51[1] + reg_nr51[2] + reg_nr51[3];
        end else begin
            out_L_num = 0;
            out_R_num = 0;
            out_L_den = 0;
            out_R_den = 0;
        end
    end

    /* Mixer */
    logic[7:0] mono_out;
    assign mono_out = (out_L_num * (reg_nr50[2:0]+1) * 2) / out_L_den; // max vol = (15 * 4 * 8 * 2) / 4= 240. min vol = 2
    pwm_m pwm (.clk_in(clk), .rst_in(rst), .level_in(mono_out), .pwm_out(pwm_val));

    /* Channel 2 - Logic */
    logic [7:0] waveforms [4:0]; 
    logic [2:0] wave_duty_position;
    logic [13:0] freq_timer; 
    logic [11:0] frequency_reload;
    logic [3:0] current_volume;
    assign frequency_reload = {reg_nr24[2:0], reg_nr23};
    assign current_volume = reg_nr22[7:4];
    always_ff @(posedge clk) begin
        if (rst) begin
            // Waveform Duty Cycle Table
            waveforms[0] <= 8'b0000_0001;   // 12.5%
            waveforms[1] <= 8'b0000_0011;   // 25%
            waveforms[2] <= 8'b0000_1111;   // 50%
            waveforms[3] <= 8'b1111_1100;   // 75%
            freq_timer <= 0;
            ch2_out <= 0;
            wave_duty_position <= 0;
        end
        else begin 
            if (freq_timer == 0) begin
                freq_timer <= (2048 - frequency_reload) * 4;
                wave_duty_position <= wave_duty_position + 1; 
            end
            else begin
                freq_timer <= freq_timer - 1; 
            end
            ch2_out <= waveforms[reg_nr21[7:6]][wave_duty_position] * current_volume;
        end
    end

    /* 0xFF16 - NR21 - Channel 2 Sound Length / Wave Pattern Duty (R/W*) */
    /* 0xFF17 - NR22 - Channel 2 Volume Envelope (R/W) */
    /* 0xFF23 - NR23 - Channel 2 Frequency Lo Data (W) */
    /* 0xFF24 - NR24 - Channel 2 Frequency Hi Data & Control (W) */
    logic[1:0] nr21_we_hi; 
    logic[1:0] nr22_we_hi; 
    logic[1:0] nr23_we_hi; 
    logic[1:0] nr24_we_hi; 
    logic[1:0] nr50_we_hi;
    logic[1:0] nr51_we_hi;
    logic[1:0] nr52_we_hi;
    always_ff @(posedge clk) begin
        if (rst) begin
            nr21_we_hi <= 0;
            nr22_we_hi <= 0;
            nr23_we_hi <= 0;
            nr24_we_hi <= 0;
            nr50_we_hi <= 0;
            nr51_we_hi <= 0;
            nr52_we_hi <= 0;

            reg_nr24 <= 8'hff;
            reg_nr23 <= 8'hff;
        end
        else begin 
            // WE has been hi for 1 cycle. Reset counter on next rising edge
            if (nr21_we_hi == 1) reg_nr21 <= req.write_value; 
            if (nr22_we_hi == 1) reg_nr22 <= req.write_value; 
            if (nr23_we_hi == 1) reg_nr23 <= req.write_value; 
            if (nr24_we_hi == 1) reg_nr24 <= req.write_value; 
            if (nr50_we_hi == 1) reg_nr50 <= req.write_value; 
            if (nr51_we_hi == 1) reg_nr51 <= req.write_value; 
            if (nr52_we_hi == 1) reg_nr52 <= req.write_value; 

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF16) nr21_we_hi <= nr21_we_hi + 1;  
            else nr21_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF17) nr22_we_hi <= nr22_we_hi + 1;  
            else nr22_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF18) nr23_we_hi <= nr23_we_hi + 1;  
            else nr23_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF19) nr24_we_hi <= nr24_we_hi + 1;  
            else nr24_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF24) nr50_we_hi <= nr50_we_hi + 1;  
            else nr50_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF25) nr51_we_hi <= nr51_we_hi + 1;  
            else nr51_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF26) nr52_we_hi <= nr52_we_hi + 1;  
            else nr52_we_hi <= 0; 
        end
    end


endmodule

//PWM generator for audio generation!
module pwm_m (input wire clk_in, input wire rst_in, input wire [7:0] level_in, output logic pwm_out);
    logic [7:0] count;
    assign pwm_out = count<level_in;
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            count <= 8'b0;
        end else begin
            count <= count+8'b1;
        end
    end
endmodule
  