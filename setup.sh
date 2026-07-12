export PROJ_ROOT=$(pwd)
export SIM_DIR=$PROJ_ROOT/sim

export RTL_DIR=$PROJ_ROOT/rtl
export TB_DIR=$PROJ_ROOT/tb
export SCRIPTS_DIR=$PROJ_ROOT/scripts
export SIM_DIR=$PROJ_ROOT/sim

#Set script_dir as a new path, prevent faulty matches
if [[ ":$PATH:" != *":$SCRIPTS_DIR:"* ]]; then
    export PATH=$SCRIPTS_DIR:$PATH
fi

#root is the root directory of the project
alias goroot="cd $PROJ_ROOT"
alias gosim="cd $SIM_DIR"
alias gortl="cd $RTL_DIR"

echo "===================================================="
echo "  IC design environment setup successful"
echo "  Present root directory: $PROJ_ROOT"
echo "  Input 'goroot' to go to the root directory"
echo "  Input 'gosim'  to go to the simulation directory"
echo "===================================================="