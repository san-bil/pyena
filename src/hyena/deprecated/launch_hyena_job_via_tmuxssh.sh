#!/bin/bash

# $1=hostname
# $2=working folder
# $3=function to run
ssh_keyfile=$4

date_string=$(python -c "import time; print (time.strftime(\"%H_%M_%S_\"))+(time.strftime(\"%d-%m-%Y\"))")


ssh -i $ssh_keyfile -t $1 "tmux new-session -s $USER_session_$date_string -d 'cd $2; matlab -r \"maddpath;$3;\";exit;'"

