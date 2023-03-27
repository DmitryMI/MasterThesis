cd ~/scripts/hpc/hpc-executors
pwd

if [ -z "$HPC_SETVARS_GUARD" ]
then
    vars=$(realpath "../setvars.sh")
    if [ ! -f "$vars" ]
    then
        echo "$vars does not exist!"
        exit 1
    fi
    source $vars
fi

if [ -d "$CODEBASE_DIR/MasterThesis/.git" ]
then
    cd $CODEBASE_DIR/MasterThesis
    echo "Repository already exists, pulling..."
    git pull
else
    echo "Cloning repository..."
    cd $CODEBASE_DIR
    git clone https://DmitryMI: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@github.com/DmitryMI/MasterThesis
fi
