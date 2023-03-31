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
    BUMPER_SPEED  : integer := 20
  );
  port (
    clk           : in    std_logic;
    rst           : in    std_logic;
    en            : in    std_logic;

    startIn       : in    std_logic;
    controlLIn    : in    std_logic_vector(0 to 3);
    controlRIn    : in    std_logic_vector(0 to 3);

    xCoord        : in    coord_t;
    yCoord        : in    coord_t;

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
      (toSLV((3*hVisibleArea)/8),  toSLV(((3*hVisibleArea)/8)+10),  toSLV((vVisibleArea/2) - 5),  toSLV((vVisibleArea/2) + 5));

  signal topWallCoords   : coords_t(0 to 3) := 
      (toSLV(0),  toSLV(hVisibleArea),  toSLV(0),  toSLV(0));

  signal botWallCoords   : coords_t(0 to 3) := 
      (toSLV(0),  toSLV(hVisibleArea),  toSLV(vVisibleArea-1),  toSLV(vVisibleArea-1));

  signal rightWallCoords   : coords_t(0 to 3) := 
      (toSLV(hVisibleArea-10),  toSLV(hVisibleArea),  toSLV(0),  toSLV(vVisibleArea));

  signal leftWallCoords   : coords_t(0 to 3) := 
      (toSLV(0),  toSLV(1),   toSLV(0),  toSLV(vVisibleArea));

  signal controllerLdirection : std_logic_vector(0 to 3) := "0000";
  signal controllerRdirection : std_logic_vector(0 to 3) := "0000";
  signal ballStatus           : std_logic_vector(0 to 3) := "0000";

  signal ballDirection : std_logic_vector(0 to 3) := "0000";

  signal bumperSpeedControl : std_logic := '0';
  signal ballVSpeedControl  : std_logic := '0';
  signal ballHSpeedControl  : std_logic := '0';
  signal ballHSpeed         : integer :=  60000;
  signal ballVSpeed         : integer := 100000;

  signal ballStarted        : std_logic := '0';

begin

  nonball_proc : process(clk, rst)
  begin
    if(rst = '1') then
      bumperLCoords_s <=
       (toSLV(11),  toSLV(21),  toSLV((vVisibleArea/2) - (PADDLEL_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLEL_SIZE/2)));
      bumperRCoords_s <=
       (toSLV(hVisibleArea-30), toSLV(hVisibleArea-20), toSLV((vVisibleArea/2) - (PADDLER_SIZE/2)),  toSLV((vVisibleArea/2) + (PADDLER_SIZE/2)));
      midlineCoords_s <=
      (toSLV((hVisibleArea/2)-1),  toSLV((hVisibleArea/2)+1),  toSLV(0),  toSLV(vVisibleArea));
      numLCoords_s    <=
       intToPixels(0, (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(61)));
      numRCoords_s    <=
       intToPixels(0, (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(61)));
    elsif(rising_edge(clk) and en = '1') then
      -- Left Bumper
      bumperLCoords_s <= shiftCoords(controllerLdirection, bumperLCoords_s);
      -- Right Bumper
      bumperRCoords_s <= shiftCoords(controllerRdirection, bumperRCoords_s);
      -- Left Number
      numLCoords_s <= intToPixels(scoreL_s, (toSLV(((3*hVisibleArea)/8)-20), toSLV(((3*hVisibleArea)/8)),    toSLV(20),  toSLV(61)));
      -- Right Number
      numRCoords_s <= intToPixels(scoreR_s, (toSLV((5*hVisibleArea)/8),      toSLV(((5*hVisibleArea)/8)+20), toSLV(20),  toSLV(61)));
    end if;
  end process;

  bumper_speed_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    LOOP_IN    => '1'
  )
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => en,
    startVal => 0,
    stopVal  => BUMPER_SPEED,
    countOut => open,
    doneOut  => bumperSpeedControl
  );

  ball_Hspeed_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    LOOP_IN    => '1'
  )
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => en,
    startVal => 0,
    stopVal  => ballHSpeed,
    countOut => open,
    doneOut  => ballHSpeedControl
  );

  ball_Vspeed_inst : entity jacobson_ip.ip_counter(RTL)
  generic map (
    LOOP_IN    => '1'
  )
  port map (
    clk      => clk,
    rst      => rst,
    enableIn => en,
    startVal => 0,
    stopVal  => ballVSpeed,
    countOut => open,
    doneOut  => ballVSpeedControl
  );

  ball_bounce_proc : process(clk, rst)
  begin
    if(rst = '1') then
      scoreL_s     <= 0;
      scoreR_s     <= 0;
      ballStarted  <= '0';
      ballStatus   <= "0000";
      ballCoords_s <= (toSLV((3*hVisibleArea)/8),  toSLV(((3*hVisibleArea)/8)+10),  toSLV((vVisibleArea/2) - 5),  toSLV((vVisibleArea/2) + 5));
    elsif(rising_edge(clk)) then
      -- start the ball
      if(startIn = '1' and ballStarted = '0') then
        ballStatus(2) <= '1';
        ballStarted   <= '1';
      end if;
      if((isTouching(ballCoords_s, topWallCoords)) and ballStatus(0) = '1') then
        ballStatus(0) <= '0';
        ballStatus(1) <= '1';
      elsif((isTouching(ballCoords_s, botWallCoords)) and ballStatus(1) = '1') then
        ballStatus(0) <= '1';
        ballStatus(1) <= '0';
      elsif(isTouching(ballCoords_s, bumperLCoords_s) and ballStatus(2) = '1') then
        if((ballStatus(0) = '0' and ballStatus(1) = '0') and controlLIn(0) = '1') then
          ballStatus(0) <= '1';
          ballStatus(1) <= '0';
        elsif((ballStatus(0) = '0' and ballStatus(1) = '0') and controlLIn(1) = '1') then
          ballStatus(0) <= '1';
          ballStatus(1) <= '0';
        end if;
        ballStatus(2) <= '0';
        ballStatus(3) <= '1';
      elsif(isTouching(ballCoords_s, bumperRCoords_s) and ballStatus(3) = '1') then
        if((ballStatus(0) = '0' and ballStatus(1) = '0') and controlRIn(0) = '1') then
          ballStatus(0) <= '1';
          ballStatus(1) <= '0';
        elsif((ballStatus(0) = '0' and ballStatus(1) = '0') and controlRIn(1) = '1') then
          ballStatus(0) <= '1';
          ballStatus(1) <= '0';
        end if;
        ballStatus(2) <= '1';
        ballStatus(3) <= '0';
      elsif(isTouching(ballCoords_s, leftWallCoords)) then
        ballCoords_s <= (toSLV((3*hVisibleArea)/8),  toSLV(((3*hVisibleArea)/8)+10),  toSLV((vVisibleArea/2) - 5),  toSLV((vVisibleArea/2) + 5));
        ballStarted  <= '0';
        ballStatus   <= "0000";
        scoreR_s     <= scoreR_s + 1;
      elsif(isTouching(ballCoords_s, rightWallCoords)) then
        ballCoords_s <= (toSLV((3*hVisibleArea)/8),  toSLV(((3*hVisibleArea)/8)+10),  toSLV((vVisibleArea/2) - 5),  toSLV((vVisibleArea/2) + 5));
        ballStarted  <= '0';
        ballStatus   <= "0000";
        scoreL_s     <= scoreL_s + 1;
      else
        -- Ball Coordinates
        ballCoords_s <= shiftCoords(ballDirection, ballCoords_s);
      end if;
    end if;
  end process;

  controllerLdirection(0)   <= bumperSpeedControl when controlLIn(0) = '1' else '0';
  controllerLdirection(1)   <= bumperSpeedControl when controlLIn(1) = '1' else '0';
  controllerRdirection(0)   <= bumperSpeedControl when controlRIn(0) = '1' else '0';
  controllerRdirection(1)   <= bumperSpeedControl when controlRIn(1) = '1' else '0';
  ballDirection(0) <= ballVSpeedControl when ballStatus(0) = '1' else '0';
  ballDirection(1) <= ballVSpeedControl when ballStatus(1) = '1' else '0';
  ballDirection(2) <= ballHSpeedControl when ballStatus(2) = '1' else '0';
  ballDirection(3) <= ballHSpeedControl when ballStatus(3) = '1' else '0';

  bumperLCoords <= bumperLCoords_s;
  bumperRCoords <= bumperRCoords_s;
  midlineCoords <= midlineCoords_s;
  numLCoords    <= numLCoords_s;
  numRCoords    <= numRCoords_s;
  ballCoords    <= ballCoords_s;
  scoreL        <= scoreL_s;
  scoreR        <= scoreR_s;

end architecture RTL;