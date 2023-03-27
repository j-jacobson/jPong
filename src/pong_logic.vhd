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
    hVisibleArea  : integer := 640;
    vVisibleArea  : integer := 480;
    PADDLEL_SIZE  : integer := NORMAL; -- XSMALL, SMALL, NORMAL, LARGE, FULL
    PADDLER_SIZE  : integer := NORMAL; -- XSMALL, SMALL, NORMAL, LARGE, FULL
    BUMPER_SPEED  : integer := 20;
    BALL_SPEED    : integer := 30
  );
  port (
    clk           : in    std_logic;
    rst           : in    std_logic;
    en            : in    std_logic;

    controlLIn    : in    std_logic_vector(0 to 3);
    controlRIn    : in    std_logic_vector(0 to 3);

    bumperLCoords :   out coords_t(0 to 3);
    bumperRCoords :   out coords_t(0 to 3);
    midlineCoords :   out coords_t(0 to 3);
    numLCoords    :   out multiCoords_t(0 to 6);
    numRCoords    :   out multiCoords_t(0 to 6);
    ballCoords    :   out coords_t(0 to 3);

    scoreL        :   out integer;
    scoreR        :   out integer
  );
end entity pong_logic;
architecture RTL of pong_logic is
  signal scoreL_s : integer := 0;
  signal scoreR_s : integer := 0;

  signal bumperLCoords_s  : coords_t(0 to 3) := 
      (toSLV(10),  toSLV(20),  toSLV((vVisibleArea/2) - (PADDLEL_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLEL_SIZE/2)));

  signal bumperRCoords_s  : coords_t(0 to 3) :=
       (toSLV(hVisibleArea-30), toSLV(hVisibleArea-20), toSLV((vVisibleArea/2) - (PADDLER_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLER_SIZE/2)));

  signal midlineCoords_s : coords_t(0 to 3) := 
      (toSLV((hVisibleArea/2)-1),  toSLV((hVisibleArea/2)+1),  toSLV(0),  toSLV(vVisibleArea));

  signal numLCoords_s     : multiCoords_t(0 to 6) := 
       intToPixels(0, (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(61)));

  signal numRCoords_s     : multiCoords_t(0 to 6) := 
       intToPixels(0, (toSLV((5*hVisibleArea)/8),       toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(61)));

  signal ballCoords_s    : coords_t(0 to 3) := 
      (toSLV(10),  toSLV(20),  toSLV(30),  toSLV(40));

  signal controllerLdirection : std_logic_vector(3 downto 0) := "0000";
  signal controllerRdirection : std_logic_vector(3 downto 0) := "0000";
  signal ballStatus           : std_logic_vector(3 downto 0) := "0000";

  signal ballDirection : std_logic_vector(3 downto 0) := "0000";

  signal bumperSpeedControl : std_logic := '0';
  signal ballSpeedControl   : std_logic := '0';
begin

  reset_proc : process(clk, rst)
  begin
    if(rst = '1') then
      scoreL_s <= 0;
      scoreR_s <= 0;
      bumperLCoords_s <=
       (toSLV(10),  toSLV(20),  toSLV((vVisibleArea/2) - (PADDLEL_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLEL_SIZE/2)));
      bumperRCoords_s <=
       (toSLV(hVisibleArea-30), toSLV(hVisibleArea-20), toSLV((vVisibleArea/2) - (PADDLER_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLER_SIZE/2)));
      midlineCoords_s <=
      (toSLV((hVisibleArea/2)-1),  toSLV((hVisibleArea/2)+1),  toSLV(0),  toSLV(vVisibleArea));
      numLCoords_s    <=
       intToPixels(0, (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(61)));
      numRCoords_s    <=
       intToPixels(0, (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(61)));
      ballCoords_s   <=
       (toSLV(hVisibleArea+1), toSLV(hVisibleArea+1), toSLV(vVisibleArea+1),  toSLV(vVisibleArea+1));

    elsif(rising_edge(clk) and en = '1') then
      -- Left Bumper
        bumperLCoords_s <= shiftCoords(controllerLdirection, bumperLCoords_s);
      -- Right Bumper
        bumperRCoords_s <= shiftCoords(controllerRdirection, bumperRCoords_s); 
      -- Ball
        ballCoords_s <= shiftCoords(ballDirection, ballCoords_s);
      -- Left Number
        numLCoords_s <= intToPixels(scoreL_s, (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(61)));
      -- Right Number
        numRCoords_s <= intToPixels(scoreR_s, (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(61)));
    end if;
  end process;

  bumper_speed_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0,
    STOP_VAL   => BUMPER_SPEED,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => en,
    countOut => open,
    doneOut  => bumperSpeedControl
  );

  ball_speed_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    START_VAL  => 0,
    STOP_VAL   => BALL_SPEED,
    LOOP_IN    => '1'
  )
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => en,
    countOut => open,
    doneOut  => ballSpeedControl
  );

  controllerLdirection(0)   <= bumperSpeedControl when controlLIn(0) = '1' else '0';
  controllerLdirection(1)   <= bumperSpeedControl when controlLIn(1) = '1' else '0';
  controllerRdirection(0)   <= bumperSpeedControl when controlRIn(0) = '1' else '0';
  controllerRdirection(1)   <= bumperSpeedControl when controlRIn(1) = '1' else '0';
  ballDirection(0) <= ballSpeedControl when ballStatus(0) = '1' else '0';
  ballDirection(1) <= ballSpeedControl when ballStatus(1) = '1' else '0';
  ballDirection(2) <= ballSpeedControl when ballStatus(2) = '1' else '0';
  ballDirection(3) <= ballSpeedControl when ballStatus(3) = '1' else '0';

  bumperLCoords <= bumperLCoords_s;
  bumperRCoords <= bumperRCoords_s;
  midlineCoords <= midlineCoords_s;
  numLCoords    <= numLCoords_s;
  numRCoords    <= numRCoords_s;
  ballCoords    <= ballCoords_s;
  scoreL        <= scoreL_s;
  scoreR        <= scoreR_s;

end architecture RTL;