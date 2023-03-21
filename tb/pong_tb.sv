// ----------------------------------------------
// Filename: pong_tb.sv
// Author: Jonathan L. Jacobson
// Date:   19 Mar 2023
//
// Description: This is a simple TB to
// exercise the Pong game.
//
// ----------------------------------------------

module pong_tb;

bit clk, rst, en;
bit isVisible;
int x, y;
bit hPulse, vPulse;
bit [7:0] red, green, blue;

initial begin
    clk = 0;
    reset();
    run();
end

always begin
    #5;
    clk = ~clk;
end

task reset();
  #5  rst = 1;
  #10 rst = 0;
endtask

task run();
  #5 en <= 1;
endtask

vga_driver VGA_INST (
    .clkIn(clk),
    .rstIn(rst),
    .enableIn(en),
    .RED(red),
    .GREEN(green),
    .BLUE(blue),
    .RED_RTN(1'b0),
    .GREEN_RTN(1'b0),
    .BLUE_RTN(1'b0),
    .ID(4'b0),
    .HSync(hPulse),
    .VSync(vPulse)
);

endmodule