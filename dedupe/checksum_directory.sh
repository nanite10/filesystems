#!/bin/bash

check_path(){
	if ! [ -d "$1" ]; then echo "ERROR: Path specified is not a directory."; exit 1; fi
}

check_commands(){
	for commandname in $1; do
		if ! which "$commandname" > /dev/null 2>&1; then echo "ERROR: Could not find command: $commandname"; exit 1; fi
	done
}

checksum_files(){
	touch "$2"
	echo "INFO: Generating checksums from path $1 to file: $2"
	find "$1" -xdev -type f -print0 | xargs -P$3 -0 sha512sum >> "$2"
}

dedupe_log(){
	if ! [ -e "$1" ]; then echo "ERROR: File does not exist: $1"; exit 1; fi
	cut -d' ' -f1 "$1" | sort | uniq > "${1}.temp"
	mv "${1}.temp" "$1"
}

show_usage(){
	echo -e "\nchecksum_files.sh \"<source path>\" \"<output_file>\""
	exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then show_usage; fi

if [ -e "$2" ]; then echo "ERROR: Output file exists: $2"; exit 1; fi

source_path="$1"
source_path_checksum_log="$2"
number_cores=`nproc --all`

check_path "$source_path"
check_commands "sha512sum"
checksum_files "$source_path" "$source_path_checksum_log" "$number_cores"
dedupe_log "$source_path_checksum_log"
