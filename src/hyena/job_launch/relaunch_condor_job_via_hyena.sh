#!/bin/bash


remote_script_to_run=$1
job_uname=$(dirname remote_script_to_run)
ssh_keyfile="$HOME/.ssh/id_rsa"

output_file=$(dirname $remote_script_to_run)/output.txt
remote_hostname=$(head -n 1 $output_file)
echo $remote_hostname
ssh -i $ssh_keyfile -t $remote_hostname "tmux list-sessions;exit" | grep $job_uname



#date_string=$job_uname_$(python -c "import time; print (time.strftime(\"%H_%M_%S_\"))+(time.strftime(\"%d-%m-%Y\"))")
#session_name=$job_uname_$date_string

#ssh -i $ssh_keyfile -t $remote_hostname "tmux new-session -s $session_name -d '$remote_script_to_run 1>$(dirname $remote_script_to_run)/output.txt 2>$(dirname $remote_script_to_run)/err.txt ;exit;'"
