#!/bin/bash

INSTALLATION_DIR="/home/$(whoami)/Software"

if [ -z "$INSTALLATION_DIR_SUMO" ]
then
    INSTALLATION_DIR_SUMO="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_SUMO no set. Setting to default $INSTALLATION_DIR_SUMO"
else
    echo "SUMO will be installed to $INSTALLATION_DIR_SUMO"
fi

if [ -z "$INSTALLATION_DIR_OMNETPP" ]
then
    INSTALLATION_DIR_OMNETPP="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_OMNETPP no set. Setting to default $INSTALLATION_DIR_OMNETPP"
else
    echo "OMNeT++ will be installed to $INSTALLATION_DIR_OMNETPP"
fi

DOWNLOADS_DIR="/home/$(whoami)/Downloads"
SLEEP_SEC=2
RUNTIME_ONLY=0

SETVARS_GUARD=1
