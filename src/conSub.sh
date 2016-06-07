#!/bin/bash

# in: path to condor job script

# out: nada.

# desc: to be called from matlab (hence the removal of some 
# environment variables which are auto-set by matlab, and cause errors)
# Add condor functions to path, and submits condor job script to the condor daemon

# tags: #condor #matlab #job_submission

unset LD_LIBRARY_PATH
unset OSG_LD_LIBRARY_PATH

is_remote=$1
condor_task_desc_path=$2
presubmit_auth_steps=$3
remote_host=$4
ssh_keyfile=$5


if [ "$is_remote" == "1" ]
then
    ssh -i $ssh_keyfile  -o StrictHostKeyChecking=no -o ConnectTimeout=5 $remote_host 'PATH=$PATH:$CONDOR_HOME/bin;'"$presubmit_auth_steps"';hostname; condor_submit '"$condor_task_desc_path" 
else
    echo is_local
    PATH=$PATH:$CONDOR_HOME/bin; $(eval echo $presubmit_auth_steps ) ;hostname; cd $(dirname $condor_task_desc_path); condor_submit $condor_task_desc_path
fi
