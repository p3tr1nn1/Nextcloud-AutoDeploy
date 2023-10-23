#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <argument1> <argument2>"
  exit 1
fi

arg1="$1"
arg2="$2"

# Create the 'outputs' directory if it doesn't exist
mkdir -p scripts/outputs

# Define the path to the autoconfig.php file
autoconfig_file="scripts/outputs/autoconfig.php"

# Check if the file doesn't exist and create it with touch
if [ ! -f "$autoconfig_file" ]; then
  touch "$autoconfig_file"
fi

# Copy the template to the output file
cat scripts/template.txt > "$autoconfig_file"

# Replace placeholders with argument values
sed -i "s/\$argv\[1\]/'$arg1'/" "$autoconfig_file"
sed -i "s/\$argv\[2\]/'$arg2'/" "$autoconfig_file"