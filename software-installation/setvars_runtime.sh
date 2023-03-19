#!/bin/bash

INSTALLATION_DIR="/Software"

if [[ -z "$INSTALLATION_DIR_SUMO" ]]
then
    INSTALLATION_DIR_SUMO="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_SUMO no set. Setting to default $INSTALLATION_DIR_SUMO"
fi
if [[ -z "$INSTALLATION_DIR_OMNETPP" ]]
then
    INSTALLATION_DIR_OMNETPP="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_OMNETPP no set. Setting to default $INSTALLATION_DIR_OMNETPP"
fi

DOWNLOADS_DIR="/Downloads"
SLEEP_SEC=0
RUNTIME_ONLY=1

SETVARS_GUARD=1
