#!/bin/bash

function exit_err {
    printf "%s\n" "$1" >&2
    exit 1
}

while getopts ":d:i:c:h:e:xg:f:p:u:s:n:l:m:" option; do
    case "$option" in
        i) INITIALIZATION="$OPTARG" ;;
        :) exit_err "Missing argument for -$OPTARG" ;;
        *) exit_err "Invalid option -$OPTARG" ;;
    esac
done

if [[ -f "$INITIALIZATION" ]]; then
    printf "\n======================\n"
    printf "Running Initialization\n"
    printf "======================\n\n"
    case "$INITIALIZATION" in
        *.txt)
            pip install --user -r "$INITIALIZATION" || exit_err "Failed to install packages from $INITIALIZATION"
            ;;
        *.yml|*.yaml)
            conda env update --file "$INITIALIZATION" || exit_err "Failed to update environment using $INITIALIZATION"
            ;;
        *.sh)
            bash "$INITIALIZATION" || exit_err "Failed to execute script $INITIALIZATION"
            ;;
        *)
            exit_err "File format not correct. Initialization must be specified in a *.txt, *.yml/yaml, or *.sh file."
            ;;
    esac
fi    

# Launch Polynote and set dependencies and configurations
printf "\n======================\n"
printf "Setting up Polynote\n"
printf "======================\n\n"
# Set Java version to 11
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
python3 /opt/polynote/polynote.py

sleep infinity