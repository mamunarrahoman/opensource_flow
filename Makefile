# DESIGN NAME   : alu_4bit
# STAGE		: Makefile
# LAST UPDATED  : 2026-09-06 00:29:43
# VERSION       : build_v1.1
# DESIGNER      : Mamunar Rahoman

#---------------------------------------------------------------#
#  __  __    _    _  _  ______    _____  ___ _     _____	#
# |  \/  |  / \  | |/ / | ____|  |  ___||_ _| |   | ____|	#
# | |\/| | / _ \ | ' /  |  _|    | |_    | || |   |  _|		#
# | |  | |/ ___ \| . \  | |___   |  _|   | || |___| |___	#
# |_|  |_/_/   \_\_|\_\ |_____|  |_|    |___|_____|_____|	#
#								#
#---------------------------------------------------------------#


# VARIABLE SETUP -----
include design_setup.mk

.PHONY: all setup synthesis logic_equiv floorplan clean_setup clean_logic clean_floorplan clean_all

# MAKE ALL
all: setup syn logic_equiv

# DESIGN SETUP -----
setup: $(LOG_DIR)/environment_setup.pass
	@echo "Design Environment already up-to-date :- HAVE FUN ... "

$(LOG_DIR)/environment_setup.pass:
	@echo "Design Environment is setting up ... "
	@mkdir -p $(DESIGN_DIR) $(SYN_DIR) $(LOG_DIR)
	@bash $(SCRIPTS_DIR)/environment_setup.sh | tee $(LOG_DIR)/environment_setup.log
	@if ! grep -i "ERROR" $(LOG_DIR)/environment_setup.log > /dev/null; then \
		touch $(LOG_DIR)/environment_setup.pass; \
		echo "PASS" > $(LOG_DIR)/environment_setup.pass; \
		echo "Design Environment setup done :- CHILL ..."; \
	else \
		echo "Design Environment setup failed :- don't worry, you will figure it out ..."; \
		touch $(LOG_DIR)/environment_setup.fail; \
		grep -i "ERROR" $(LOG_DIR)/environment_setup.log > $(LOG_DIR)/environment_setup.fail \
		exit 1; \
	fi

# DESIGN ENVIRONMENT SETUP CLEAN
clean_setup:
	@echo "Design Environment is cleaning ..."
	@rm -rf $(DESIGN_DIR) $(SYN_DIR) $(LOG_DIR)
	@rm -f $(SCRIPTS_DIR)/tcl_variables.tcl
	@rm -f $(LOG_DIR)/environment_setup*
	@echo "Design Environment cleaning done ..."

# SYNTHESIS -----
syn: $(LOG_DIR)/synthesis.pass
	@echo "Synthesis already up-to-date :- HAVE FUN ... "
$(LOG_DIR)/synthesis.pass:
	@echo "Starting Synthesis Process"
	@yosys -c $(SCRIPTS_DIR)/synthesis.ys -l $(LOG_DIR)/synthesis.log
	@if ! grep -i "ERROR" $(LOG_DIR)/synthesis.log > /dev/null; then \
                touch $(LOG_DIR)/synthesis.pass; \
                echo "PASS" > $(LOG_DIR)/synthesis.pass; \
                echo "SYNTHESIS done :- CHILL ..."; \
        else \
                echo "SYNTHESIS failed :- don't worry, you will figure it out ..."; \
                touch $(LOG_DIR)/synthesis.fail; \
		grep -i "ERROR" $(LOG_DIR)/synthesis.log > $(LOG_DIR)/synthesis.fail \
                exit 1; \
        fi

# SYNTHESIS CLEAN
clean_syn:
	@echo "SYNTHESIS is cleaning ..."
	@rm -f $(SYN_DIR)/$(DESIGN_NM)_mapped.v
	@rm -f $(SYN_DIR)/$(DESIGN_NM)_mapped.dot
	@rm -f $(LOG_DIR)/synthesis*
	@echo "SYNTHESIS cleaning done ..."

# LOGIC EQUIVALENCY CHECK -----
logic_equiv: $(LOG_DIR)/logic_equiv.pass
	@echo "LOGIC EQUIVALENCE CHECK already up-to-date :- HAVE FUN ..."

$(LOG_DIR)/logic_equiv.pass:
	@echo "Starting Synthesis Process"
	@yosys -c $(SCRIPTS_DIR)/equiv.ys -l $(LOG_DIR)/logic_equiv.log || true
	@if ! grep -i "ERROR" $(LOG_DIR)/logic_equiv.log > /dev/null; then \
                touch $(LOG_DIR)/logic_equiv.pass; \
                echo "PASS" > $(LOG_DIR)/logic_equiv.pass; \
                echo "LOGIC EQUIVALENCE CHECK done :- CHILL ..."; \
        else \
                echo "SYNTHESIS failed :- don't worry, you will figure it out ..."; \
                touch $(LOG_DIR)/logic_equiv.fail; \
                grep -i "ERROR" $(LOG_DIR)/logic_equiv.log > $(LOG_DIR)/logic_equiv.fail \
                exit 1; \
        fi

# LOGIC EQUIVALENCY CHECK CLEAN
clean_logic:
	@echo "LOGIC EQUIVALENCE CHECK is cleaning ..."
	@rm -f $(LOG_DIR)/logic_equiv*
	@echo "LOGIC EQUIVALENCE CHECK cleaning done ..."

# FLOORPLAN -----
floorplan: $(LOG_DIR)/floorplan.pass
        @echo "FLOORPLAN already up-to-date :- HAVE FUN ..."

$(LOG_DIR)/floorplan.pass:
	@echo "Starting Floorplan Process"
	@util/docker_shell openroad
	@if ! grep -i "ERROR" $(LOG_DIR)/floorplan.log > /dev/null; then \
                touch $(LOG_DIR)/floorplan.pass; \
                echo "PASS" > $(LOG_DIR)/floorplan.pass; \
                echo "FLOORPLAN done :- CHILL ..."; \
        else \
                echo "FLOORPLAN failed :- don't worry, you will figure it out ..."; \
                touch $(LOG_DIR)/floorplan.fail; \
                grep -i "ERROR" $(LOG_DIR)/floorplan.log > $(LOG_DIR)/floorplan.fail \
                exit 1; \
        fi

# FLOORPLAN CLEAN
clean_floorplan:
	@echo "FLOORPLAN is cleaning ..."
	@rm -f $(LOG_DIR)/floorplan*
	@rm -f $(DESIGN_DIR)/floorplan.odb
	@echo "FLOORPLAN cleaning done ..."


# CLEAN ALL
clean_all: clean_setup clean_syn clean_logic
	@echo "CLEANED ALL ..."
