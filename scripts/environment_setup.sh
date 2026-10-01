# DESIGN NAME   : alu_4bit
# STAGE         : Environment Setup
# LAST UPDATED  : 2026-09-06 00:29:43
# VERSION       : build_v1.1
# DESIGNER      : Mamunar Rahoman

#!/bin/bash
echo "Executing environment.sh file"

# Required File/Directory to run the project flow
#cp -rf /home/mamun/openroad/OpenROAD-flow-scripts/flow/platforms .
#cp -rf /home/mamun/openroad/OpenROAD-flow-scripts/flow/util .
#cp -rf /home/mamun/openroad/eqy/oss-cad-suite .

# To replace the DESIGN NAME according to current project
#find "$(pwd)" -type f -exec sed -i "0,/DESIGN NAME   :.*/s//DESIGN NAME   : $DESIGN_NM/" {} +

# To replace the LAST UPDATE date
#find "$(pwd)" -type f -exec sed -i "0,/LAST UPDATED  :.*/s//LAST UPDATED  : $(date '+%Y-%m-%d %H:%M:%S')/" {} +

# To replace the Designer Name | To keep a watermark of Designer
#find "$(pwd)" -type f -exec sed -i "0,/DESIGNER      :.*/s//DESIGNER      : $DESIGNER_NAME/" {} +

# To replace the DESIGN NAME according to current project
#find "$(pwd)" -type f -exec sed -i \
#"0,/^# DESIGN NAME[[:space:]]*:.*/s//\# DESIGN NAME   : $DESIGN_NM/" {} +

# To replace the LAST UPDATE date
#find "$(pwd)" -type f -exec sed -i \
#"0,/^# LAST UPDATED[[:space:]]*:.*/s//\# LAST UPDATED  : $(date '+%Y-%m-%d %H:%M:%S')/" {} +

# To replace the Designer Name | To keep a watermark of Designer
#find "$(pwd)" -type f -exec sed -i \
#"0,/^# DESIGNER[[:space:]]*:.*/s//\# DESIGNER      : $DESIGNER_NAME/" {} +

# To replace the build version | To keep a watermark of design build version
#find "$(pwd)" -type f -exec sed -i \
#"0,/^# VERSION[[:space:]]*:.*/s//\# VERSION       : $BUILD_VERSION/" {} +

# To convert the variables.mk into TCL variables
awk '
{
    # Skip comments and blank lines
    if ($0 ~ /^[[:space:]]*#/ || $0 ~ /^[[:space:]]*$/)
        next

    line = $0

    # Remove export
    sub(/^[[:space:]]*export[[:space:]]+/, "", line)

    # Check for multiline variable
    if (line ~ /\\[[:space:]]*$/) {

        # Extract variable name and first value
        sub(/[[:space:]]*\\[[:space:]]*$/, "", line)
        split(line, a, /[[:space:]]*:?=[[:space:]]*/)
        
        var = a[1]
        value = a[2]

        print "set " var " {"
        print "    " value

        # Read continuation lines
        while (getline line > 0) {

            sub(/^[[:space:]]+/, "", line)

            if (line ~ /\\[[:space:]]*$/) {
                sub(/[[:space:]]*\\[[:space:]]*$/, "", line)
                print "    " line
            }
            else {
                print "    " line
                print "}"
                break
            }
        }

        next
    }

    # Normal variable
    split(line, a, /[[:space:]]*:?=[[:space:]]*/)
    var = a[1]
    value = a[2]

    # Convert $(VAR) -> ${VAR}
    while (match(value, /\$\([A-Za-z_][A-Za-z0-9_]*\)/)) {
        old = substr(value, RSTART, RLENGTH)
        name = substr(old, 3, RLENGTH - 3)

        value = substr(value, 1, RSTART - 1) \
                "${" name "}" \
                substr(value, RSTART + RLENGTH)
    }

    print "set " var " \"" value "\""
}
' design_setup.mk > scripts/tcl_variables.tcl
