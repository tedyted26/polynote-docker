#!/bin/bash

function exit_err {
    printf "%s\n" "$1" >&2
    exit 1
}

while getopts ":i:c:n:" option; do
    case "$option" in
        i) INITIALIZATION="$OPTARG" ;;
        c) CONFIGURATION="$OPTARG" ;;
        :) exit_err "Missing argument for -$OPTARG" ;;
        *) exit_err "Invalid option -$OPTARG" ;;
    esac
done

if [[ -f "$INITIALIZATION" ]]; then
    printf "\n======================\n"
    printf "Running Initialization\n"
    printf "======================\n\n"
    case "$INITIALIZATION" in
        *.sh)
            bash "$INITIALIZATION" || exit_err "Failed to execute script $INITIALIZATION"
            ;;
        *)
            exit_err "File format not correct. Initialization must be specified in a *.txt, *.yml/yaml, or *.sh file."
            ;;
    esac
fi  

if [[ -f "$CONFIGURATION" ]]; then
    printf "\n======================\n"
    printf "Adding Configuration\n"
    printf "======================\n\n"
    case "$CONFIGURATION" in
        *.yml)
            # Copy provided configuration into installation directory.
            # Configuration file must have the following lines (identations are important):
            # listen:
            #  host: 0.0.0.0
            #  port: 8192
            cp "$CONFIGURATION" /opt/polynote/config.yml || exit_err "Failed to add configuration from $CONFIGURATION"
            
            ;;
        *)
            exit_err "File format not correct. Configuration must be specified in a *.yml file."
            ;;
    esac
fi 

# Launch Polynote
printf "\n======================\n"
printf "Setting up Polynote\n"
printf "======================\n\n"

mamba init bash \
 && source ~/.bashrc \
 && mamba activate /opt/conda/envs/poly \
 && python3 /opt/polynote/polynote.py

sleep infinity