#!/bin/bash

function exit_err {
    printf "%s\n" "$1" >&2
    exit 1
}

while getopts ":i:c:n:" option; do
    case "$option" in
        i) INITIALIZATION="$OPTARG" ;;
        c) CONFIGURATION="$OPTARG" ;;
        # Notebook folder. By default /work/notebooks, but user can specify.
        # This is different from "Select folders to use", 
        # since it changes the configuration file so Polynote can detect the folder and show it in the interface
        n) NB_DIR="$OPTARG" ;;
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
        # The if can be removed.
            if grep -q -E '^listen:\s*$' config.yml && \
               grep -q -E '^\s+host:\s+0\.0\.0\.0\s*$' config.yml && \
               grep -q -E '^\s+port:\s+8192\s*$' config.yml; then
                cp "$CONFIGURATION" /opt/polynote/config.yml || exit_err "Failed to add configuration from $CONFIGURATION"
            else
                echo "Host or port listen configuration is not correctly set."
            fi
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
python3 /opt/polynote/polynote.py

sleep infinity