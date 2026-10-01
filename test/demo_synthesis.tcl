# ==============================================================
# Synthesising designs for hardware:
#                      A guided tour of the synth_ice40 command
#                   ~~~~~~~~~~~~~~~~~~~~~~~

# Presented by Krystine Dawn

# What is synthesis?
# - HDL input (verilog)
# - mapping design logic onto hardware elements
# - platform specific output (json for nextpnr)

# What is synth_ice40?
# - synthesis command for the iCE40 platform
# - most FPGA synth scripts use the same passes
# $ yosys -p "help synth_ice40"
# > help synth_ice40
# https://yosys.readthedocs.io/en/latest/cmd/synth_ice40.html

# Demo design:
# - available in Yosys source repo:
# $ cd docs/source/code_examples/fifo
# - simple FIFO ring buffer
# - parametrizable memory size

# Today's goal:
# $ yosys -p "synth_ice40 -top fifo -json fifo.json" fifo.v
# - step through iCE40 FPGA synthesis script
# - see how design changes for hardware
# - look at common passes used in synthesis

# ==============================================================
# Loading the design
# - opening a Yosys shell prompt:
# $ yosys

read_verilog fifo.v

# ==============================================================
# Elaboration
# > synth_ice40 -top fifo -run begin:flatten

# - load iCE40 cell models for IP blocks, e.g. PLLs
read_verilog -D ICE40_HX -lib -specify +/ice40/cells_sim.v
# - always run hierarchy first
hierarchy -check -top fifo
# - convert processes into cells
proc
stat
design -save proc
design -load proc

# show: addr_gen
# pink: simple operations
# blue: process logic
# - clean for show command
# - restore after
clean
select -set show $*addr_gen*
select -set pink t:$mux t:*dff
select -set blue t:$add t:$eq
show -color maroon3 @pink -color cornflowerblue @blue @show
design -load proc

# show: input cone for fifo.rdata output pin
# pink: instance of addr_gen
# blue: generic (asynchronous) memory read
select -set show o:rdata %ci*
select -set pink c:fifo_reader
select -set blue t:$memrd
show -color maroon3 @pink -color cornflowerblue @blue @show

# ==============================================================
# Flattening
# > synth_ice40 -top fifo -run flatten:coarse

flatten
tribuf -logic
deminout
design -save flatten
design -load flatten

# show: input cone for fifo.rdata output pin
# pink: contents of addr_gen
# - clean for show command
clean
select -set show o:rdata %ci*
select -set pink w:fifo_reader.* %ci* i:* %d
show -color maroon3 @pink @show
design -load flatten

# ==============================================================
# The coarse-grain representation
# > synth_ice40 -top fifo -run coarse:map_ram

# - cleaning
opt_expr
opt_clean
check
# - inferring fsms
opt -nodffe -nosdff
fsm
# - optimizations
opt
design -save fsm
design -load fsm

# show: input cone for fifo.rdata output pin
# pink: change from opt_dff
select -set show o:rdata %ci*
select -set pink t:$adffe
show -color maroon3 @pink @show

# - operator width reduction
wreduce
# - more optimizations
peepopt
opt_clean
share
# - convert comparison operators to luts
techmap -map +/cmp2lut.v -D LUT_WIDTH=4
opt_expr
opt_clean
# - merge input/output DFFs into memory read ports
memory_dff
design -save memory_dff
design -load memory_dff

# DSP optimizations (skipped)
# > wreduce t:$mul
# > techmap -map +/mul2dsp.v -map +/ice40/dsp_map.v -D DSP_A_MAXWIDTH=16 -D DSP_B_MAXWIDTH=16 -D DSP_A_MINWIDTH=2 -D DSP_B_MINWIDTH=2 -D DSP_Y_MINWIDTH=11 -D DSP_NAME=$__MUL16X16    (if -dsp)
# > select a:mul2dsp                  (if -dsp)
# > setattr -unset mul2dsp            (if -dsp)
# > opt_expr -fine                    (if -dsp)
# > wreduce                           (if -dsp)
# > select -clear                     (if -dsp)
# > ice40_dsp                         (if -dsp)
# > chtype -set $mul t:$__soft_mul    (if -dsp)

# - combine arithmetic cells
alumacc
opt
design -save alumacc
design -load alumacc

# show: input cone for fifo.rdata output pin
# pink: arithmetic cell(s)
select -set show o:rdata %ci*
select -set pink t:$alu t:$macc
select -set blue t:$memrd_v2
show -color maroon3 @pink -color cornflowerblue @blue @show

# - combine abstract memory cells
memory -nomap
opt_clean
stat
design -save coarse
design -load coarse

# show: input cone for fifo.rdata output pin
# (ignoring memory write ports)
# pink: memory cell
select -set show o:rdata %ci*:-$mem_v2[WR_DATA,WR_ADDR,WR_EN]
select -set pink t:$mem_v2
show -color maroon3 @pink @show

