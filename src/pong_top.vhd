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
--             
--             
--             
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;
library jacobson_ip;

entity pong_top is
  generic (
    VGA_DEPTH     : integer := 12;
    NUM_LEDS      : integer := 1
  );
  port (
    CLK100MHZ     : in    std_logic;
    reset         : in    std_logic;
    enable        : in    std_logic;

    VGA_R         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    VGA_G         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    VGA_B         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);

    VGA_HS        :   out std_logic;
    VGA_VS        :   out std_logic;

    LED           :   out std_logic_vector((NUM_LEDS-1) downto 0)
  );
end;

architecture RTL of pong_top is

signal clk25MHz     : std_logic;

begin

  vga_clk_inst : entity jacobson_ip.clk_divider(RTL)
  generic map (
    COUNT         => 2 -- 100MHz -> 25MHz
  )
  port map (
    clkIn         => CLK100MHZ,
    rstIn         => reset,
    clkOut        => clk25MHz
  );

  vga_inst : entity pong_lib.vga_driver(RTL)
  generic map (
    VGA_DEPTH     => VGA_DEPTH,
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
    clkIn         => clk25MHz,
    rstIn         => reset,
    enableIn      => enable,

    RED           => VGA_R,
    GREEN         => VGA_G,
    BLUE          => VGA_B,

    RED_RTN       => '0',
    GREEN_RTN     => '0',
    BLUE_RTN      => '0',

    ID            => (others => '0'),
    HSync         => VGA_HS,
    VSync         => VGA_VS
  );

  test_led_inst : entity jacobson_ip.clk_divider(RTL)
  generic map (
    COUNT         => 50000000 -- 100MHz -> 2Hz
  )
  port map (
    clkIn         => CLK100MHZ,
    rstIn         => reset,
    clkOut        => LED(0)
  );
end architecture RTL;