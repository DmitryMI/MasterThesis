#!/bin/bash

# Calls global setvars_hpc.sh

wd_backup=$(pwd)
cd ..
source setvars_hpc.sh
cd $wd_backup
