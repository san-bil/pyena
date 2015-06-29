#!/bin/bash

# $1=hostname
# $2=remote script to run
ssh_keyfile=$3

date_string=$(python -c "import time; print (time.strftime(\"%H_%M_%S_\"))+(time.strftime(\"%d-%m-%Y\"))")

ssh -i $ssh_keyfile -t $1 "tmux new-session -s $USER_session_$date_string -d '$2 1>$(dirname $2)/output.txt 2>$(dirname $2)/err.txt ;exit;'"
