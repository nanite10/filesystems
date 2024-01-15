#!/bin/bash

show_usage(){
  echo "parallel_rsync_gnu.sh /source_path destination_host::/destination_path <number of concurrent processes> \"job_cmds_file.txt\" \"log_file.txt\""
  echo "NOTE: /source_path must be a directory"
  echo "NOTE: destination_host's target path can either be blank or a specific path:"
  echo "      Blank:                 /source_path/ destination_host::source_path/"
  echo "      Specified Destination: /source_path/ destination_host::destination_path/"
  echo ""
  echo "EXAMPLE: ./parallel_rsync_gnu.sh /data01 cos7s02::data01 50 \"20201124_job_cmnds_file.txt\" \"log_file.txt\""
  echo "         Replicates /data01 on local host to data01 on the target cos7s02 host with up to 50 concurrent jobs"
  echo ""
  exit 1
}

check_command(){
  if ! which "$1" > /dev/null 2>&1; then echo "ERROR: Could not find command: $1"; exit 1; fi
}

generate_commands(){
  parent_structure=`echo "$2" | cut -d':' -f3- | sed 's/^/\//g'`
  echo "rsync -rlptgoDHAXx --numeric-ids --exclude='*' --exclude='*/' --rsync-path=\"mkdir -p \\\"$parent_structure\\\" && rsync\" \"$1\" \"$2\" > /dev/null 2>&1" >> "$3"
  echo "rsync --delete --ignore-errors -rXgAHuSsolxptD --numeric-ids --exclude=\"/*/*\" --exclude aquota.user --exclude aquota.group --exclude export.info.xml --exclude rsnapshot --exclude .zfs --delete --rsync-path=\"mkdir -p \\\"$parent_structure\\\" && rsync\" \"$1\" \"$2\" > /dev/null 2>&1" >> "$3"
}

check_command parallel

if [ -z "$1" ] || ! [ -d "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then show_usage; fi

source_path="$1"
destination_target="$2"
number_processes="$3"
start_time=`date +%s`
job_cmds_file="$4"
log_file="$5"

if [ -e "$job_cmds_file" ]; then echo "ERROR: Job command file exists already: $job_cmds_file"; exit 1; fi

echo "INFO: Started parallel_rsync_gnu.sh $source_path $destination_target $number_processes" >> "$log_file"

while read current_source_path; do
  generate_commands "$source_path/$current_source_path/" "$destination_target/$current_source_path/" "$job_cmds_file"
done < <(find "$source_path/" -xdev -type d ! -name .zfs ! -name rsnapshot -printf '%P\n')

parallel -P"$number_processes" < "$job_cmds_file"

end_time=`date +%s`
total_time=$((end_time-start_time))
echo "INFO: Finished parallel_rsync_gnu.sh $source_path $destination_target $number_processes with elapsed time $total_time" >> "$log_file"
