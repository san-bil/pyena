#!/bin/bash

# $1=hostname
# $2=working folder
# $3=function to run


date_string=$(python -c "import time; print (time.strftime(\"%H_%M_%S_\"))+(time.strftime(\"%d-%m-%Y\"))")


ssh -t $1 "tmux new-session -s $USER_session_$date_string_ -d 'cd $2; matlab -r \"maddpath;$3;\";exit;'"

