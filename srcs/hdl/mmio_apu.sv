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

    logic [7:0] wave_ram [15:0];

    /* Ouput for each register */
    always_comb begin
        if (req.addr_select >= 16'hFF30 && req.addr_select <= 16'hFF3F) begin
            req.read_out = wave_ram[req.addr_select - 16'hFF30];
        end else begin
            case (req.addr_select) 
                /* Sound Channel 1 Regs */
                16'hFF10: req.read_out = reg_nr10;    
                16'hFF11: req.read_out = reg_nr11 | 8'b00111111;    
                16'hFF12: req.read_out = reg_nr12;
                16'hFF13: req.read_out = reg_nr13 | 8'b11111111;
                16'hFF14: req.read_out = reg_nr14 | 8'b10111111;
                /* Sound Channel 2 Regs */
                16'hFF16: req.read_out = reg_nr21 | 8'b00111111;    
                16'hFF17: req.read_out = reg_nr22;
                16'hFF18: req.read_out = reg_nr23 | 8'b11111111;
                16'hFF19: req.read_out = reg_nr24 | 8'b10111111;
                /* Sound Channel 3 Regs */
                16'hFF1A: req.read_out = reg_nr30;
                16'hFF1B: req.read_out = reg_nr31 | 8'b11111111;
                16'hFF1C: req.read_out = reg_nr32;
                16'hFF1D: req.read_out = reg_nr33 | 8'b11111111;
                16'hFF1E: req.read_out = reg_nr34 | 8'b10111111;
                /* Control Regs */
                16'hFF24: req.read_out = reg_nr50;
                16'hFF25: req.read_out = reg_nr51;
                16'hFF26: req.read_out = reg_nr52 | 8'b01110000;
                default:  req.read_out = 8'haa;
            endcase
        end
    end

    logic[3:0] ch1_out;
    logic[3:0] ch2_out;
    logic[3:0] ch3_out;
    logic[3:0] ch4_out;

    assign ch4_out = 0;

    logic[6:0] out_L_num;
    logic[6:0] out_R_num; 
    logic[6:0] out_L_den;
    logic[6:0] out_R_den; 

    
    /* Frame Sequencer Clock Driver */
    // Falling edge of bit 5 of DIV (upper 8 bits of sysclock) steps the FS clock
    // Freq: 512Hz
    logic previous_fs_bit;
    logic[2:0] fs_clock;
    always_ff @(posedge clk) begin
        if (rst) begin
            previous_fs_bit <= 0;
            fs_clock <= 0; 
        end else begin
            previous_fs_bit <= sys_counter[7+5];
            if (previous_fs_bit && !sys_counter[7+5]) begin
                fs_clock <= fs_clock + 1;
            end
        end
    end

    /* DAC Sound Logic */
    always_comb begin
        logic[6:0] tmp_R;
        logic[6:0] tmp_L;
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


    /* Sound Channel 1 stuff */
    logic[1:0] nr10_we_hi; 
    logic[1:0] nr11_we_hi; 
    logic[1:0] nr12_we_hi; 
    logic[1:0] nr13_we_hi; 
    logic[1:0] nr14_we_hi; 
    logic nr14_triggered;
    /* 0xFF16 - NR21 - Channel 2 Sound Length / Wave Pattern Duty (R/W*) */
    /* 0xFF17 - NR22 - Channel 2 Volume Envelope (R/W) */
    /* 0xFF23 - NR23 - Channel 2 Frequency Lo Data (W) */
    /* 0xFF24 - NR24 - Channel 2 Frequency Hi Data & Control (W) */
    logic[1:0] nr21_we_hi; 
    logic[1:0] nr22_we_hi; 
    logic[1:0] nr23_we_hi; 
    logic[1:0] nr24_we_hi; 
    logic nr24_triggered;
    /* Sound Channel 3 */
    logic[1:0] nr30_we_hi; 
    logic[1:0] nr31_we_hi; 
    logic[1:0] nr32_we_hi; 
    logic[1:0] nr33_we_hi; 
    logic[1:0] nr34_we_hi; 
    logic nr34_triggered;
    /* APU Control */
    logic[1:0] nr50_we_hi;
    logic[1:0] nr51_we_hi;
    logic[1:0] nr52_we_hi;
    always_ff @(posedge clk) begin
        if (rst) begin
            /* Channel 1 Regs Init */
            nr10_we_hi <= 0;
            nr11_we_hi <= 0;
            nr12_we_hi <= 0;
            nr13_we_hi <= 0;
            nr14_we_hi <= 0;
            reg_nr14 <= 8'hff;
            reg_nr13 <= 8'hff;
            reg_nr12 <= 8'hff;
            nr14_triggered <= 0; 

            /* Channel 2 Regs Init */
            nr21_we_hi <= 0;
            nr22_we_hi <= 0;
            nr23_we_hi <= 0;
            nr24_we_hi <= 0;
            reg_nr24 <= 8'hff;
            reg_nr23 <= 8'hff;
            reg_nr22 <= 8'hff;
            nr24_triggered <= 0; 

            /* Channel 3 Regs Init */
            nr30_we_hi <= 0;
            nr31_we_hi <= 0;
            nr32_we_hi <= 0;
            nr33_we_hi <= 0;
            nr34_we_hi <= 0;
            reg_nr34 <= 8'hff;
            reg_nr33 <= 8'hff;
            reg_nr32 <= 8'hff;
            nr34_triggered <= 0; 
            for (int i = 0; i < 15; i = i + 1) wave_ram[i] <= 0;

            /* Control Regs Init */
            nr50_we_hi <= 0;
            nr51_we_hi <= 0;
            nr52_we_hi <= 0;


        end
        else begin 
            // WE has been hi for 1 cycle. Reset counter on next rising edge

            /* Channel 1 Regs */
            if (nr10_we_hi == 1) reg_nr10 <= req.write_value; 
            if (nr11_we_hi == 1) reg_nr11 <= req.write_value; 
            if (nr12_we_hi == 1) reg_nr12 <= req.write_value; 
            if (nr13_we_hi == 1) reg_nr13 <= req.write_value; 
            if (nr14_we_hi == 1) begin 
                reg_nr14 <= req.write_value; 
                nr14_triggered <= req.write_value[7]; 
            end else begin nr14_triggered <= 0; end 

            /* Channel 2 Regs */
            if (nr21_we_hi == 1) reg_nr21 <= req.write_value; 
            if (nr22_we_hi == 1) reg_nr22 <= req.write_value; 
            if (nr23_we_hi == 1) reg_nr23 <= req.write_value; 
            if (nr24_we_hi == 1) begin 
                reg_nr24 <= req.write_value; 
                nr24_triggered <= req.write_value[7]; 
            end else begin nr24_triggered <= 0; end 

            /* Channel 3 Regs */
            if (nr30_we_hi == 1) reg_nr30 <= req.write_value; 
            if (nr31_we_hi == 1) reg_nr31 <= req.write_value; 
            if (nr32_we_hi == 1) reg_nr32 <= req.write_value; 
            if (nr33_we_hi == 1) reg_nr33 <= req.write_value; 
            if (nr34_we_hi == 1) begin 
                reg_nr34 <= req.write_value; 
                nr34_triggered <= req.write_value[7]; 
            end else begin nr34_triggered <= 0; end 

            /* Control Regs */
            if (nr50_we_hi == 1) reg_nr50 <= req.write_value; 
            if (nr51_we_hi == 1) reg_nr51 <= req.write_value; 
            if (nr52_we_hi == 1) reg_nr52 <= req.write_value; 

            // Keep track of how long WE has been hi for

            /* Channel 1 Regs */
            if (req.write_enable && req.addr_select == 16'hFF10) nr10_we_hi <= nr10_we_hi + 1;  
            else nr10_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF11) nr11_we_hi <= nr11_we_hi + 1;  
            else nr11_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF12) nr12_we_hi <= nr12_we_hi + 1;  
            else nr12_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF13) nr13_we_hi <= nr13_we_hi + 1;  
            else nr13_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF14) nr14_we_hi <= nr14_we_hi + 1;  
            else nr14_we_hi <= 0; 
            
            /* Channel 2 Regs */
            if (req.write_enable && req.addr_select == 16'hFF16) nr21_we_hi <= nr21_we_hi + 1;  
            else nr21_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF17) nr22_we_hi <= nr22_we_hi + 1;  
            else nr22_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF18) nr23_we_hi <= nr23_we_hi + 1;  
            else nr23_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF19) nr24_we_hi <= nr24_we_hi + 1;  
            else nr24_we_hi <= 0; 

            /* Channel 3 Regs */
            if (req.write_enable && req.addr_select == 16'hFF1A) nr30_we_hi <= nr30_we_hi + 1;  
            else nr30_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF1B) nr31_we_hi <= nr31_we_hi + 1;  
            else nr31_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF1C) nr32_we_hi <= nr32_we_hi + 1;  
            else nr32_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF1D) nr33_we_hi <= nr33_we_hi + 1;  
            else nr33_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF1E) nr34_we_hi <= nr34_we_hi + 1;  
            else nr34_we_hi <= 0; 
            if (req.write_enable && (req.addr_select >= 16'hFF30 && req.addr_select <= 16'hFF3F)) begin
                wave_ram[req.addr_select - 16'hFF30] <= req.write_value;
            end
            
            /* Control Regs */
            if (req.write_enable && req.addr_select == 16'hFF24) nr50_we_hi <= nr50_we_hi + 1;  
            else nr50_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF25) nr51_we_hi <= nr51_we_hi + 1;  
            else nr51_we_hi <= 0; 
            if (req.write_enable && req.addr_select == 16'hFF26) nr52_we_hi <= nr52_we_hi + 1;  
            else nr52_we_hi <= 0; 
        end
    end

    /* Channel 1 - Logic */
    logic [7:0] waveforms_1 [4:0]; 
    logic [2:0] wave_duty_pos_1;
    logic [13:0] freq_timer_1; 
    logic [11:0] freq_reload_1;
    logic [11:0] new_freq;
    logic [11:0] shadow_freq;
    logic sweep_enabled;
    logic [9:0] sweep_timer;
    logic [3:0] current_vol_1;
    assign freq_reload_1 = {reg_nr14[2:0], reg_nr13};
    logic last_trigger_val_1;
    logic [2:0] last_fsclock_1;
    logic [2:0] envelope_period_1; 
    logic ch1_disabled;
    always_ff @(posedge clk) begin
        logic [11:0] tmp_freq;
        logic tmp_freq_ov;
        if (rst) begin
            // Waveform Duty Cycle Table
            waveforms_1[0] <= 8'b0000_0001;   // 12.5%
            waveforms_1[1] <= 8'b0000_0011;   // 25%
            waveforms_1[2] <= 8'b0000_1111;   // 50%
            waveforms_1[3] <= 8'b1111_1100;   // 75%
            freq_timer_1 <= 0;
            ch1_out <= 0;
            wave_duty_pos_1 <= 0;
            current_vol_1 <= 0; 
            envelope_period_1 <= 0; 
            last_trigger_val_1 <= 0;
            ch1_disabled <= 0;
        end
        else begin 
            // If Trigger Event occurs, start Enveloping audio (Change volume over time)
            if (nr14_triggered) begin
                envelope_period_1 <= reg_nr12[2:0];
                current_vol_1 <= reg_nr12[7:4];
                sweep_timer <= reg_nr10[6:4] == 0? 8 : reg_nr10[6:4];
                shadow_freq <= freq_reload_1;
                sweep_enabled <= (reg_nr10[6:4] != 0) || (reg_nr10[2:0] != 0);
                ch1_disabled <= 0;
            end
            else begin
                last_fsclock_1 <= fs_clock;
                if ((last_fsclock_1 == 1 && fs_clock == 2) || (last_fsclock_1 == 5 && fs_clock == 6)) begin
                    // frame sequencer clocked
                    sweep_timer <= sweep_timer - 1;
                    if (sweep_timer == 0) begin
                        sweep_timer <= reg_nr10[6:4] == 0? 8 : reg_nr10[6:4];
                        if (sweep_enabled && reg_nr10[6:4] > 0) begin
                            if (reg_nr10[3]) begin
                                // sub
                                tmp_freq = shadow_freq - (shadow_freq >> reg_nr10[2:0]);
                            end else begin
                                // add
                                tmp_freq = shadow_freq + (shadow_freq >> reg_nr10[2:0]);
                            end

                            if (tmp_freq < 2048) begin
                                // no overflow
                                new_freq <= tmp_freq;
                                shadow_freq <= tmp_freq;
                            end else begin
                                // overflow
                                ch1_disabled <= 1;
                            end
                        end
                    end
                end

                if (fs_clock == 7 && last_fsclock_1 == 6) begin
                    if (reg_nr12[2:0] != 0) begin
                        envelope_period_1 <= envelope_period_1 - 1; 
                        if (envelope_period_1 == 0) begin
                            envelope_period_1 <= reg_nr12[2:0];
                            if (current_vol_1 < 4'hF && reg_nr12[3]) begin
                                current_vol_1 <= current_vol_1 + 1;
                            end else if (current_vol_1 > 4'h0 && !reg_nr12[3]) begin
                                current_vol_1 <= current_vol_1 - 1; 
                            end
                        end
                    end
                end
                
            end     

            // Output correct wave with correct frequency
            if (freq_timer_1 == 0) begin
                freq_timer_1 <= (2048 - freq_reload_1) * 4;
                wave_duty_pos_1 <= wave_duty_pos_1 + 1; 
            end
            else begin
                freq_timer_1 <= freq_timer_1 - 1; 
            end
            ch1_out <= ch1_disabled? 0 :  waveforms_1[reg_nr11[7:6]][wave_duty_pos_1] * current_vol_1;
        end
    end


    /* Channel 2 - Logic */
    logic [7:0] waveforms_2 [4:0]; 
    logic [2:0] wave_duty_pos_2;
    logic [13:0] freq_timer_2; 
    logic [11:0] freq_reload_2;
    logic [3:0] current_vol_2;
    assign freq_reload_2 = {reg_nr24[2:0], reg_nr23};
    logic last_trigger_val_2;
    logic [2:0] last_fsclock_2;
    logic [2:0] envelope_period_2; 
    always_ff @(posedge clk) begin
        if (rst) begin
            // Waveform Duty Cycle Table
            waveforms_2[0] <= 8'b0000_0001;   // 12.5%
            waveforms_2[1] <= 8'b0000_0011;   // 25%
            waveforms_2[2] <= 8'b0000_1111;   // 50%
            waveforms_2[3] <= 8'b1111_1100;   // 75%
            freq_timer_2 <= 0;
            ch2_out <= 0;
            wave_duty_pos_2 <= 0;
            current_vol_2 <= 0; 
            envelope_period_2 <= 0; 
            last_trigger_val_2 <= 0;
        end
        else begin 
            // If Trigger Event occurs, start Enveloping audio (Change volume over time)
            if (nr24_triggered) begin
                envelope_period_2 <= reg_nr22[2:0];
                current_vol_2 <= reg_nr22[7:4];
            end
            else begin
                last_fsclock_2 <= fs_clock;
                if (fs_clock == 7 && last_fsclock_2 == 6) begin
                    if (reg_nr22[2:0] != 0) begin
                        envelope_period_2 <= envelope_period_2 - 1; 
                        if (envelope_period_2 == 0) begin
                            envelope_period_2 <= reg_nr22[2:0];
                            if (current_vol_2 < 4'hF && reg_nr22[3]) begin
                                current_vol_2 <= current_vol_2 + 1;
                            end else if (current_vol_2 > 4'h0 && !reg_nr22[3]) begin
                                current_vol_2 <= current_vol_2 - 1; 
                            end
                        end
                    end
                end
            end     

            // Output correct wave with correct frequency
            if (freq_timer_2 == 0) begin
                freq_timer_2 <= (2048 - freq_reload_2) * 4;
                wave_duty_pos_2 <= wave_duty_pos_2 + 1; 
            end
            else begin
                freq_timer_2 <= freq_timer_2 - 1; 
            end
            ch2_out <= waveforms_2[reg_nr21[7:6]][wave_duty_pos_2] * current_vol_2;
        end
    end


    /* Channel 3 - Logic */
    logic [3:0] wave_pos_3;
    logic [18:0] freq_timer_3; 
    logic [11:0] freq_reload_3;
    logic [1:0] vol_shift;
    assign freq_reload_3 = {reg_nr34[2:0], reg_nr33};
    logic last_trigger_val_3;
    logic wave_ram_parity;
    always_ff @(posedge clk) begin
        if (rst) begin
            // Waveform Duty Cycle Table
            freq_timer_3 <= 0;
            ch3_out <= 0;
            wave_pos_3 <= 0;
            vol_shift <= 0; 
            last_trigger_val_3 <= 0;
            wave_ram_parity <= 0;
        end
        else begin 
            // If Trigger Event occurs, start Enveloping audio (Change volume over time)
            if (nr34_triggered) begin
                vol_shift <= reg_nr32[6:5];
                wave_pos_3 <= 0; 
                wave_ram_parity <= 0;
            end
            else begin
                // Output correct wave with correct frequency
                if (freq_timer_3 == 0) begin
                    freq_timer_3 <= (2048 - freq_reload_3) * 2;
                    if (wave_ram_parity) begin
                        wave_pos_3 <= wave_pos_3 + 1; 
                        wave_ram_parity <= 0;
                    end
                    else begin
                        wave_ram_parity <= 1; 
                    end
                end
                else begin
                    freq_timer_3 <= freq_timer_3 - 1; 
                end

                if (reg_nr30[7]) begin
                    if (wave_ram_parity == 0) 
                        ch3_out <= reg_nr32[6:5] == 0? 0 : wave_ram[wave_pos_3][7:4] >> (reg_nr32[6:5] - 1);
                    else 
                        ch3_out <= reg_nr32[6:5] == 0? 0 : wave_ram[wave_pos_3][3:0] >> (reg_nr32[6:5] - 1);
                end
                else begin
                    ch3_out <= 0;
                end
            end
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
  