# ==============================================================
# Mapping memory blocks
# > synth_ice40 -top fifo -run map_ram:map_gates

# map_ram
# - map generic memory into hardware block(s)
memory_libmap -lib +/ice40/brams.txt -lib +/ice40/spram.txt -no-auto-huge
techmap -map +/ice40/brams_map.v -map +/ice40/spram_map.v
ice40_braminit
stat
design -save map_ram
design -load map_ram

# show: input cone for fifo.rdata output pin
# (ignoring memory write ports and read-before-write logic)
# pink: memory cell with swizzled inputs/outputs and
#       read-before-write logic
# blue: fifo_reader.addr == MAX_DATA-1 feedback path
select -set mem_read t:SB_RAM40_4K %ci*:-SB_RAM40_4K[WCLKE,WDATA,WADDR,WE]
select -set mem_out t:SB_RAM40_4K %co*
select -set show @mem_read @mem_out %%
select -set pink t:SB_RAM40_4K %ci:+[RADDR] %co4
select -set blue w:fifo_reader.addr %c %ci5 %D t:$alu %co %d i:* %d
show -color maroon3 @pink -color cornflowerblue @blue @show

# map_ffram
# - map any leftover memory to flip flops
opt -fast -mux_undef -undriven -fine
memory_map
opt -undriven -fine
stat
design -save map_ffram
design -load map_ffram

# ==============================================================
# Mapping arithmetic
# > synth_ice40 -top fifo -run map_gates:map_ffs

# - convert arithmetic to gate-level primitives
# - each multi-bit cell explodes into many single-bit cells
# - $alu logic in iCE40 get special carry wrapper
ice40_wrapcarry
techmap -map +/techmap.v -map +/ice40/arith_map.v
opt -fast
ice40_opt
stat
design -save map_gates
design -load map_gates

# show: fifo_reader.addr[3] feedback path
# - temporarily split up fifo_reader.addr
splitnets
opt_clean -purge
# pink: address register
# blue: eq cell
select w:fifo_reader.addr[3]
select -set show % %co:+$_NOT_ % %d %co7 % %ci5 %%
select -set pink t:$_DFF*
select -set blue t:$_*O*
show -color maroon3 @pink -color cornflowerblue @blue @show
design -load map_gates

# ==============================================================
# Mapping flip-flops
# > synth_ice40 -top fifo -run map_ffs:map_luts

# - convert FFs to hardware supported types
dfflegalize -cell $_DFF_?_ 0 -cell $_DFFE_?P_ 0 -cell $_DFF_?P?_ 0 -cell $_DFFE_?P?P_ 0 -cell $_SDFF_?P?_ 0 -cell $_SDFFCE_?P?P_ 0 -cell $_DLATCH_?_ x -mince -1
# - map FFs to hardware
techmap -map +/ice40/ff_map.v
opt_expr -mux_undef
# - convert remaining cells to gate-level primitives
simplemap
debug ice40_opt -full
stat
design -save map_ffs
design -load map_ffs

# show: fifo_reader.addr[3] feedback path
# - temporarily split up fifo_reader.addr
splitnets
opt_clean -purge
# pink: address register
# blue: mux cell
select w:fifo_reader.addr[3]
select -set show % %co:+$_NOT_ % %d %co7 % %ci5 %%
select -set pink t:SB_DFFER
select -set blue t:$_AND_
show -color maroon3 @pink -color cornflowerblue @blue @show
design -load map_ffs

# ==============================================================
# Mapping LUTs
# > synth_ice40 -top fifo -run map_luts:check

# map_luts
# - convert gate-level primitives to $lut cells
techmap -map +/ice40/latches_map.v
read_verilog -D ICE40_HX -icells -lib -specify +/ice40/abc9_model.v
abc9 -W 250
# - unwrap carries to $lut and SB_CARRY cells
ice40_wrapcarry -unwrap
techmap -map +/ice40/ff_map.v
clean
opt_lut -tech ice40
stat
design -save map_luts
design -load map_luts

# show: memory read address feedback path
# - use %R for a random bit of addr
select t:SB_RAM40_4K %ci2:-SB_RAM40_4K[WCLKE,WDATA,WADDR,WE] t:SB_DFFER %i %R
show % %ci3 % %co3 %i
select -clear

# map_cells
# - map generic $lut into hardware
techmap -map +/ice40/cells_map.v
clean
stat
design -save map_cells
design -load map_cells

# show: memory read address feedback path
select t:SB_RAM40_4K %ci2:-SB_RAM40_4K[WCLKE,WDATA,WADDR,WE] t:SB_DFFER %i %R
show % %ci3 % %co3 %i
select -clear

# ==============================================================
# Final steps
# > synth_ice40 -top fifo -run check:

autoname
hierarchy -check
stat
check -noinit
blackbox =A:whitebox

# outputs
# > synth_ice40 -top fifo -json fifo.json
write_json fifo.json
