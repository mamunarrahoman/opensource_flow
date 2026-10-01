DESIGNER      : Mamunar Rahoman
# STAGE         : Constraints File
LAST UPDATED  : 2026-09-04 01:25:02
# VERSION       : build_v1.1

#create_clock -name clk -period 10.00 [get_ports clk]
#set_clock_uncertainty 0.200 [all_clocks]
#set_max_fanout 4 [current_design]
#set_max_transition 0.500 [current_design]
#set_input_delay  -clock [get_clocks clk] -add_delay  2.000 [all_inputs]
#set_output_delay -clock [get_clocks clk] -add_delay 2.000 [all_outputs]


create_clock -period 10.0 [get_ports clk]
set_input_delay 2.0 -clock clk [all_inputs]
set_output_delay 2.0 -clock clk [all_outputs]
