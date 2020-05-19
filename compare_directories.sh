#!/bin/bash

check_path(){
        if ! [ -d "$1" ]; then echo "ERROR: Path specified is not a directory."; exit 1; fi
}

check_cleanup(){
        if [[ "$1" != "noclean" ]] && [[ "$1" != "clean" ]]; then echo "ERROR: Cleanup specified was neither noclean or clean: $1"; exit 1; fi
}

check_commands(){
        for commandname in $1; do
                if ! which "$commandname" > /dev/null 2>&1; then echo "ERROR: Could not find command: $commandname"; exit 1; fi
        done
}

checksum_files(){
        touch "$2"
        while read full_path; do
          echo "INFO: Generating checksum from path: $1 filename: $full_path"
          checksum_value=`sha512sum "$full_path" | awk '{print $1}'`
          echo "${checksum_value},${full_path}" >> "$2"
        done < <(find "$1" -type f -xdev)
}

find_duplicates(){
        echo "INFO: Starting to search for duplicates"
        number_lines=`wc -l "$1"`
        current_line=1
        while read line; do
                echo "INFO: Progress: $current_line / $number_lines"
                checksum_value=`echo "$line" | cut -d',' -f1`
                if [ -z "$checksum_value" ]; then echo "ERROR: Checksum value empty: $checksum_value"; exit 1; fi
                if grep -q "^$checksum_value," "$2"; then
                        echo "$line" >> "$3"
                        grep "^$checksum_value," "$2" >> "$3"
                        echo "" >> "$3"
                        if [[ "$4" == "clean" ]]; then
                                while read duplicate_file; do
                                        rm -vf "$duplicate_file"
                                done < <(grep "^$checksum_value," "$2" | cut -d',' -f2-)
                        fi
                fi
                ((current_line++))
        done < <(cat "$1")
}

show_usage(){
        echo -e "\ncompare_directories.sh \"<source path>\" \"<destination path>\" \"<noclean/clean>\""
        exit 1
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then echo "ERROR: Please specify the correct flags."; show_usage; fi

if [[ "$1" == "$2" ]]; then echo "ERROR: Source and destination paths are the same."; exit 1; fi

source_path="$1"
destination_path="$2"
cleanup="$3"
start_time=`date +%s`
source_path_checksum_log="/dev/shm/compare_directories_${start_time}_source_files.txt"
destination_path_checksum_log="/dev/shm/compare_directories_${start_time}_destination_files.txt"
destination_duplicate_log="/dev/shm/compare_directories_${start_time}_duplicates.txt"

check_path "$source_path"
check_path "$destination_path"
check_cleanup "$cleanup"
check_commands "sha512sum"
checksum_files "$source_path" "$source_path_checksum_log"
checksum_files "$destination_path" "$destination_path_checksum_log"
find_duplicates "$source_path_checksum_log" "$destination_path_checksum_log" "$destination_duplicate_log" "$cleanup"
