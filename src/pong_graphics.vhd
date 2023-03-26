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

    bumperCoords  : in    multiCoords_t(0 to 1); -- two bumpers
    midlineCoords : in    coords_t(0 to 3);      -- one midline
    numCoords     : in    multiCoords_t(0 to 13);-- two numbers with 7 segments each
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

-- fixme. Why doesn't a generate statement work here?
function inBumpers(x, y : coord_t;
                   mcoords : multiCoords_t(0 to 1)
                  ) return boolean is
    variable isIn : boolean := false;
  begin
    -- check if within coords of each of the 2 bumpers
    if(   x >= mcoords(0)(0)  and
          x <= mcoords(0)(1)  and
          y >= mcoords(0)(2)  and
          y <= mcoords(0)(3)) then 
      isIn := true;
    elsif(x >= mcoords(1)(0)  and
          x <= mcoords(1)(1)  and
          y >= mcoords(1)(2)  and
          y <= mcoords(1)(3)) then 
      isIn := true;
    end if;
    return isIn;
  end function;

  -- fixme. Why doesn't a generate statement work here?
  function inNumbers(x, y : coord_t;
                     mcoords : multiCoords_t(0 to 13)
                    ) return boolean is
    variable isIn : boolean := false;
  begin
    -- check if within coords of each segment of the 2 7 segment numbers
    if(   x >= mcoords(0)(0)  and
          x <= mcoords(0)(1)  and
          y >= mcoords(0)(2)  and
          y <= mcoords(0)(3)) then 
      isIn := true;
    elsif(x >= mcoords(1)(0)  and
          x <= mcoords(1)(1)  and
          y >= mcoords(1)(2)  and
          y <= mcoords(1)(3)) then 
      isIn := true;
    elsif(x >= mcoords(2)(0)  and
          x <= mcoords(2)(1)  and
          y >= mcoords(2)(2)  and
          y <= mcoords(2)(3)) then 
      isIn := true;
    elsif(x >= mcoords(3)(0)  and
          x <= mcoords(3)(1)  and
          y >= mcoords(3)(2)  and
          y <= mcoords(3)(3)) then 
      isIn := true;
    elsif(x >= mcoords(4)(0)  and
          x <= mcoords(4)(1)  and
          y >= mcoords(4)(2)  and
          y <= mcoords(4)(3)) then 
      isIn := true;
    elsif(x >= mcoords(5)(0)  and
          x <= mcoords(5)(1)  and
          y >= mcoords(5)(2)  and
          y <= mcoords(5)(3)) then 
      isIn := true;
    elsif(x >= mcoords(6)(0)  and
          x <= mcoords(6)(1)  and
          y >= mcoords(6)(2)  and
          y <= mcoords(6)(3)) then 
      isIn := true;
    elsif(x >= mcoords(7)(0)  and
          x <= mcoords(7)(1)  and
          y >= mcoords(7)(2)  and
          y <= mcoords(7)(3)) then 
      isIn := true;
    elsif(x >= mcoords(8)(0)  and
          x <= mcoords(8)(1)  and
          y >= mcoords(8)(2)  and
          y <= mcoords(8)(3)) then 
      isIn := true;
    elsif(x >= mcoords(9)(0)  and
          x <= mcoords(9)(1)  and
          y >= mcoords(9)(2)  and
          y <= mcoords(9)(3)) then 
      isIn := true;
    elsif(x >= mcoords(10)(0)  and
          x <= mcoords(10)(1)  and
          y >= mcoords(10)(2)  and
          y <= mcoords(10)(3)) then 
      isIn := true;
    elsif(x >= mcoords(11)(0)  and
          x <= mcoords(11)(1)  and
          y >= mcoords(11)(2)  and
          y <= mcoords(11)(3)) then 
      isIn := true;
    elsif(x >= mcoords(12)(0)  and
          x <= mcoords(12)(1)  and
          y >= mcoords(12)(2)  and
          y <= mcoords(12)(3)) then 
      isIn := true;
    elsif(x >= mcoords(13)(0)  and
          x <= mcoords(13)(1)  and
          y >= mcoords(13)(2)  and
          y <= mcoords(13)(3)) then 
      isIn := true;
    end if;

    return isIn;
  end function;

  function inMidline(x, y : coord_t;
                      coords : coords_t(0 to 3)
                    ) return boolean is
    variable isIn : boolean := false;
  begin
    if( x >= coords(0)  and 
        x <= coords(1)  and 
        y >= coords(2)  and 
        y <= coords(3)) then
      isIn := true;
    end if;

    return isIn;
  end function;

  function inBall (x, y : coord_t;
                   coords : coords_t(0 to 3)
                  ) return boolean is
    variable isIn : boolean := false;
  begin
    -- check each segment of the 7 segment display
    if( x >= coords(0)  and 
        x <= coords(1)  and 
        y >= coords(2)  and 
        y <= coords(3)) then 
      isIn := true;
    end if;

    return isIn;
  end function;

begin

  -- ugly, I know.
  RED   <= pixel_s( ((VGA_DEPTH/3)   -1) downto 0);                 --  ((12/3)-1)    =  3
  GREEN <= pixel_s((((VGA_DEPTH/3)*2)-1) downto  (VGA_DEPTH/3));    -- (((12/3)*2)-1) =  7
  BLUE  <= pixel_s((VGA_DEPTH-1)         downto ((VGA_DEPTH/3)*2)); --    12-1        = 11

  
  graphics_proc : process (clk, rst, en, xCoord, yCoord)
  begin
    if(rst = '1') then
      pixel_s <= (others => '0');
    elsif(rising_edge(clk) and (en = '1')) then
      if(   inBumpers(xCoord, yCoord, bumperCoords)) then
        pixel_s <= BUMPERS_RGB;
      elsif(inMidline(xCoord, yCoord, midlineCoords)) then
        pixel_s <= MIDLINE_RGB;
      elsif(inNumbers(xCoord, yCoord, numCoords)) then
        pixel_s <= NUM_RGB;
      elsif(inBall(xCoord, yCoord, ballCoords)) then
        pixel_s <= BALL_RGB;
      else
        pixel_s <= BACKGND_RGB;
      end if;
    end if;
  end process;
end architecture RTL;      