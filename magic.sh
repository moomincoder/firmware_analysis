#!/bin/bash
# By CodeNeko
# To parse firmware dumps and to extract creds (or CTF flags)

# dependancies:
# 	binwalk
# 	file
# 	strings
# 	rg (ripgrep)
# 	unsquashfs

input=$1
extracted="_$input.extracted"
mode=$2
# binary_or_not=$3

# programs to run
# binwalk -e
# strings, recursivly and outputing every files strings to a file named "$file.strings"
# rg
# also unzips archives it sees, and unsquashes any squashfs files that it sees
# WARNING: THIS CAN ESSENTIALLY BE A ZIP BOMB DEPENDING ON THE FIRMWARE YOU ARE EXTRACTING


# Check if the folder path is provided
if [[ -z "$input" ]]; then
	echo "Do you want me to read your fucking mind?"
	echo "I'm not that kind of magic"
	exit
fi

if [[ "$input" == "-h" ]]; then
	echo "magic.sh <folder or file> <mode>"
	echo "Modes: default, ctf, web, or bb (bug bounty) This only affects regex"
	exit
fi

normal_regex="pass|user|admin|root|http|HTB{|C1\{|flag\{|(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

ctf_regex="HTB\{|C1\{|flag\{|http|(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

bb_regex="pass|user|admin|root|http|(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

web_regex="http|(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))|ftp|nfs|smb|ssh|snmp|pop3|imap|smtp"

if [[ -z "$mode" || "$mode" == "default" ]]; then
	echo "Default regex engaged"
	regex=$normal_regex
elif [[ "$mode" == "ctf" || "$mode" == "CTF" ]]; then
	echo "Switching to CTF mode regex"
	regex=$ctf_regex
elif [[ "$mode" == "bb" || "$mode" == "BB" ]]; then
	echo "bug bounty regex time"
	regex=$bb_regex
elif [[ "$mode" == "web" || "$mode" == "WEB" ]]; then
	echo "Switching to web regex time"
	regex=$web_regex
fi


function strings_files_recursively {
	folder_path=$1
	find $folder_path -type f -name "*.strings" -exec rm {} +
	# Use find to iterate over all files in the directory and subdirectories
	find "$folder_path" -type f -print | while IFS= read -r file; do
		echo "$file"
		strings "$file" >> "${file}.strings"
	done
	echo "Done stringing files"
}

function binwalking {
	inputFile=$1 
	binwalk -Me $inputFile
}

function grepping_time {
	folder_path=$1
	rg -is -p "$regex" $folder_path
}

function not_a_directory {
	input=$1
	echo "Not a directory, extracting"
	binwalking "$input"
	process_files $extracted
	strings_files_recursively $extracted
	grepping_time $extracted
}


# ON HOLD FOR NOW, ABOVE IS MORE IMPORTANT
function its_a_directory {
	input=$1
	process_files "$input"
	strings_files_recursively "$input"
	grepping_time "$input"
}

function process_files {
	echo $1
    local folder_path="$1"  # Takes the first argument as the folder path
    echo "Processing files"

    # Check if the folder path is provided
    if [[ -z "$folder_path" ]]; then
        echo "Please provide a directory path."
        return 1  # Return with error if no path is provided
    fi

    # Check if the provided path is actually a directory
    if [[ ! -d "$folder_path" ]]; then
        echo "The provided path is not a directory: $folder_path"
        return 1  # Return with error if the path is not a directory
    fi

    Use find to iterate over all files in the directory and subdirectories
    find "$folder_path" -type f -exec bash -c '
        for file_path; do
            file_type=$(file --mime-type "$file_path")  # Get the mime type of the file

            # Check if the file is not a text file
            if [[ ! $file_type =~ text/plain ]]; then
                # Check file content with `file` and process accordingly
                content_type=$(file "$file_path")

                # Check for zip files
                if [[ $content_type =~ Zip ]]; then
                    echo "Unzipping $file_path..."
                    unzip -o "$file_path" -d "${file_path}_unzipped"
                fi

                # Check for SquashFS filesystems
                if [[ $content_type =~ Squashfs ]]; then
                    echo "Unsquashing $file_path..."
                    unsquashfs -f -d "${file_path}_unsquashed" "$file_path"
                fi
            fi
        done
    ' bash {} +
}

if [[ ! -d "$input" ]]; then
	echo "The provided path is not a directory: $input"
	not_a_directory "$input"
else
	echo "The provided input is a directory: $input"
	# echo "Cry about it, this is on hold for right now"
	its_a_directory "$input"
fi
