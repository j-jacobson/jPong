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

vga_counter VGA_INST(
    .clkIn(clk),
    .rstIn(rst),
    .inVisibleArea(isVisible),
    .xValue(x),
    .yValue(y),
    .HSync(hPulse),
    .VSync(vPulse),
    .enableIn(en)
);

endmodule