if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi


sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:~/logs/run_drones_veins_project-37304109.out ./logs/


sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:~/logs/run_drones_veins_project-37304109.err ./logs/
