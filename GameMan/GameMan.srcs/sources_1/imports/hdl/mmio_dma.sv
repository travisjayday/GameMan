module mmio_dma_m(
    input wire clk, 
    input wire rst,
    mem_if.slave req,
    mem_if.master dma_req
    );

    /* 0xFF46 - DMA (R/W) */
    logic [7:0] dma_src_addr_hi;    // mapped to 0xFF46
    logic [7:0] dma_src_addr_lo;    // internal to DMA engine
    logic [2:0] dma_we_hi; 
    logic [4:0] dma_request; 
    always_ff @(posedge clk) begin
        if (rst) begin
            dma_src_addr_hi <= 0; 
            dma_we_hi <= 0;
            dma_request <= 0; 
            dma_src_addr_lo <= 0; 
            dma_req.addr_select <= 16'hFFFF;
            dma_req.write_enable <= 0; 
            dma_req.write_value <= 0; 
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (dma_we_hi == 1) begin
                dma_src_addr_hi <= req.write_value;
                dma_src_addr_lo <= 0;
                dma_request <= 6; 
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF46) 
                dma_we_hi <= dma_we_hi + 1;  
            else                  
                dma_we_hi <= 0; 
        end
    end

    typedef enum {
        DMA_READ_1,
        DMA_READ_2, 
        DMA_WRITE_1, 
        DMA_WRITE_2
    } dma_state_t; 

    dma_state_t dma_state;
    logic [15:0] dma_dst_addr; 

    always_ff @(posedge clk) begin
        // Delay for two machine cycles
        if (dma_request > 0) begin
            dma_request <= dma_request - 1; 
            if (dma_request == 2) begin 
                dma_req.write_enable <= 0;
                dma_req.addr_select <= {dma_src_addr_hi, dma_src_addr_lo};
                dma_src_addr_lo <= 1; 
                dma_dst_addr <= 16'hFE00;
                dma_state <= DMA_READ_1;
            end
        end
        // DMA in progress
        if (dma_req.addr_select != 16'hFFFF) begin
            // Dma is ongoing. Copy data.
            case (dma_state) 
                DMA_READ_1: begin
                    // Reading... (first full read cycle)
                    dma_state <= DMA_READ_2;
                end
                DMA_READ_2: begin
                    // Reading... (second full read cycle)
                    // At the end of this cycle, data byte will come in 
                    dma_state <= DMA_WRITE_1;
                end
                DMA_WRITE_1: begin
                    // Write incoming byte to OAM...
                    dma_req.addr_select <= dma_dst_addr;
                    dma_dst_addr <= dma_dst_addr + 1; 
                    dma_req.write_enable <= 1; 
                    dma_req.write_value <= dma_req.read_out;
                    dma_state <= DMA_WRITE_2;
                end
                DMA_WRITE_2: begin
                    // Writing right now...
                    // (1 full cycle seems to be enough)
                    dma_state <= DMA_READ_1;

                    // On next clock edge, set address for next read
                    // (Don't waste cycle)
                    if (dma_dst_addr == 16'hFEA0) begin 
                        // After 160 bytes, dma is done
                        dma_req.addr_select <= 16'hFFFF; 
                    end else begin
                        // Else read next byte
                        dma_src_addr_lo <= dma_src_addr_lo + 1; 
                        dma_req.addr_select <= {dma_src_addr_hi, dma_src_addr_lo};
                        dma_req.write_enable <= 0; 
                    end
                end
            endcase 
        end
    end
endmodule
