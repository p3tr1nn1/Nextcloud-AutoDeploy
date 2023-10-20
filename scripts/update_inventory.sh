#!/bin/bash

# Check if the inventory file exists
if [ -f "inventory.ini" ]; then
    # If it exists, erase its content
    > inventory.ini
else
    # If it doesn't exist, create it as a blank file
    touch inventory.ini
fi

# Copy the string to the first line
echo "[my_hosts]" > inventory.ini

# Copy the variable from the command line to the second line
if [ $# -ne 1 ]; then
    echo "Usage: $0 <your_variable>"
    exit 1
fi

variable="$1"
echo "$variable" >> inventory.ini

echo "Inventory file has been updated with the variable."
