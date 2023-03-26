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

  subtype coord_t       is std_logic_vector(31 downto 0); -- leave coordinate depth open
  -- array of coords
  type    coords_t      is array (natural range <>) of coord_t;
  -- array of arrays of coords, for the 2 bumpers and the 7 segment displays
  type    multiCoords_t is array (natural range <>) of coords_t(0 to 3);

end package;