#!/bin/bash
# By codeneko to pull ip addresses and urls from firmware so it can pass the IPs to nrich

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <outputfile>"
    exit 1
fi
folder_path="$1"
output_file="$2"
regex_pattern='https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)|(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|^(((?!-))(xn--|_)?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$'
#  ^(((?!-))(xn--|_)?[a-z0-9-]{0,61}[a-z0-9]{1,1}\.)*(xn--)?([a-z0-9][a-z0-9\-]{0,60}|[a-z0-9-]{1,30}\.[a-z]{2,})$

temp_file=$(mktemp)
grep -rhPo "$regex_pattern" "$folder_path" > "$temp_file"
sort "$temp_file" | uniq > "$output_file"
rm "$temp_file"
echo "Deduplicated results saved to $output_file"
/bin/nrich $output_file
