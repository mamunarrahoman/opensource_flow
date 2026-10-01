# DESIGN NAME   : alu_4bit
# STAGE         : Floorplan
# LAST UPDATED  : 2026-09-06 00:29:43
# VERSION       : build_v1.1
# Tool          : Openroad
# DESIGNER      : Mamunar Rahoman

#---------------------------------------------------------------#
#  _____ _     ___   ___  ____  ____  _        _    _   _       #
# |  ___| |   / _ \ / _ \|  _ \|  _ \| |      / \  | \ | |      #
# | |_  | |  | | | | | | | |_) | |_) | |     / _ \ |  \| |      #
# |  _| | |__| |_| | |_| |  _ <|  __/| |___ / ___ \| |\  |      #
# |_|   |_____\___/ \___/|_| \_\_|   |_____/_/   \_\_| \_|      #
#                                                               #
#---------------------------------------------------------------#

# Initiate all design related variables into openroad environment
source //work/scripts/tcl_variables.tcl

# Read tech LEF and cell LEF | PDK may contains morethan one LEF so it is safe to checek all.
foreach lef $LEF_PATH {
        read_lef //work/$lef
}

# Read LIB file for timing information | PDK may contains morethan one LIB so it is safe to checek all.
foreach lib $LIB_PATH {
        read_liberty //work/$lib
}

# Read Synthesized verilog that is going to be used throughout the flow
read_verilog //work/$SYN_VERILOG

# Link the design with tool
link_design $DESIGN_NM


# Link design constraints | Needed leter for timing driven placement or timing optimization
if {[file exists //work/$SYN_SDC]} {
        read_sdc //work/$SYN_SDC
}

# Floorplan Geometry | Set FP_MODE from design_variables.mk |  Two supported modes :
# MODE = "UTIL" -> size die/core from target utilization + aspect ratio
# MODE = "EXPLICIT" -> hard-code die/core coordinates (microns)

# MODE = UTIL
set TARGET_UTIL 0.45    ;# 0.35-0.55 is a safe starting range pre-CTS/PDN
set ASPECT_RATIO 1.0    ;# height / width, 1.0 = square
set CORE_MARGIN 5      ;# um, spacing from core ring to die edge (all sides)

# MODE = EXPLICIT
set DIE_LX    0
set DIE_LY    0
set DIE_UX    1200
set DIE_UY    1200
set CORE_LX   10
set CORE_LY   10
set CORE_UX   1190
set CORE_UY   1190

# Site name fromtech LEF (check with `read_lef` output or PDK docs)
set SITE_NAME "FreePDK45_38x28_10R_NP_162NW_34O"

# Initiate Floorplan
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

# Row / site tracks | Track pitches are normally pulled from the tech LEF automatically via make_tracks; pass no args to use LEF-defined pitch/offset for every layer.
make_tracks

# Pin Placement
source //work/scripts/pin_placement.tcl

# Check Pin Placement Verification
puts "\[INFO\] Verifying pin placement..."
set unplaced_pins [get_ports -filter "placement_status == none"]
if {[llength $unplaced_pins] > 0} {
    puts "\[WARN\] [llength $unplaced_pins] pin(s) left unplaced:"
    foreach p $unplaced_pins { puts "        $p" }
} else {
    puts "\[INFO\] All pins placed successfully."
}
