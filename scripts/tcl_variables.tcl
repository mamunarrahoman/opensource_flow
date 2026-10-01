set DESIGN_NM "alu_4bit"
set DESIGN_VERILOG "inputs/${DESIGN_NM}.v"
set LIB_PATH "platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib"
set LEF_PATH {
    platforms/nangate45/lef/NangateOpenCellLibrary.tech.lef
    platforms/nangate45/lef/NangateOpenCellLibrary.macro.lef
    platforms/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef
    platforms/nangate45/lef/NangateOpenCellLibrary.macro.rect.lef
}
set DESIGN_SDC "inputs/${DESIGN_NM}_abc.constr"
set SYN_DIR "synthesis"
set DESIGN_DIR "design"
set LOG_DIR "log"
set SCRIPTS_DIR "scripts"
set SYN_SDC "synthesis/${DESIGN_NM}.sdc"
set SYN_VERILOG "synthesis/${DESIGN_NM}_mapped.v"
set ABC_CONSTR "inputs/${DESIGN_NM}_input.sdc"
set FP_MODE "UTIL"
set DESIGNER_NAME "Mamunar Rahoman"
set BUILD_VERSION "build_v1.1"
