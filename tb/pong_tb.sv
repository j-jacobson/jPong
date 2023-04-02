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
bit rst_n, en;
bit hPulse, vPulse;
bit [3:0] red, green, blue;
bit led;
bit U, D, C, L, R;
bit [0:2] SW;
bit PWM, SD;

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
  #5ns   rst_n = 0;
  #200ns rst_n = 1;
endtask

task run();
  #80ns en <= 1;
  #400ns C <= 1;
endtask

pong_top pong_inst(
  .CLK100MHZ(clk100),
  .reset_n(rst_n),
  .enable(en),
  .BTNC(C),
  .BTNU(U),
  .BTND(D),
  .BTNL(L),
  .BTNR(R),
  .SW(SW),
  .VGA_R(red),
  .VGA_G(green),
  .VGA_B(blue),
  .VGA_HS(hPulse),
  .VGA_VS(vPulse),
  .AUD_PWM(PWM),
  .AUD_SD(SD),
  .LED(led)
);

endmodule