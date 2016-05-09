#!/bin/bash

remote_hostname=$1
remote_script_to_run=$2
job_uname=$3
ssh_keyfile=$4
remote_setup_cmds=$5
date_string=$job_uname_$(date +"%H_%M_%S-%d-%m-%Y")
session_name=$job_uname_$date_string

ssh -i $ssh_keyfile -t $remote_hostname "$remote_setup_cmds ; tmux new-session -s $session_name -d '$remote_script_to_run 1>$(dirname $remote_script_to_run)/output.txt 2>$(dirname $remote_script_to_run)/err.txt ;exit;'"
