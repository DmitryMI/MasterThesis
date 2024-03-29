source ./run.jobfile.vars

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

echo "#!/bin/bash" > run.jobfile

echo "#SBATCH --ntasks=$NTASKS" >> run.jobfile
echo "#SBATCH --cpus-per-task=$CPUS_PER_TASK" >> run.jobfile 
echo "#SBATCH --partition=haswell" >> run.jobfile
echo "#SBATCH --mem-per-cpu=2048" >> run.jobfile
echo "#SBATCH --time=10:00:00" >> run.jobfile
echo "#SBATCH --job-name=run_drones_veins_project" >> run.jobfile
echo "#SBATCH --output=/home/dmmo937c/logs/run_drones_veins_project-%j.out" >> run.jobfile
echo "#SBATCH --error=/home/dmmo937c/logs/run_drones_veins_project-%j.err" >> run.jobfile
echo "#SBATCH --mail-type=all" >> run.jobfile
echo "#SBATCH --mail-user=dmitriy.monakhov@mailbox.tu-dresden.de" >> run.jobfile
if [ ! -z "$DEPENDENCY" ]
then
    # afterok:20
    echo "#SBATCH --dependency=afterok:$DEPENDENCY" >> run.jobfile
fi

# sin_app="/root/singularity-executors/singularity_run_project.sh -j$CPUS_PER_TASK"
sin_app="/root/scripts/hpc/singularity-executors/singularity_run_project.sh"

app="singularity exec -C --net --network none -H ~/:/root --bind $SCRATCH_WORKSPACE:$SINGULARITY_WORKSPACE_MNT:rw,$BEEGFS_WORKSPACE:$SINGULARITY_BEEGFS_MNT:rw ./ubuntu \"$sin_app\""

echo "srun --exclusive --ntasks=$NTASKS $app" >> run.jobfile

echo "# AUTOGENERATED FILE! DO NOT EDIT!" >> ./run.jobfile
