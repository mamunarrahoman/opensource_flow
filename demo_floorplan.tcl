###############################################################################
# floorplan_pins.tcl
#
# Floorplan initialization + I/O pin planning script for OpenROAD.
#
# Stage in flow:  synthesis (netlist) -> [THIS SCRIPT: floorplan + pins] ->
#                  tapcell/PDN -> global placement -> ...
#
# Usage:
#   openroad -gui floorplan_pins.tcl
#   or source it from a wrapper flow script after design/library setup.
#
# All tunables are collected at the top. Adjust for your PDK/design before
# running. Written to be technology-agnostic (works for sky130, asap7,
# gf180, or a commercial PDK) as long as the variables below are correct.
###############################################################################

###############################################################################
# 1. DESIGN / LIBRARY SETUP
###############################################################################
# ---- Edit these paths for your project -------------------------------------
set DESIGN_NAME     "top"
set NETLIST_V        "./results/synth/${DESIGN_NAME}.v"
set LIB_FILES        [glob ./platform/lib/*.lib]
set LEF_TECH         "./platform/lef/tech.lef"
set LEF_CELLS        [glob ./platform/lef/*_stdcell.lef]
set LEF_MACROS       [glob -nocomplain ./platform/lef/macros/*.lef]
set SDC_FILE         "./constraints/${DESIGN_NAME}.sdc"

# ---- Read technology + cell LEFs --------------------------------------------
read_lef $LEF_TECH
foreach lef $LEF_CELLS  { read_lef $lef }
foreach lef $LEF_MACROS { read_lef $lef }

# ---- Read liberty (needed for gate sizes / pin cap during downstream steps) -
foreach lib $LIB_FILES { read_liberty $lib }

# ---- Read gate-level netlist and link ---------------------------------------
read_verilog $NETLIST_V
link_design $DESIGN_NAME

# ---- Timing constraints (needed later for pin timing-driven placement) ------
if {[file exists $SDC_FILE]} {
    read_sdc $SDC_FILE
}

###############################################################################
# 2. FLOORPLAN GEOMETRY
###############################################################################
# Two supported modes:
#   MODE = "UTIL"    -> size die/core from target utilization + aspect ratio
#   MODE = "EXPLICIT" -> hard-code die/core coordinates (microns)
set FP_MODE         "UTIL"

# --- Mode: UTIL ---------------------------------------------------------------
set TARGET_UTIL      0.45   ;# 0.35-0.55 is a safe starting range pre-CTS/PDN
set ASPECT_RATIO      1.0   ;# height / width, 1.0 = square
set CORE_MARGIN        10   ;# um, spacing from core ring to die edge (all sides)

# --- Mode: EXPLICIT -------------------------------------------------------
set DIE_LX    0
set DIE_LY    0
set DIE_UX    1200
set DIE_UY    1200
set CORE_LX   10
set CORE_LY   10
set CORE_UX   1190
set CORE_UY   1190

# --- Site name from your tech LEF (check with `read_lef` output or PDK docs)
set SITE_NAME "unithd"

if {$FP_MODE == "UTIL"} {
    # initialize_floorplan can compute die/core directly from utilization,
    # aspect ratio, and margins -- this avoids hand math and rounding errors.
    initialize_floorplan \
        -utilization   $TARGET_UTIL \
        -aspect_ratio  $ASPECT_RATIO \
        -core_space    $CORE_MARGIN \
        -site          $SITE_NAME
} else {
    initialize_floorplan \
        -die_area  "$DIE_LX $DIE_LY $DIE_UX $DIE_UY" \
        -core_area "$CORE_LX $CORE_LY $CORE_UX $CORE_UY" \
        -site      $SITE_NAME
}

# ---- Row / site tracks -------------------------------------------------------
# Track pitches are normally pulled from the tech LEF automatically via
# make_tracks; pass no args to use LEF-defined pitch/offset for every layer.
make_tracks

puts "\[INFO\] Floorplan initialized:"
puts "        Die area  : [ord::get_die_area]"
puts "        Core area : [ord::get_core_area]"

###############################################################################
# 3. MACRO PLACEMENT (skip cleanly if design is macro-free)
###############################################################################
set macro_insts [get_cells -filter "is_block == true"]
if {[llength $macro_insts] > 0} {
    puts "\[INFO\] [llength $macro_insts] macro(s) found -- running macro placement."

    # Halo keeps standard cells / routing off the macro boundary.
    set MACRO_HALO_X  5.0
    set MACRO_HALO_Y  5.0
    # Channel width for macro-to-macro spacing (routing channel).
    set MACRO_CHANNEL 10.0

    rtl_macro_placer \
        -halo_width  $MACRO_HALO_X \
        -halo_height $MACRO_HALO_Y \
        -channel_width $MACRO_CHANNEL \
        -channel_height $MACRO_CHANNEL

    # Optional: pin down macro orientation/placement blockages manually
    # instead of/in addition to the automatic placer, e.g.:
    # set_placement_padding -masters "SRAM_32K" -left 2 -right 2
} else {
    puts "\[INFO\] No macros in design -- skipping macro placement stage."
}

###############################################################################
# 4. PLACEMENT BLOCKAGES (keepout regions, optional)
###############################################################################
# Example: reserve a region for later hard-macro insertion, PLL keepout, etc.
# set_placement_blockage -region "100 100 200 300"

###############################################################################
# 5. I/O PIN PLANNING
###############################################################################
# Strategy: hand-place a small set of critical/differential/analog pins first
# (clock, reset, high-fanout control, JTAG), then let the automatic placer
# fill in the rest with even spacing and layer/side rules.

# ---- 5a. Pin layers ----------------------------------------------------------
# Horizontal pins go on a horizontal metal layer, vertical pins on a vertical
# metal layer. Check your tech LEF for which metals run which direction.
set PIN_LAYER_HOR   "metal4"
set PIN_LAYER_VER   "metal5"

set_io_pin_constraint -layer $PIN_LAYER_HOR -pin_names "*"  ;# placeholder no-op guard, see below

# ---- 5b. Manually-placed critical pins ---------------------------------------
# Fixed positions avoid clock skew surprises and keep known-good pin locations
# stable across ECOs. Coordinates are absolute, in microns, on the die boundary.

# Clock pin -- place centered on the top edge for a balanced H-tree/CTS start.
place_pin -pin_name "clk"      -layer $PIN_LAYER_VER -location {595 1200} -pin_size {2 2}

# Async reset -- place near clock for short, controlled skew to reset tree.
place_pin -pin_name "rst_n"    -layer $PIN_LAYER_VER -location {605 1200} -pin_size {2 2}

# Example bus kept together on the left edge, evenly spaced, in bit order --
# useful for datapath-heavy busses where physical adjacency matches logical
# adjacency (helps timing and reduces routing congestion).
set data_bus_width 32
set bus_y_start    100
set bus_y_pitch     8
for {set i 0} {$i < $data_bus_width} {incr i} {
    place_pin -pin_name "data_in\[$i\]" \
        -layer $PIN_LAYER_HOR \
        -location "0 [expr {$bus_y_start + $i * $bus_y_pitch}]" \
        -pin_size {2 2}
}

# ---- 5c. Side/order constraints for groups of pins (let placer optimize
#          position within the constraint) --------------------------------
# Keep all SPI signals together on the right edge, in the order listed --
# improves routability to an adjacent SPI macro/pad.
set_io_pin_constraint -pin_names "spi_sclk spi_mosi spi_miso spi_cs_n" \
    -region "right:*"

# Group all JTAG signals on the bottom edge.
set_io_pin_constraint -pin_names "tck tms tdi tdo trst_n" \
    -region "bottom:*"

# ---- 5d. Automatic placement for everything else -----------------------------
# place_pins handles all pins not already fixed by place_pin, respecting the
# constraints set above, spacing pins evenly and avoiding overlap/DRC.
place_pins \
    -hor_layers $PIN_LAYER_HOR \
    -ver_layers $PIN_LAYER_VER \
    -min_distance 2.0 \
    -corner_avoidance 5.0 \
    -random false

###############################################################################
# 6. VERIFICATION
###############################################################################
puts "\[INFO\] Verifying pin placement..."
set unplaced_pins [get_ports -filter "placement_status == none"]
if {[llength $unplaced_pins] > 0} {
    puts "\[WARN\] [llength $unplaced_pins] pin(s) left unplaced:"
    foreach p $unplaced_pins { puts "        $p" }
} else {
    puts "\[INFO\] All pins placed successfully."
}

check_placement -verbose

###############################################################################
# 7. WRITE OUT RESULTS
###############################################################################
set OUT_DIR "./results/floorplan"
file mkdir $OUT_DIR

write_def   "${OUT_DIR}/${DESIGN_NAME}_floorplan.def"
write_db    "${OUT_DIR}/${DESIGN_NAME}_floorplan.odb"

puts "\[INFO\] Floorplan + pin planning complete."
puts "        DEF: ${OUT_DIR}/${DESIGN_NAME}_floorplan.def"
puts "        ODB: ${OUT_DIR}/${DESIGN_NAME}_floorplan.odb"

###############################################################################
# NOTES
###############################################################################
# - Run tapcell/endcap insertion and PDN generation as the next stage, before
#   global placement, e.g.:
#     source tapcell.tcl
#     source pdn.tcl
# - If pin locations must match a package/bump map (flip-chip or wire-bond
#   die), replace section 5 with coordinates read from that map instead of
#   place_pins' automatic distribution.
# - Re-run with FP_MODE = "EXPLICIT" once you have a fixed die size from a
#   package/foundry constraint, rather than deriving it from utilization.
###############################################################################
