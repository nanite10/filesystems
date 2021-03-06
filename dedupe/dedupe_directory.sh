#!/bin/bash

check_commands(){
        for commandname in $1; do
                if ! which "$commandname" > /dev/null 2>&1; then echo "ERROR: Could not find command: $commandname"; exit 1; fi
        done
}

remove_duplicates(){
        echo "INFO: Starting to search for duplicates in directory: $1"
        touch "$2"
        total_files_freed=0
        total_space_freed=0

        while read full_path; do
                checksum_value=`sha512sum "$full_path" | awk '{print $1}'`
                if grep -q "^$checksum_value$" "$2"; then
                        file_size=`stat -c %s "$full_path"`
                        total_files_freed=$((total_files_freed+1))
                        total_space_freed=$((total_space_freed+file_size))
                        rm -vf "$full_path"
                        echo "$full_path" >> "$3"
                        echo "INFO: Total files freed: $total_files_freed Total space freed: $total_space_freed"
                else
                        echo "$checksum_value" >> "$2"
                fi
        done < <(find "$1" -xdev -type f)
}

show_usage(){
        echo -e "\ndedupe_source_directory.sh \"<path>\""
        exit 1
}

if [ -z "$1" ] || ! [ -d "$1" ]; then show_usage; fi

dedupe_path="$1"
current_time=`date +%s`
dedupe_log="${current_time}_dedupe.log"
dedupe_output="${current_time}_dedupe_list.txt"

check_commands "sha512sum"
remove_duplicates "$dedupe_path" "$dedupe_log" "$dedupe_output"
