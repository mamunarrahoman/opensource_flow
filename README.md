# 4-bit ALU ASIC Open-Source RTL-to-GDSII Flow

This repository contains an automated, Makefile-driven ASIC physical design flow for a **4-bit Arithmetic Logic Unit (`alu_4bit`)** utilizing open-source EDA tools (`Yosys`, `OpenROAD`).

## Design Metadata

* **Design Name:** `alu_4bit`
* **Version:** `build_v1.1`
* **Designer:** Mamunar Rahoman
* **Synthesis Tool:** Yosys
* **Physical Design / Verification Tools:** OpenROAD & Docker-wrapped environments

---

## ASIC Design Flow Stages

The flow is managed via a comprehensive `Makefile` that reads configuration variables from `design_setup.mk` and tracks execution progress using pass/fail log markers.

| Stage | Target Name | Tool / Utility | Description |
| :--- | :--- | :--- | :--- |
| **1. Setup** | `setup` | Bash script / Environment | Initializes required directories (`$(DESIGN_DIR)`, `$(SYN_DIR)`, `$(LOG_DIR)`) and checks environmental dependencies. |
| **2. Synthesis** | `syn` | Yosys | Converts RTL descriptions into a mapped gate-level netlist (`*_mapped.v`) and logs reports. |
| **3. Logic Equivalence** | `logic_equiv` | Yosys (Equiv check) | Verifies functional equivalence between the pre-synthesis RTL and the post-synthesis netlist. |
| **4. Floorplan** | `floorplan` | OpenROAD (via Docker) | Executes initial floorplanning steps within containerized open-source environments. |

---

## Directory Structure

```text
.
├── Makefile
├── design_setup.mk
├── scripts/
│   ├── environment_setup.sh
│   ├── synthesis.ys
│   ├── equiv.ys
│   └── tcl_variables.tcl
├── util/
│   └── docker_shell
└── log/
    └── *.log, *.pass, & *.fail (Generated during execution)
```

---

## How to Run

You can execute the entire flow or trigger individual stages using `make`.

### Run the Full Flow
To run environment setup, synthesis, and logic equivalence checks sequentially:
```bash
make all
```

### Run Individual Stages
You can also target specific milestones independently:
```bash
# Setup the workspace environment
make setup

# Run logical synthesis
make syn

# Run formal logic equivalence checking
make logic_equiv

# Run floorplanning inside Docker
make floorplan
```

### Cleaning Up
Cleanup targets are provided to clear logs, temporary files, or specific build stages selectively:
```bash
# Clean specific modules
make clean_setup
make clean_syn
make clean_logic
make clean_floorplan

# Clean the entire workspace history
make clean_all
