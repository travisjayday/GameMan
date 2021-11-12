//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2021 01:10:20 PM
// Design Name: 
// Module Name: fifo
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


module fifo( 
    input wire clk_in, rst_in, enable_in,  enqueue_in, dequeue_in,
    input wire [7:0] data_in, 
    output logic [7:0] data_out, 
    output logic full_out, empty_out
    );
    parameter MAX_QUEUE_SIZE = 16; //in bits so this is 2^4 elements 
    
    reg  [7:0] data_queue [MAX_QUEUE_SIZE-1:0]; //data queue of 8 bit elemeemts 16 elements deep
    reg  [4:0] fifo_count, fifo_count_rd, fifo_count_wr;
    
    assign full_out = (fifo_count == MAX_QUEUE_SIZE);
    assign empty_out = (fifo_count == 0); 
    always_ff @(posedge clk_in) begin 
        if (rst_in) begin 
            fifo_count <= 0;
            fifo_count_rd <= 0;
            fifo_count_wr <= 0;
            for(int i = 0; i < MAX_QUEUE_SIZE - 1 ; i++) begin 
                data_queue[i] <= 0;
            end 
        end  
        if(enable_in) begin 
            if(dequeue_in && fifo_count != 0) begin 
                data_out <= data_queue[fifo_count_rd];
                fifo_count_rd <= fifo_count_rd + 1;
            end else if (enqueue_in && fifo_count < MAX_QUEUE_SIZE) begin
                data_queue[fifo_count_wr] <= data_in;
                fifo_count_wr <= fifo_count_wr + 1;
            end 
            //Edge Case Logic 
            if (fifo_count_wr == MAX_QUEUE_SIZE) begin 
                fifo_count_wr <= 0;
            end else if (fifo_count_rd == MAX_QUEUE_SIZE) begin 
                fifo_count_rd <= 0;
            end 
            //Fifo_count Logic
            if(fifo_count_rd > fifo_count_wr) begin 
                fifo_count <= fifo_count_rd - fifo_count_wr;
            end else if (fifo_count_wr > fifo_count_rd) begin 
                fifo_count <= fifo_count_wr - fifo_count_rd ;
            end 
            
            
        end 
    end  
endmodule
