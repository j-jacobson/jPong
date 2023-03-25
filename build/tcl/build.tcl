open_project /home/jonathan/Projects/Rhino/Pong/build/pong.xpr
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1