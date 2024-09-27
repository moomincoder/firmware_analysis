#!/bin/bash
# By CodeNeko for ripping hashs from a unix filesystem to attempt to crack with john or hashcat

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <outputfile>"
    exit 1
fi
folder_path="$1"
output_file="$2"
regex_pattern='[a-z_][a-z0-9_-]{0,30}[a-z0-9_$-]?:[^:]*:\d+:\d+:[^:]*:[^:]*:[^:]*'
temp_file=$(mktemp)
grep -rhPo "$regex_pattern" "$folder_path" > "$temp_file"
sort "$temp_file" | uniq > "$output_file"
rm "$temp_file"
echo "Deduplicated results saved to $output_file"
