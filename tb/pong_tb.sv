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

bit clk, vga_clk, rst, en;
bit hPulse, vPulse;
bit [7:0] red, green, blue;

initial begin
  clk = 0;
  vga_clk = 0;
  reset();
  run();
end

always begin
  #5ns clk = ~clk;
end

always begin
  #19.8609ns vga_clk = ~vga_clk;
end

task reset();
  #5ns  rst = 1;
  #50ns rst = 0;
endtask

task run();
  #80ns en <= 1;
endtask

pong_top pong_inst(
  .clk(clk),
  .vgaClk(vga_clk),
  .rst(rst),
  .enable(en),
  .RED(red),
  .GREEN(green),
  .BLUE(blue),
  .HSync(hPulse),
  .VSync(vPulse)
);

endmodule