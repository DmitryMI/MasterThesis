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

if [ -z "$INSTALLATION_DIR_RUNMAKER" ]
then
    INSTALLATION_DIR_RUNMAKER="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_RUNMAKER not set. Setting to default $INSTALLATION_DIR_RUNMAKER"
else
    echo "Runmaker will be installed to $INSTALLATION_DIR_RUNMAKER"
fi

if [ -z "$INSTALLATION_DIR_VEINS" ]
then
    INSTALLATION_DIR_VEINS="$INSTALLATION_DIR"
    echo "INSTALLATION_DIR_VEINS not set. Setting to default $INSTALLATION_DIR_VEINS"
else
    echo "Veins will be installed to $INSTALLATION_DIR_VEINS"
fi

if [ -z "$DOWNLOADS_DIR" ]
then
    DOWNLOADS_DIR="/home/$(whoami)/Downloads"
    echo "DOWNLOADS_DIR not set. Setting to default $DOWNLOADS_DIR"
else
    echo "Downloads directory set to $INSTALLATION_DIR_OMNETPP"
fi

if [ -z "$RUNTIME_ONLY" ]
then
    RUNTIME_ONLY=0
    echo "RUNTIME_ONLY not set. Setting to default $RUNTIME_ONLY"
else
    echo "RUNTIME_ONLY set to $RUNTIME_ONLY"
fi

SETVARS_GLOBAL_GUARD=1

source ./stats/setvars.sh
source ./hpc/setvars.sh

SETVARS_GUARD=1
