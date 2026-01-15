#!/bin/bash

# Bash script to combine the content of multiple files with specified extensions into a single text file,
# using absolute file paths and ensuring each file is processed only once.

# Output file
output_file="utils/combined_files.txt"

# Get the absolute path of the current working directory
current_dir=$(pwd)

# Base directory to search (modify this if you want to search a different subfolder)
base_dir="$current_dir"

# Check if the base_dir exists
if [[ ! -d "$base_dir" ]]; then
    echo "Error: Base directory '$base_dir' does not exist. Exiting."
    exit 1
fi

# Prompt the user for file extensions (without the dot, separated by spaces)
read -p "Enter file extensions (without dot, separated by space, e.g., py txt md): " -a extensions

# Check if extensions were provided
if [ ${#extensions[@]} -eq 0 ]; then
    echo "No extensions provided. Exiting."
    exit 1
fi

# Initialize an empty temporary file to store all matching file paths
temp_file=$(mktemp)

# Function to clean up temporary file on exit
cleanup() {
    rm -f "$temp_file"
}
trap cleanup EXIT

# Loop through each extension and find matching files within the base_dir
for ext in "${extensions[@]}"; do
    # Use find to search for files with the given extension
    # -iname makes the search case-insensitive; remove 'i' if case-sensitive
    find "$base_dir" -type f -iname "*.$ext" >> "$temp_file"
done

# Remove duplicate file paths using sort and uniq
unique_files=$(sort "$temp_file" | uniq)

# Initialize an empty array to hold unique file paths
files=()

# Read unique file paths into the array using a loop to prevent duplication
while IFS= read -r line; do
    # Avoid adding empty lines
    if [[ -n "$line" ]]; then
        files+=("$line")
    fi
done <<< "$unique_files"

# Check if any files were found
if [ ${#files[@]} -eq 0 ]; then
    echo "No files found with the specified extensions in '$base_dir'. Exiting."
    exit 1
fi

# Create or empty the output file
> "$output_file"

# Loop through each unique file and append its content to the output file
for file in "${files[@]}"; do
    # Ensure the file path is absolute
    full_path="$file"
    echo "### $full_path ###" >> "$output_file"
    if [[ -f "$full_path" ]]; then
        cat "$full_path" >> "$output_file"
    else
        echo "Error: $full_path not found." >> "$output_file"
    fi
    echo -e "\n" >> "$output_file"
done

echo "Files combined into $output_file"% 