`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2021 12:47:32 AM
// Design Name: 
// Module Name: cpu_tb1
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


module cpu_tb1(

    );
    logic clk, rst;
    logic out; 
    top_level uut(clk, {rst, 15'b0}); 

    always #5 clk = !clk;


    initial begin
        //$readmemh("p1.mem", uut.wram);

        clk = 0; 
        rst = 1;     
        #15
        rst = 0;
    end
endmodule
