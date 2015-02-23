#!/bin/bash

# in: path to condor job script

# out: nada.

# desc: to be called from matlab (hence the removal of some 
# environment variables which are auto-set by matlab, and cause errors)
# Add condor functions to path, and submits condor job script to the condor daemon

# tags: #condor #matlab #job_submission

unset LD_LIBRARY_PATH
unset OSG_LD_LIBRARY_PATH

ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $2 'setenv PATH ${PATH}:${CONDOR_HOME}/bin;kinit $USER@IC.AC.UK -k -t $HOME/.kerb/$USER.keytab; hostname; condor_submit '"$1"
