read_liberty platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_verilog synthesis/alu_4bit_mapped.v
link_design alu_4bit
create_clock -period 10 [get_ports clk]
set_output_delay 2 -clock clk [all_outputs]
set_driving_cell -lib_cell INV_X1 [all_outputs]
set_load 0.05 [all_outputs]
report_checks -path_delay min_max -fields {skew cap input_pins nets fanout} -digits 3
report_worst_slack
report_tns
write_sdc alu_4bit.sdc
