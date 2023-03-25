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

bit clk100, clk25;
bit rst, en;
bit hPulse, vPulse;
bit [3:0] red, green, blue;
bit led;

initial begin
  clk100 = 0;
  clk25  = 0;
  run();
  reset();
end

always begin
  #5ns clk100 = ~clk100;
end

always begin
  #20ns clk25 = ~clk25;
end

task reset();
  #5ns   rst = 1;
  #200ns rst = 0;
endtask

task run();
  #80ns en <= 1;
endtask

pong_top pong_inst(
  .CLK100MHZ(clk100),
  .reset(rst),
  .enable(en),
  .VGA_R(red),
  .VGA_G(green),
  .VGA_B(blue),
  .VGA_HS(hPulse),
  .VGA_VS(vPulse),
  .LED(led)
);

endmodule