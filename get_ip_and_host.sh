#!/bin/bash

# Ensure yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq could not be found. Please install yq to proceed."
    exit
fi

# Check if master.yml exists
if [ ! -f "master.yml" ]; then
    echo "master.yml file not found!"
    exit 1
fi

# Extract IPs and parent keys
yq eval ' .. | select(has("ansible_host")) | (path | .[-1]) as $host | "\(.ansible_host) \($host)"' master.yml >> hosts
