#!/bin/bash

# Define the path to the input file
input_file="master.yml"
intermediate_file="intermediate.yml"
output_file="output.yml"

# Initialize variables
job_name=""
targets=()

# Function to output the collected job group
output_job_group() {
    if [ -n "$job_name" ] && [ ${#targets[@]} -gt 0 ]; then
        echo "- job_name: \"$job_name\"" >> "$intermediate_file"
        echo "  scrape_interval: 15s" >> "$intermediate_file"
        echo "  scrape_timeout: 14s" >> "$intermediate_file"
        echo "  static_configs:" >> "$intermediate_file"
        echo "  - targets:" >> "$intermediate_file"
        for target in "${targets[@]}"; do
            echo "    - \"$target""9100\"" >> "$intermediate_file"
        done
    fi
}

# Clear the intermediate file if it exists
> "$intermediate_file"

# Read the input file line by line
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ $line == \#* ]]; then
        # Output the previous job group if it exists
        output_job_group
        # Set the new job name
        job_name="${line#\# }"
        targets=()
    elif [[ $line == *ansible_host* ]]; then
        # Add the target (the line above ansible_host) to the targets list
        if [ -n "$previous_line" ]; then
            targets+=("$previous_line")
        fi
    fi
    previous_line="$line"
done < "$input_file"

# Output the last job group
output_job_group

# Use yq to properly format the intermediate file into the final output file
yq e '.' "$intermediate_file" > "$output_file"

# Clean up intermediate file
rm "$intermediate_file"

echo "Output written to $output_file"
