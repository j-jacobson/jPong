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
    --PADDLE_SIZE   : size_t  := NORMAL; -- XSMALL, SMALL, NORMAL, LARGE, FULL
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
    ballCoords    :   out coords_t(0 to 3)
  );
end entity pong_logic;
architecture RTL of pong_logic is

  signal bumperCoords_s  : multiCoords_t(0 to 1) := (others => (others => (others => '0')));
  signal midlineCoords_s : coords_t(0 to 3) := (others => (others => '0'));
  signal numCoords_s     : multiCoords_t(0 to 13) := (others => (others => (others => '0')));
  signal ballCoords_s    : coords_t(0 to 3) := (others => (others => '0'));

begin

  --reset_proc : process(clk, rst)
  --begin
  --  if(rst = '1') then
      bumperCoords_s(0)(0) <= std_logic_vector(to_unsigned(10,  bumperCoords_s(0)(0)'length));
      bumperCoords_s(0)(1) <= std_logic_vector(to_unsigned(20,  bumperCoords_s(0)(1)'length));
      bumperCoords_s(0)(2) <= std_logic_vector(to_unsigned(30,  bumperCoords_s(0)(2)'length));
      bumperCoords_s(0)(3) <= std_logic_vector(to_unsigned(50,  bumperCoords_s(0)(3)'length));
      bumperCoords_s(1)(0) <= std_logic_vector(to_unsigned(100, bumperCoords_s(1)(0)'length));
      bumperCoords_s(1)(1) <= std_logic_vector(to_unsigned(110, bumperCoords_s(1)(1)'length));
      bumperCoords_s(1)(2) <= std_logic_vector(to_unsigned(130, bumperCoords_s(1)(2)'length));
      bumperCoords_s(1)(3) <= std_logic_vector(to_unsigned(150, bumperCoords_s(1)(3)'length));
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

end architecture RTL;