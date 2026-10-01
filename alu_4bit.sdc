###############################################################################
# Created by write_sdc
# Tue Sep  8 23:53:48 2026
###############################################################################
current_design alu_4bit
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[0]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[1]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[2]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[3]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[4]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[5]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[6]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {Y[7]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0500 [get_ports {Y[7]}]
set_load -pin_load 0.0500 [get_ports {Y[6]}]
set_load -pin_load 0.0500 [get_ports {Y[5]}]
set_load -pin_load 0.0500 [get_ports {Y[4]}]
set_load -pin_load 0.0500 [get_ports {Y[3]}]
set_load -pin_load 0.0500 [get_ports {Y[2]}]
set_load -pin_load 0.0500 [get_ports {Y[1]}]
set_load -pin_load 0.0500 [get_ports {Y[0]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[7]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[6]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[5]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[4]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[3]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[2]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[1]}]
set_driving_cell -lib_cell INV_X1 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {Y[0]}]
###############################################################################
# Design Rules
###############################################################################
