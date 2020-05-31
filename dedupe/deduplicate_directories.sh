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
	echo "INFO: Starting to search for duplicates from file: $1 in directory: $2"
	total_saved=0
	total_number_files=0
	while read full_path; do
		if [ -e "$full_path" ]; then
			checksum_value=`sha512sum "$full_path" | awk '{print $1}'`
			if grep -q "^$checksum_value" "$1"; then
				file_size=`stat -c %s "$full_path"`
				rm -vf "$full_path"
				total_saved=$((total_saved+file_size))
				total_number_files=$((total_number_files+1))
			fi
		fi
	done < <(find "$2" -xdev -type f)
}

show_usage(){
	echo -e "\ndeduplicate_directories.sh \"<source file>\" \"<destination path>\""
	exit 1
}

if [ -z "$1" ] || ! [ -e "$1" ] || [ -z "$2" ]; then show_usage; fi

source_file="$1"
destination_path="$2"

check_path "$destination_path"
check_commands "sha512sum"
find_duplicates "$source_file" "$destination_path"
echo "INFO: Finished with Number files deleted: $total_number_files Total space saved: $total_saved bytes"
