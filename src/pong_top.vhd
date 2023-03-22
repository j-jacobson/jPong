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
    clk           : in    std_logic;
    vgaClk        : in    std_logic;
    rst           : in    std_logic;
    enable        : in    std_logic;

    RED           :   out std_logic_vector(7 downto 0);
    GREEN         :   out std_logic_vector(7 downto 0);
    BLUE          :   out std_logic_vector(7 downto 0);

    HSync         :   out std_logic;
    VSync         :   out std_logic
  );
end;

architecture RTL of pong_top is

begin

  vga_inst : entity work.vga_driver(RTL)
  generic map (
    HSync_Front   => 16,
    HSync_Visible => 640,
    HSync_Back    => 48,
    HSync_SyncP   => 96,

    VSync_Front   => 10,
    VSync_Visible => 480,
    VSync_Back    => 33,
    VSync_SyncP   => 2
  )
  port map (
    clkIn         => vgaClk,
    rstIn         => rst,
    enableIn      => enable,

    RED           => RED,
    GREEN         => GREEN,
    BLUE          => BLUE,

    RED_RTN       => '0',
    GREEN_RTN     => '0',
    BLUE_RTN      => '0',

    ID            => (others => '0'),
    HSync         => HSync,
    VSync         => VSync
  );

end architecture RTL;