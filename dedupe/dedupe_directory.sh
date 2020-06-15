#!/bin/bash

check_path(){
        if ! [ -d "$1" ]; then echo "ERROR: Path specified is not a directory."; exit 1; fi
}

check_commands(){
        for commandname in $1; do
                if ! which "$commandname" > /dev/null 2>&1; then echo "ERROR: Could not find command: $commandname"; exit 1; fi
        done
}

find_duplicates(){
        echo "INFO: Starting to search for duplicates in directory: $1"
        touch "$2"
        total_files_freed=0
        total_space_freed=0
        while read full_path; do
                if [ -e "$full_path" ]; then
                        checksum_value=`sha512sum "$full_path" | awk '{print $1}'`
                        if grep -q "^$checksum_value" "$2"; then
                                file_size=`stat -c %s "$full_path"`
                                total_files_freed=$((total_files_freed+1))
                                total_space_freed=$((total_space_freed+file_size))
                                rm -vf "$full_path"
                                echo "INFO: Total files freed: $total_files_freed Total space freed: $total_space_freed"
                        else
                                echo "$checksum_value" >> "$2"
                        fi
                fi
        done < <(find "$1" -xdev -type f)
}

show_usage(){
        echo -e "\ndedupe_directory.sh \"<path>\""
        exit 1
}

if [ -z "$1" ] || ! [ -d "$1" ]; then show_usage; fi

dedupe_path="$1"
dedupe_log=`date +%s`"_dedupe.log"

check_path "$dedupe_path"
check_commands "sha512sum"
find_duplicates "$dedupe_path" "$dedupe_log"
