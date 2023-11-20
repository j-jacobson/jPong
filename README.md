# Digital Ping Pong
Digital Ping Pong on the Nexys A7

This is to be a full and complete game of Digital Ping Pong written by myself.

Currently, the game is playable with 2 players. Two paddles are created and a ball. The start button is pushed by the player the ball is in front of and the ball is launched towards their paddle. The ball bounces off of the paddles and upper and lower walls until it hits the left or right wall behind a players paddle. Then the score increments and the ball is reset. When the ball bounces, it makes a beeping noise. The paddles are configurable to be different sizes: Normal, Large, Full (for single player play), small, and extra small.

## File List
### pong_top.vhd
Top Level

### pong_logic.vhd
Game logic

### pong_graphics.vhd
Video Logic

### pong_pack.vhd
Custom types and functions

## Components:
### Clock Divider
Divides clocks from an input frequency to a configurable output frequency. Currently set to divide a 100MHz clock into a 25Mhz clock for VGA purposes.

### VGA Driver
Simple VGA driver that takes in a clock and outputs the information needed to create a VGA feed (cartesian pixel location, and whether the current pixel is visible or not). Currently it is set for 640x480 resolution with a clock speed of 25Mhz.

### Video Logic
Takes in game component pixel arrays and the current pixel the VGA driver is writing, then outputs the correct RGB signals to drive the pixel.

### Game Logic
Creates and updates the pixel arrays for each game component (paddles, ball, score numbers).

### Sound Logic
Takes in a play signal, and outputs a PWM beep for when the ball hits the wall or a paddle.

### LED test
Outputs a 2Hz LED pulse, so that you can tell the board was correctly programmed. Optional.

## Limitations
There is currently no AI available for single player play. There is currently no variation in ball speed based on bounces. These are planned to be added in the future. The score currently only increments to 9 and then goes into a '-' state. That is planned to be changed in the future.

## IP
My personal IP is currently private. It should be obvious what pieces are needed based on the instantiations. If you are really struggling getting this to work, reach out and I can share some of the other code.

Thanks!
