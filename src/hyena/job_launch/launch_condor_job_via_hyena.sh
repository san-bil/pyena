#!/bin/bash

remote_hostname=$1
remote_script_to_run=$2
job_uname=$3
ssh_keyfile=$4

date_string=$job_uname_$(python -c "import time; print (time.strftime(\"%H_%M_%S_\"))+(time.strftime(\"%d-%m-%Y\"))")
session_name=$job_uname_$date_string

ssh -i $ssh_keyfile -t $remote_hostname "tmux new-session -s $session_name -d '$remote_script_to_run 1>$(dirname $remote_script_to_run)/output.txt 2>$(dirname $remote_script_to_run)/err.txt ;exit;'"
