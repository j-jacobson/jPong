-------------------------------------------------
-- filename : pong_pack.vhd
-- date     : 25 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the type package for
-- the implementation of Pong 
-- on the Nexys A7 development board.
-- 
-- Components: 
--             Type definitions
--             
-------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;

package pong_pack is

  constant v_Size     : integer := 480;
  constant h_Size     : integer := 640;
  constant COORD_LEN  : integer := 32;
  constant XSMALL     : integer := 30;
  constant SMALL      : integer := 50;
  constant NORMAL     : integer := 80;
  constant LARGE      : integer := 150;
  constant FULL       : integer := 480;

  subtype coord_t       is std_logic_vector(COORD_LEN-1 downto 0); -- leave coordinate depth open
  -- array of coords
  type    coords_t      is array (natural range <>) of coord_t;
  -- array of arrays of coords, for the 2 bumpers and the 7 segment displays
  type    multiCoords_t is array (natural range <>) of coords_t(0 to 3);
  -- int to SLV function
  function toSLV(int: integer) return std_logic_vector;
  -- function to see if a pixel is within a range (x0, x1, y0, y1)
  function inCoords(x, y: coord_t;  coords : coords_t(0 to 3)) return boolean;
  -- function to shift coords of an object
  function shiftCoords(direction: std_logic_vector(3 downto 0); coords : coords_t(0 to 3)) return coords_t;
  -- function to turn an integer into a picture of pixels
  function intToPixels(int: integer; bounds: coords_t(0 to 3)) return multiCoords_t;
end package;

package body pong_pack is

  function toSLV(int: integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(int,  COORD_LEN));
  end function;

  function inCoords(x, y   : coord_t;
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

  function shiftCoords(direction: std_logic_vector(3 downto 0);
                       coords   : coords_t(0 to 3)
                      )return coords_t is
  variable shifted : coords_t(0 to 3) := coords;
  begin
    if(direction(0) = '1' and coords(2) > 0) then -- up
      shifted(2) := coords(2) - toSLV(1);
      shifted(3) := coords(3) - toSLV(1);
    elsif(direction(1) = '1' and coords(3) < v_Size) then -- down
      shifted(2) := coords(2) + toSLV(1);
      shifted(3) := coords(3) + toSLV(1);
    end if;

    if(direction(2) = '1' and coords(0) > 0) then -- left
      shifted(0) := coords(0) - toSLV(1);
      shifted(1) := coords(1) - toSLV(1);
    elsif(direction(3) = '1' and coords(1) < h_Size) then -- right
      shifted(0) := coords(0) + toSLV(1);
      shifted(1) := coords(1) + toSLV(1);
    end if;
    return shifted;
  end function;

  function intToPixels(int: integer;
                       bounds: coords_t(0 to 3)
                      ) return multiCoords_t is
    variable pixelsOut : multiCoords_t(0 to 6) :=
    (((bounds(0),    bounds(1),    bounds(2),             bounds(2)+4)),
     ((bounds(1)-4), bounds(1),    bounds(2),             bounds(3)-bounds(2)),
     ((bounds(1)-4), bounds(1),    bounds(3)-bounds(2),   bounds(3)),
     ((bounds(0)),   bounds(1),    bounds(3)-4,           bounds(3)),
     ((bounds(0)),   bounds(0)+4,  bounds(3)-bounds(2),   bounds(3)),
     ((bounds(0)),   bounds(0)+4,  bounds(2),             bounds(3)-bounds(2)),
     (bounds(0),     bounds(1),    bounds(3)-bounds(2)-2, bounds(3)-bounds(2)+2));
    variable segmentOff : coords_t(0 to 3) := (toSLV(h_Size+1), toSLV(h_Size+1),    toSLV(v_Size+1), toSLV(v_Size+1));
  begin
    if(int = 0) then
      pixelsOut(6) := (toSLV(h_Size+1), toSLV(h_Size+1),    toSLV(v_Size+1), toSLV(v_Size+1));
    elsif(int = 1) then
      pixelsOut(0) := segmentOff;
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
      pixelsOut(6) := segmentOff;
    elsif(int = 2) then
      pixelsOut(2) := segmentOff;
      pixelsOut(5) := segmentOff;
    elsif(int = 3) then
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
    elsif(int = 4) then
      pixelsOut(0) := segmentOff;
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
    elsif(int = 5) then
      pixelsOut(1) := segmentOff;
      pixelsOut(4) := segmentOff;
    elsif(int = 6) then
      pixelsOut(1) := segmentOff;
    elsif(int = 7) then
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
      pixelsOut(5) := segmentOff;
      pixelsOut(6) := segmentOff;
    -- 8 is the default, we don't need a case
    elsif(int = 9) then
      pixelsOut(3) := segmentOff;
      pixelsOut(4) := segmentOff;
    end if;

    return pixelsOut;
  end function;

end package body pong_pack;