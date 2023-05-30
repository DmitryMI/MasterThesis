if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ -z "$JOB_ID" ]
then
    JOB_ID=37304793
fi

sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:~/logs/run_drones_veins_project-$JOB_ID.out ./logs/


sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:~/logs/run_drones_veins_project-$JOB_ID.err ./logs/
