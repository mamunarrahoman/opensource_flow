# =======================================================================
# SDC Constraints for alu_4bit Module
# Target: 100 MHz (10.0ns Period)
# =======================================================================

# 1. Define the Clock
# Creates a clock named 'master_clk' bound to your 'clk' input pin
create_clock -name master_clk -period 10.0 [get_ports clk]

# 2. Input Delays
# Tells ABC that inputs arrive up to 2.0ns after the clock edge
set_input_delay -clock master_clk 2.0 [get_ports A[*]]
set_input_delay -clock master_clk 2.0 [get_ports B[*]]
set_input_delay -clock master_clk 2.0 [get_ports Opcode[*]]

# 3. Output Delays
# Tells ABC that the external circuit needs the 8-bit output 'Y' 
# to be stable 3.0ns before the next clock edge
set_output_delay -clock master_clk 3.0 [get_ports Y[*]]

