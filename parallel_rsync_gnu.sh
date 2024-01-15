#!/bin/bash

show_usage(){
  echo "parallel_rsync_gnu.sh /source_path destination_host::/destination_path <number of concurrent processes> \"log_file.txt\""
  echo "NOTE: /source_path must be a directory"
  echo "NOTE: destination_host's target path can either be blank or a specific path:"
  echo "      Blank:                 /source_path/ destination_host::source_path/"
  echo "      Specified Destination: /source_path/ destination_host::destination_path/"
  echo ""
  echo "EXAMPLE: ./parallel_rsync_gnu.sh /data01 cos7s02::data01 4 \"log_file.txt\""
  echo "         Replicates /data01 on local host to data01 on the target cos7s02 host with up to 4 concurrent jobs"
  echo ""
  exit 1
}

check_command(){
  if ! which "$1" > /dev/null 2>&1; then echo "ERROR: Could not find command: $1"; exit 1; fi
}

check_command parallel

if [ -z "$1" ] || ! [ -d "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then show_usage; fi

src_path="$1"
dst_target="$2"
number_processes="$3"
log_file="$4"
start_time=`date +%s`

echo "INFO: Started parallel_rsync_gnu.sh $src_path $dst_target $number_processes" >> "$log_file"

if [[ "$dst_target" == *"::"* ]]; then
  find "$src_path/" -xdev -type d ! -name .zfs ! -name rsnapshot ! -name .snapshot -printf '%P\n' | while read cur_path; do
    parent_structure=`echo "$dst_target/$cur_path/" | cut -d':' -f3- | sed 's/^/\//g'`
    echo "rsync -rlptgoDHAXx --numeric-ids --exclude='*' --exclude='*/' --rsync-path=\"mkdir -p \\\"$parent_structure\\\" && rsync\" \"$src_path/$cur_path/\" \"$dst_target/$cur_path/\" > /dev/null 2>&1"
    echo "rsync --delete --ignore-errors -rXgAHuSsolxptD --numeric-ids --exclude=\"/*/*\" --exclude aquota.user --exclude aquota.group --exclude export.info.xml --exclude rsnapshot --exclude .zfs --delete --rsync-path=\"mkdir -p \\\"$parent_structure\\\" && rsync\" \"$src_path/$cur_path\" \"$dst_target/$cur_path\" > /dev/null 2>&1"
  done | parallel -P"$number_processes"
else
  find "$src_path/" -xdev -type d ! -name .zfs ! -name rsnapshot ! -name .snapshot -printf '%P\n' | while read cur_path; do
    echo "mkdir -p \"$dst_target/$cur_path\" && rsync --delete --ignore-errors -rXgAHuSsolxptD --numeric-ids --exclude=\"/*/*\" --exclude aquota.user --exclude aquota.group --exclude export.info.xml --exclude rsnapshot --exclude .zfs --exclude .snapshot --delete \"$src_path/$cur_path/\" \"$dst_target/$cur_path/\" > /dev/null 2>&1"
  done | parallel -P"$number_processes"
fi

end_time=`date +%s`
total_time=$((end_time-start_time))
echo "INFO: Finished parallel_rsync_gnu.sh $src_path $dst_target $number_processes with elapsed time $total_time" >> "$log_file"
