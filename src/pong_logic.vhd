-------------------------------------------------
-- filename : pong_logic.vhd
-- date     : 26 Mar 2023
-- Author   : Jonathan L. Jacobson
-- Email    : jacobson.jonathan.1@gmail.com
--
-- This file is the game logic 
-- for the implementation of Pong 
-- on the Nexys A7 development board.
-- 
-- Components: 
--             Game Logic
--             
---------------------------------------------------
library ieee;         use ieee.std_logic_1164.all;
                      use ieee.std_logic_unsigned.all;
                      use ieee.numeric_std.all;
library pong_lib;     use pong_lib.pong_pack.all;
library jacobson_ip;

entity pong_logic is
  generic (
    PADDLEL_SIZE  : integer  := NORMAL; -- XSMALL, SMALL, NORMAL, LARGE, FULL
    PADDLER_SIZE  : integer  := NORMAL; -- XSMALL, SMALL, NORMAL, LARGE, FULL
    hVisibleArea  : integer := 640;
    vVisibleArea  : integer := 480
  );
  port (
    clk           : in    std_logic;
    rst           : in    std_logic;
    en            : in    std_logic;

    bumperCoords  :   out multiCoords_t(0 to 1);
    midlineCoords :   out coords_t(0 to 3);
    numCoords     :   out multiCoords_t(0 to 13);
    ballCoords    :   out coords_t(0 to 3);

    scoreL        :   out integer;
    scoreR        :   out integer
  );
end entity pong_logic;
architecture RTL of pong_logic is
  -- \(\(5\*hVisibleArea/8\)\)
  signal bumperCoords_s  : multiCoords_t(0 to 1) := 
      ((toSLV(10),  toSLV(20),  toSLV((vVisibleArea/2) - (PADDLEL_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLEL_SIZE/2))),
       (toSLV(hVisibleArea-30), toSLV(hVisibleArea-20), toSLV((vVisibleArea/2) - (PADDLER_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLER_SIZE/2))));

  signal midlineCoords_s : coords_t(0 to 3) := 
      (toSLV((hVisibleArea/2)-1),  toSLV((hVisibleArea/2)+1),  toSLV(0),  toSLV(vVisibleArea));

  signal numCoords_s     : multiCoords_t(0 to 13) := 
       -- left number (starts at top, goes CW, then middle) (this is '8')
      ((toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(24)),
       (toSLV(((3*hVisibleArea)/8)-4),  toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(40)),
       (toSLV(((3*hVisibleArea)/8)-4),  toSLV(((3*hVisibleArea)/8)),    toSLV(41),  toSLV(61)),
       (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(57),  toSLV(61)),
       (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)-16), toSLV(41),  toSLV(61)),
       (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)-16), toSLV(20),  toSLV(40)),
       (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)), toSLV(38),  toSLV(42)),

       -- right number (starts at top, goes CW, then middle) (this is '8')
       (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(24)),
       (toSLV(((5*hVisibleArea)/8)+16), toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(40)),
       (toSLV(((5*hVisibleArea)/8)+16), toSLV(((5*hVisibleArea)/8)+20), toSLV(41),  toSLV(61)),
       (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(57),  toSLV(61)),
       (toSLV((5*hVisibleArea)/8),      toSLV((5*hVisibleArea/8)+4),    toSLV(41),  toSLV(61)),
       (toSLV((5*hVisibleArea)/8),      toSLV((5*hVisibleArea/8)+4),    toSLV(20),  toSLV(40)),
       (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(38),  toSLV(42)));
       --(toSLV(hVisibleArea+1),          toSLV(hVisibleArea+1), toSLV(vVisibleArea+1),  toSLV(vVisibleArea+1)));

  signal ballCoords_s    : coords_t(0 to 3) := 
      (toSLV(10),  toSLV(20),  toSLV(30),  toSLV(40));

begin

  --reset_proc : process(clk, rst)
  --begin
  --  if(rst = '1') then
  --    bumperCoords_s(0)(0) <= std_logic_vector(to_unsigned(10,  bumperCoords_s(0)(0)'length));
  --    bumperCoords_s(0)(1) <= std_logic_vector(to_unsigned(20,  bumperCoords_s(0)(1)'length));
  --    bumperCoords_s(0)(2) <= std_logic_vector(to_unsigned(30,  bumperCoords_s(0)(2)'length));
  --    bumperCoords_s(0)(3) <= std_logic_vector(to_unsigned(50,  bumperCoords_s(0)(3)'length));

  --    bumperCoords_s(1)(0) <= std_logic_vector(to_unsigned(100, bumperCoords_s(1)(0)'length));
  --    bumperCoords_s(1)(1) <= std_logic_vector(to_unsigned(110, bumperCoords_s(1)(1)'length));
  --    bumperCoords_s(1)(2) <= std_logic_vector(to_unsigned(130, bumperCoords_s(1)(2)'length));
  --    bumperCoords_s(1)(3) <= std_logic_vector(to_unsigned(150, bumperCoords_s(1)(3)'length));
  --  end if;
  --end process;
  -- setup Left Bumper
  
  -- setup Right Bumper

  -- set midline

  -- set Ball




  -- worry about these later
  -- set Left Number
  -- set Right Number

  bumperCoords  <= bumperCoords_s;
  midlineCoords <= midlineCoords_s;
  numCoords     <= numCoords_s;
  ballCoords    <= ballCoords_s;
  scoreL        <= 0;
  scoreR        <= 0;

end architecture RTL;