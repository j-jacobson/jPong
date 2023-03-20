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
    en  = 0;
    rst = 1;
    #10us;
    rst = 0;
    en = 1;
end

always begin
    #5us;
    clk = ~clk;
end

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