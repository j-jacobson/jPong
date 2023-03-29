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
--             Pong Game Logic
--             Pong Graphics Logic
--             Test LED counter (2Hz Blink on LED[0])
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;     use pong_lib.pong_pack.all;
library jacobson_ip;

entity pong_top is
  generic (
    VGA_DEPTH     : integer := 12;
    NUM_LEDS      : integer := 1
  );
  port (
    CLK100MHZ     : in    std_logic;
    reset_n       : in    std_logic;
    enable        : in    std_logic;

    BTNC          : in    std_logic;
    BTNU          : in    std_logic;
    BTND          : in    std_logic;
    BTNL          : in    std_logic;
    BTNR          : in    std_logic;

    SW            : in    std_logic_vector(13 to 15);

    VGA_R         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    VGA_G         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    VGA_B         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);

    VGA_HS        :   out std_logic;
    VGA_VS        :   out std_logic;

    LED           :   out std_logic_vector((NUM_LEDS-1) downto 0)
  );
end;

architecture RTL of pong_top is

signal clk25MHz        : std_logic;
signal reset           : std_logic;
signal inVisibleArea   : std_logic;
signal xCoord          : coord_t;
signal yCoord          : coord_t;
signal bumperLCoords_s : coords_t(0 to 3);
signal bumperRCoords_s : coords_t(0 to 3);
signal midlineCoords_s : coords_t(0 to 3);
signal numLCoords_s    : multiCoords_t(0 to 6);
signal numRCoords_s    : multiCoords_t(0 to 6);
signal ballCoords_s    : coords_t(0 to 3);
signal controlLIn      : std_logic_vector(0 to 3);
signal controlRIn      : std_logic_vector(0 to 3);
signal PADDLEL_SIZE    : integer;
signal PADDLER_SIZE    : integer;

begin

  reset      <= not reset_n;
  controlLIn <= BTNU & BTND & "00";
  controlRIn <= BTNL & BTNR & "00";

  vga_clk_inst : entity jacobson_ip.clk_divider(RTL)
    generic map (
      COUNT         => 2 -- 100MHz -> 25MHz
    )
    port map (
      clkIn         => CLK100MHZ,
      rstIn         => reset,
      clkOut        => clk25MHz
    );

  vga_inst : entity jacobson_ip.vga_driver(RTL)
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

      inVisibleArea => inVisibleArea,
      xCoord        => xCoord,
      yCoord        => yCoord,

      HSync         => VGA_HS,
      VSync         => VGA_VS
    );

  graphics_inst : entity pong_lib.pong_graphics(RTL)
    generic map (
      VGA_DEPTH     => VGA_DEPTH
    )
    port map (
      clk           => clk25MHz,
      rst           => reset,
      en            => inVisibleArea,

      xCoord        => xCoord,
      yCoord        => yCoord,

      -- game logic will take care of these
      bumperLCoords  => bumperLCoords_s,
      bumperRCoords  => bumperRCoords_s,
      midlineCoords  => midlineCoords_s,
      numLCoords     => numLCoords_s,
      numRCoords     => numRCoords_s,
      ballCoords     => ballCoords_s,

      RED           => VGA_R,
      GREEN         => VGA_G,
      BLUE          => VGA_B
    );

  logic_inst : entity pong_lib.pong_logic(RTL)
    generic map(
    PADDLEL_SIZE    => NORMAL, -- XSMALL, SMALL, NORMAL, LARGE, FULL
    PADDLER_SIZE    => NORMAL,   -- XSMALL, SMALL, NORMAL, LARGE, FULL
    hVisibleArea    => 640,
    vVisibleArea    => 480,
    BUMPER_SPEED    => 100000,
    BALL_SPEED      =>  90000
    )
    port map(
      clk           => clk25MHz,
      rst           => reset,
      en            => '1',

      startIn       => BTNC,
      controlLIn    => controlLIn,
      controlRIn    => controlRIn,

      xCoord        => xCoord,
      yCoord        => yCoord,

      bumperLCoords  => bumperLCoords_s,
      bumperRCoords  => bumperRCoords_s,
      midlineCoords  => midlineCoords_s,
      numLCoords     => numLCoords_s,
      numRCoords     => numRCoords_s,
      ballCoords     => ballCoords_s,

      scoreL        => open,
      scoreR        => open
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