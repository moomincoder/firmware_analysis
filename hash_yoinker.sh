#!/bin/bash
# By CodeNeko
# For ripping hashs from a unix filesystem to attempt to crack with john or hashcat
# I use the crackstation full dictionary

folder_path="$1"
output_file="$2"
regex_pattern='[a-z_][a-z0-9_-]{0,30}[a-z0-9_$-]?:[^:]*:\d+:\d+:[^:]*:[^:]*:[^:]*'
cracking=false
wordlist="/usr/share/wordlist/passwords/crackstation.txt"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <outputfile>"
    echo "  Optional: (-c -C -crack) <wordlist> (Optional)"
    exit 1
fi


if [[ "$4" == "-crack" || "$4" == "-c" || "$4" == "-C" ]]; then
    echo "Cracking to commence once the hashes have been obtained"
    $cracking = true
    if [[ -z "$5" ]]; then
        echo "Using $wordlist"
        continue
    fi
    echo "Using default of $wordlist"
fi

temp_file=$(mktemp)
grep -rhPo "$regex_pattern" "$folder_path" > "$temp_file"
sort "$temp_file" | uniq > "$output_file"
rm "$temp_file"
echo "Deduplicated results saved to $output_file"

if [[ cracking == true ]]; then
    # Check if hashcat or john is installed, prefer hashcat if both are found
    if command -v hashcat &>/dev/null; then
        to_use=$(command -v hashcat)
    elif command -v john &>/dev/null; then
        to_use=$(command -v john)
    else
        echo "Neither hashcat or john is installed."
        exit 1
    fi

    if [ -z "$output_file" ] || [ -z "$wordlist" ]; then
        echo "No hashes found."
        exit 1
    fi

    # Run hashcat if available
    if [ "$to_use" == "$(command -v hashcat)" ]; then
        echo "Using hashcat..."
        # Run hashcat with autodetection (-m 0 for autodetect)
        "$to_use" -m 0 "$output_file" "$wordlist" --force
    elif [ "$to_use" == "$(command -v john)" ]; then
        echo "Using john..."
        # Run john with --wordlist option and auto-detect hash type
        "$to_use" --wordlist="$wordlist" --format=auto "$output_file"
    fi
fi