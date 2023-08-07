#!/usr/bin/env bash
# Description: Kill processes filtered by command that match the given pattern and has been started from more than given number of days ago.
# Usage: pskill.sh <pattern> <days>

# set -x

# check if two arguments were passed
if [ $# -ne 2 ]; then
  echo "usage: pskill.sh <pattern> <days>"
  exit 1
fi

pattern=$1
days=$2

# check if second argument is a positive integer greater than 0
if ! [[ "$days" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: second argument must be a positive integer greater than 0"
  exit 1
fi

# check if there are any processes matching the given pattern
if ! ps aux | grep -v grep | grep -v "$0" | grep -q "$pattern"; then
  echo "no processes found matching pattern '$pattern'"
  exit 0
fi

ps aux | grep "$pattern" | grep -v grep | while read line; do
  pid=`echo $line | awk '{print $2}'`

  start_time=`ps -p $pid -o lstart | grep -v STARTED`
  start_time=`date -d "$start_time" +%s`
  now=`date +%s`
  diff=$(( ($now - $start_time) / 60 / 60 / 24 ))

  # check if process has been started from more than given number of days ago
  if [ $diff -gt $days ]; then
    echo $line
    echo "process $pid started $diff days ago"
    # kill -9 $pid
    echo "process $pid killed"
    echo ""
  fi
done
