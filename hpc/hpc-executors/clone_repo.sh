if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "../setvars.sh"
fi

if [ -d "$BEEGFS_CODEBASE_DIR/MasterThesis/.git" ]
then
    cd $BEEGFS_CODEBASE_DIR/MasterThesis
    echo "Repository already exists, pulling..."
    git pull
else
    echo "Cloning repository..."
    cd $BEEGFS_CODEBASE_DIR
    git clone https://DmitryMI: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@github.com/DmitryMI/MasterThesis
fi
