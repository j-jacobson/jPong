##################################################
# Filename     : Makefile
# Date         : 19 Mar 2023
# Author       : Jonathan L. Jacobson
# Email        : jacobson.jonathan.1@gmail.com
#
# Makefile for Pong implementation.
#
##################################################

LIB_NAME = pong_lib
LIB_DIR  = ./lib
TB_NAME  = pong_tb

compile_ip:
	cd jacobson_ip && make compile

compile_tb: tb/*
	vlog -work lib/$(LIB_NAME) \
	     tb/pong_tb.sv

compile_design: src/*
	vcom -work lib/$(LIB_NAME) \
	     src/vga_driver.vhd \
	     src/pong_top.vhd

compile:
	make compile_ip
	make compile_design
	make compile_tb

sim: FORCE
	vsim $(LIB_NAME).$(TB_NAME) -do "do sim/wave.do; run 10000us"

all:
	make compile
	make sim

new:
	mkdir -p docs tb src sim lib
	test -f .gitignore || echo lib/* > .gitignore

# Delete the library using vdel
clean:
	cd jacobson_ip && \
	make clean
	cd $(LIB_DIR) && \
	vdel -all -lib $(LIB_NAME)

FORCE: ;