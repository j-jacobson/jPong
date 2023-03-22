##################################################
# Filename     : Makefile
# Date         : 19 Mar 2023
# Author       : Jonathan L. Jacobson
# Email        : jacobson.jonathan.1@gmail.com
#
# Makefile for Pong implementation.
#
#
##################################################

compile_ip: jacobson_ip/*
	vcom -work lib/jacobson_ip \
	     jacobson_ip/ip_counter.vhd \
	     jacobson_ip/vga_counter.vhd

compile_tb: tb/*
	vlog -work lib/pong_lib \
	     tb/pong_tb.sv

compile_design: src/*
	vcom -work lib/pong_lib \
	     src/vga_driver.vhd \
	     src/pong_top.vhd

compile:
	make compile_ip
	make compile_design
	make compile_tb

sim: FORCE
	vsim pong_lib.pong_tb -do "do sim/wave.do; run 500us"

all:
	make compile
	make sim

FORCE: ;