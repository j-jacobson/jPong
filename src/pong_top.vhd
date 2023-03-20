-------------------------------------------------
-- filename : pong_top.vhd
-- date     : 19 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the top level of the implementation
-- of Pong on the Nexys A7 development board.
--
-- Components: VGA Driver
--             Game Logic
--             Controller Driver
--             Sound Driver
-------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity pong_top is
  port (
    clk           : in   std_logic;
    rst           : in   std_logic
  );
end;

architecture RTL of pong_top is
  -- add signals here
  signal temp_signal      : bit;

begin

  vga_inst : entity vga_driver
    port map (
        clkIn => clk,
        rstIn => rst
    );

  sound_inst : entity sound_driver
    port map (
        clkIn => clk,
        rstIn => rst
    );

  game_inst : entity pong_logic
    port map (
        clkIn => clk,
        rstIn => rst
    );

  controller_inst : entity controller_inst
    port map (
        clkIn => clk,
        rstIn => rst
    );
end architecture RTL;