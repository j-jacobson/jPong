-------------------------------------------------
-- filename : pong_graphics.vhd
-- date     : 25 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the graphics logic 
-- of the implementation of Pong 
-- on the Nexys A7 development board.
-- 
-- Components: 
--             Graphics Logic
--             
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;     use pong_lib.pong_pack.all;
library jacobson_ip;

entity pong_graphics is
  generic (
    VGA_DEPTH     : integer := 12
  );
  port (
    clk           : in    std_logic;
    rst           : in    std_logic;
    en            : in    std_logic; -- inVisibleArea

    xCoord        : in    coord_t;
    yCoord        : in    coord_t;

    bumperLCoords : in    coords_t(0 to 3);      -- left bumper
    bumperRCoords : in    coords_t(0 to 3);      -- right bumper
    midlineCoords : in    coords_t(0 to 3);      -- one midline
    numLCoords    : in    multiCoords_t(0 to 6); -- left number with 7 segments
    numRCoords    : in    multiCoords_t(0 to 6); -- right number with 7 segments
    ballCoords    : in    coords_t(0 to 3);      -- one ball (unless ...?)

    RED           :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    GREEN         :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0);
    BLUE          :   out std_logic_vector(((VGA_DEPTH/3)-1) downto 0)
  );
end entity pong_graphics;

architecture RTL of pong_graphics is

constant BUMPERS_RGB   : std_logic_vector(VGA_DEPTH-1 downto 0) := (others => '1'); -- white
constant MIDLINE_RGB   : std_logic_vector(VGA_DEPTH-1 downto 0) := (others => '1'); -- white
constant NUM_RGB       : std_logic_vector(VGA_DEPTH-1 downto 0) := (others => '1'); -- white
constant BALL_RGB      : std_logic_vector(VGA_DEPTH-1 downto 0) := (others => '1'); -- white
constant BACKGND_RGB   : std_logic_vector(VGA_DEPTH-1 downto 0) := (others => '0'); -- black

signal pixel_s : std_logic_vector((VGA_DEPTH-1) downto 0);

function inNumbers(x, y: coord_t; mcoords: multiCoords_t(0 to 6)) return boolean is
  variable isIn : boolean := false;
begin
  if(inCoords(x, y, mcoords(0)) or
     inCoords(x, y, mcoords(1)) or
     inCoords(x, y, mcoords(2)) or
     inCoords(x, y, mcoords(3)) or
     inCoords(x, y, mcoords(4)) or
     inCoords(x, y, mcoords(5)) or
     inCoords(x, y, mcoords(6))) then
    isIn := true;
  end if;
  return isIn;
end function;

begin

  -- ugly, I know.
  RED   <= pixel_s( ((VGA_DEPTH/3)   -1) downto 0);                 --  ((12/3)-1)    =  3
  GREEN <= pixel_s((((VGA_DEPTH/3)*2)-1) downto  (VGA_DEPTH/3));    -- (((12/3)*2)-1) =  7
  BLUE  <= pixel_s((VGA_DEPTH-1)         downto ((VGA_DEPTH/3)*2)); --    12-1        = 11

  graphics_proc : process (clk, rst, en)
  begin
    if(rst = '1') then
      pixel_s <= (others => '0');
    elsif(rising_edge(clk) and (en = '1')) then
      if(inCoords(xCoord, yCoord, bumperLCoords) or inCoords(xCoord, yCoord, bumperRCoords)) then
        pixel_s <= BUMPERS_RGB;
      elsif(inCoords(xCoord, yCoord, midlineCoords)) then
        pixel_s <= MIDLINE_RGB;
      elsif(inNumbers(xCoord, yCoord, numLCoords) or inNumbers(xCoord, yCoord, numRCoords)) then
        pixel_s <= NUM_RGB;
      elsif(inCoords(xCoord, yCoord, ballCoords)) then
        pixel_s <= BALL_RGB;
      else
        pixel_s <= BACKGND_RGB;
      end if;
    end if;
  end process;
end architecture RTL;      