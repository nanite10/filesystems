#!/bin/bash

show_usage(){
  echo "parallel_rsync.sh /source_path destination_host::/destination_path <number of concurrent processes> \"log_file.txt\""
  echo "NOTE: /source_path must be a directory"
  echo "NOTE: destination_host's target path can either be blank or a specific path:"
  echo "      Blank:                 /source_path/ destination_host::source_path/"
  echo "      Specified Destination: /source_path/ destination_host::destination_path/"
  echo ""
  echo "EXAMPLE: ./parallel_rsync.sh /data01 cos7s02::data01 50"
  echo "         Replicates /data01 on local host to data01 on the target cos7s02 host with up to 50 concurrent jobs"
  echo ""
  exit 1
}

check_processes_running(){
  while [[ "${#job_pids[@]}" -gt "$1" ]]; do
    for job_pid in "${job_pids[@]}"; do
      ps -p "$job_pid" > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        for entry in "${!job_pids[@]}"; do
          if [[ ${job_pids[entry]} = $job_pid ]]; then
            unset 'job_pids[entry]'
          fi
        done
      fi
    done
  done
}

spawn_job(){
  parent_structure=`echo "$2" | cut -d':' -f3- | sed 's/^/\//g'`
  rsync -rlptgoDHAXx --numeric-ids --exclude='*' --exclude='*/' --rsync-path="mkdir -p \"$parent_structure\" && rsync" "$1" "$2" &
  pid_num="$!"
  job_pids+=("$pid_num")
  rsync --delete --ignore-errors -rXgAHuSsolxptD --numeric-ids --exclude="/*/*" --exclude aquota.user --exclude aquota.group --exclude export.info.xml --exclude rsnapshot --exclude .zfs --delete --rsync-path="mkdir -p \"$parent_structure\" && rsync" "$1" "$2" &
  pid_num="$!"
  job_pids+=("$pid_num")
  echo "INFO: Sync started \"$1\" \"$2\"" >> "$log_file"
}

if [ -z "$1" ] || ! [ -d "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then show_usage; fi

source_path="$1"
destination_target="$2"
number_processes="$3"
job_pids=()
start_time=`date +%s`
log_file="$4"

echo "INFO: Started parallel_rsync.sh $source_path $destination_target $number_processes $job_pids" >> "$log_file"

while read current_source_path; do
  check_processes_running "$number_processes"
  spawn_job "$source_path/$current_source_path/" "$destination_target/$current_source_path/"
done < <(find "$source_path/" -xdev -type d ! -name .zfs ! -name rsnapshot -printf '%P\n')

end_time=`date +%s`
total_time=$((end_time-start_time))
echo "INFO: Finished parallel_rsync.sh $source_path $destination_target $number_processes $job_pids with elapsed time $total_time" >> "$log_file"
