if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi


sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:~/logs ./
