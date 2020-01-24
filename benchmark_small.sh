#!/bin/bash

datavol="$1"
volume_path="/mnt/glusterfs/$1"

if ! grep -q "$volume_path[[:blank:]]" /proc/mounts; then echo "ERROR: Mount not found: $volume_path"; fi

creation_list="${datavol}_creation.txt"
stat_list="${datavol}_stat.txt"
read_list="${datavol}_read.txt"
deletion_list="${datavol}_deletion.txt"
result_list="${datavol}_result_"`date +%s`".txt"
for list in "$creation_list" "$read_list" "$stat_list" "$deletion_list" "$result_list"; do
  if [ -e "$list" ]; then echo "INFO: Cleaning up $list"
  rm -f "$list"; fi
done

for directory in {0001..3000}; do
  echo "mkdir $volume_path/$directory > /dev/null 2>&1" >> $creation_list
  echo "stat $volume_path/$directory > /dev/null 2>&1" >> $stat_list
  for subdirectory in {1..2}; do
    echo "mkdir $volume_path/$directory/$subdirectory > /dev/null 2>&1" >> $creation_list
    echo "stat $volume_path/$directory/$subdirectory > /dev/null 2>&1" >> $stat_list
    echo "touch $volume_path/$directory/$record.record.xml > /dev/null 2>&1" >> $creation_list
    echo "stat $volume_path/$directory/$record.record.xml > /dev/null 2>&1" >> $stat_list
    echo "dd if=$volume_path/$directory/$record.record.xml of=/dev/null > /dev/null 2>&1" >> $read_list
    echo "rm -f $volume_path/$directory/$record.record.xml > /dev/null 2>&1" >> $deletion_list
  done
  for record in {1..10}; do
    echo "dd if=/dev/zero of=$volume_path/$directory/$record.pcap bs=4000 count=1 > /dev/null 2>&1" >> $creation_list
    echo "stat $volume_path/$directory/$record.pcap > /dev/null 2>&1" >> $stat_list
    echo "dd if=$volume_path/$directory/$record.pcap of=/dev/null > /dev/null 2>&1" >> $read_list
    echo "rm -f $volume_path/$directory/$record.pcap > /dev/null 2>&1" >> $deletion_list
  done
done

for directory in {0001..3000}; do
  for subdirectory in {1..2}; do
    echo "rm -rf $volume_path/$directory/$subdirectory > /dev/null 2>&1" >> $deletion_list
  done
done

for directory in {0001..3000}; do
  echo "rm -rf $volume_path/$directory > /dev/null 2>&1" >> $deletion_list
done

echo "START: Creation 1 Thread"
start_time=`date +%s`
parallel -P1 < $creation_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne "$datavol,create1thread,create8thread,find1thread,stat1thread,stat8thread,read1thread,read8thread,delete1thread,delete8thread\n$datavol" >> $result_list
echo -ne ",$total_time" >> $result_list

echo "START: Creation 8 Threads"
start_time=`date +%s`
parallel -P8 < $creation_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Find"
start_time=`date +%s`
find $volume_path/ > /dev/null 2>&1
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Stat 1 Thread"
start_time=`date +%s`
parallel -P1 < $stat_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Stat 8 Threads"
start_time=`date +%s`
parallel -P8 < $stat_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Read 1 Thread"
start_time=`date +%s`
parallel -P1 < $read_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Read 8 Thread"
start_time=`date +%s`
parallel -P8 < $read_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Delete 1 Thread"
start_time=`date +%s`
parallel -P1 < $deletion_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time" >> $result_list

echo "START: Delete 8 Threads"
start_time=`date +%s`
parallel -P8 < $deletion_list
end_time=`date +%s`
total_time=`echo "$end_time - $start_time" | bc`
echo -ne ",$total_time\n" >> $result_list

echo "COMPLETED"
