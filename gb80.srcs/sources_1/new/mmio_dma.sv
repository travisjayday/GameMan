module mmio_dma_m(
    input wire clk, 
    input wire rst,
    mem_if.slave req,
    mem_if.master dma_req
    );

    /* 0xFF46 - DMA (R/W) */
    logic [7:0] dma_addr_hi;    // mapped to 0xFF46
    logic [7:0] dma_addr_lo;    // internal to DMA engine
    logic [2:0] dma_we_hi; 
    logic [4:0] dma_request; 
    always_ff @(posedge clk) begin
        if (rst) begin
            dma_addr_hi <= 0; 
            dma_we_hi <= 0;
            dma_request <= 0; 
            dma_addr_lo <= 0; 
            dma_req.addr_select <= 16'hFFFF;
            dma_req.write_enable <= 0; 
            dma_req.write_value <= 0; 
        end
        else begin 
            // WE has been hi for 1 cycle.
            if (dma_we_hi == 1) begin
                dma_addr_hi <= req.write_value;
                dma_request <= 6; 
            end

            // Keep track of how long WE has been hi for
            if (req.write_enable && req.addr_select == 16'hFF46) 
                dma_we_hi <= dma_we_hi + 1;  
            else                  
                dma_we_hi <= 0; 
        end
    end

    always_ff @(posedge clk) begin
        // Delay for two machine cycles
        if (dma_request > 0) begin
            dma_request <= dma_request - 1; 
            if (dma_request == 1) dma_req.addr_select <= {dma_addr_hi, dma_addr_lo};
        end
        // DMA in progress
        if (dma_req.addr_select != 16'hFFFF) begin
            if (dma_addr_lo < 8'h0A) begin
                // After 160 bytes, dma is done
                if (dma_addr_lo == 8'h0A - 1) dma_req.addr_select <= 16'hFFFF; 

                // Dma is ongoing. Copy data.
            
            end 
        end
    end
endmodule
