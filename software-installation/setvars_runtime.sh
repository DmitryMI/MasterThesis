#!/bin/bash

INSTALLATION_DIR="/Software"

if [[ -z "$INSTALLATION_DIR_SUMO" ]]
then
    INSTALLATION_DIR_SUMO="$INSTALLATION_DIR"
fi
if [[ -z "$INSTALLATION_DIR_OMNETPP" ]]
then
    INSTALLATION_DIR_OMNETPP="$INSTALLATION_DIR"
fi

DOWNLOADS_DIR="/Downloads"
SLEEP_SEC=0
RUNTIME_ONLY=1

SETVARS_GUARD=1
