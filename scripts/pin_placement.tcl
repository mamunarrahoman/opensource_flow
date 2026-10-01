# DESIGN NAME   : alu_4bit
# STAGE         : Floorplan
# LAST UPDATED  : 2026-09-06 00:29:43
# VERSION       : build_v1.1
# Tool          : Openroad
# DESIGNER      : Mamunar Rahoman

# Pin placement tips | below text is commented in a non-executable nest.
if 0 {
       	Pin planning strategy: Hand-place a small set of critical/differential/analog pins first (clock, reset, high-fanout control, JTAG),  then let the automatic placer fill in the rest with even spacing and layer/side rules.
 	Pin layers: Horizontal pins go on a horizontal metal layer, vertical pins on a vertical metal layer. Check tech LEF for which metals run which direction.
}

set PIN_LAYER_HOR   "metal5"
set PIN_LAYER_VER   "metal6"

# Manual Pin placement: Clock pin -- place centered on the top edge for a balanced H-tree/CTS start.i | Async reset -- place near clock for short, controlled skew to reset tree.
# TOP side pin placement: clk
place_pin -pin_name "clk" -layer $PIN_LAYER_VER -location {87.090 174.18} -pin_size {2 2}

# Data-bus pin placment strategy: Example bus kept together on the left edge, evenly spaced, in bit order -- useful for datapath-heavy busses where physical adjacency matches logical adjacency (helps timing and reduces routing congestion.
# LEFT side pin placement: A
place_pin -pin_name "Opcode[0]" -layer $PIN_LAYER_VER -location {81.090 0} -pin_size {2 2}
place_pin -pin_name "Opcode[1]" -layer $PIN_LAYER_VER -location {85.090 0} -pin_size {2 2}

# LEFT side pin placement: A&B
set data_bus_length 8
set bus_y_start 62.096
# Center to center distance of two pin is pitch
set bus_y_pitch 4

for {set i 0} {$i < $data_bus_length} {incr i} {
	set bus_y_start 62.096
	if ($i<=3) {
    	place_pin -pin_name "A\[$i\]" \
        	  -layer $PIN_LAYER_HOR \
        	  -location "0 [expr {$bus_y_start + $i * $bus_y_pitch}]" \
        	  -pin_size {2 2}
} else {
	place_pin -pin_name "B\[[expr $i-4]\]" \
                  -layer $PIN_LAYER_HOR \
                  -location "0 [expr 20+[expr {$bus_y_start + $i * $bus_y_pitch}]]" \
                  -pin_size {2 2}
}
}

# RIGHT side pin placement: Y
set data_bus_length 8
set bus_y_start 72.090
set bus_y_pitch 4

for {set i 0} {$i < $data_bus_length} {incr i} {
	set bus_y_start 72.090
    	place_pin -pin_name "Y\[$i\]" \
        	  -layer $PIN_LAYER_HOR \
        	  -location "174.18 [expr {$bus_y_start + $i * $bus_y_pitch}]" \
       		  -pin_size {2 2}
}
