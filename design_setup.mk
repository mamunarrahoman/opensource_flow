# DESIGN NAME   : alu_4bit
# STAGE		: Design Variables
# LAST UPDATED  : 2026-09-06 00:29:43
# VERSION       : build_v1.1
# DESIGNER      : Mamunar Rahoman

#-----------------------------------------------------------------------------------------------#
#  ____  _____ ____ ___ ____ _   _    __     ___    ____  ___    _    ____  _     _____  	#
# |  _ \| ____/ ___|_ _/ ___| \ | |   \ \   / / \  |  _ \|_ _|  / \  | __ )| |   | ____| 	#
# | | | |  _| \___ \| | |  _|  \| |    \ \ / / _ \ | |_) || |  / _ \ |  _ \| |   |  _|   	#
# | |_| | |___ ___) | | |_| | |\  |     \ V / ___ \|  _ < | | / ___ \| |_) | |___| |___  	#
# |____/|_____|____/___\____|_| \_|      \_/_/   \_\_| \_\___/_/   \_\____/|_____|_____| 	#
#                                                                                               #
#-----------------------------------------------------------------------------------------------#

# ENVIRONMENT NEEDED VARIABLES -----
export DESIGN_NM := alu_4bit
export DESIGN_VERILOG := inputs/$(DESIGN_NM).v
export LIB_PATH := platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib

export LEF_PATH := platforms/nangate45/lef/NangateOpenCellLibrary.tech.lef \
		   platforms/nangate45/lef/NangateOpenCellLibrary.macro.lef \
		   platforms/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef \
		   platforms/nangate45/lef/NangateOpenCellLibrary.macro.rect.lef

export DESIGN_SDC := inputs/$(DESIGN_NM)_abc.constr

export SYN_DIR := synthesis
export DESIGN_DIR := design
export LOG_DIR := log
export SCRIPTS_DIR := scripts

export SYN_SDC := synthesis/$(DESIGN_NM).sdc
export SYN_VERILOG := synthesis/$(DESIGN_NM)_mapped.v
export ABC_CONSTR := inputs/$(DESIGN_NM)_input.sdc

# FLOORPLAN RELATED VARIABLES -----
export FP_MODE := UTIL

# LESS IMPORTANT VARIABLES
export DESIGNER_NAME := Mamunar Rahoman
export BUILD_VERSION := build_v1.1
