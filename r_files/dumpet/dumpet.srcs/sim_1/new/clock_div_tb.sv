
module clock_div_tb;
    
    logic clk_100mhz;
    logic clk_100khz;
    logic reset;


    always #5 clk_100mhz = !clk_100mhz;

    clk_divider #(.DIVIDER(500)) cart_clock (.clk_in(clk_100mhz),.rst_in(reset),.clk_out(clk_100khz));

initial begin
      // Initialize Inputs
      clk_100mhz = 0;
      //clk_100khz = 0;
      reset = 0;
      #5;
      reset = 1;
      #5;
      reset = 0;



    end
endmodule
