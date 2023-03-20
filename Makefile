#-------------------------------------------------
#-- filename : Makefile
#-- date     : 19 Mar 2023
#-- Author   : Jonathan L. Jacobson
#-- Email    : jacobson.jonathan.1@gmail.com
#--
#-- Makefile for Pong implementation
#-- of a counter.
#--
#-------------------------------------------------

compile: src/vga_counter.vhd jacobson_ip/ip_counter.vhd tb/pong_tb.sv
	vcom jacobson_ip/ip_counter.vhd src/vga_counter.vhd
	vlog tb/pong_tb.sv

sim: FORCE
	vsim pong_tb

all:
	make compile
	make sim

FORCE: ;