#!/bin/bash

function matador_find_job_ids(){
	find $1 -maxdepth 7 -type f -name *condor_job_id.txt -exec cat {} \; 
}

function matador_restart_incomplete_jobs(){
	matador_folder=$1
	folders=`ls $matador_folder | grep -v volatile`

	for folder in $folders; do

        job_complete_file=$matador_folder/$folder/job_complete.txt;
        if [ -f "$job_complete_file"  ]
        then
            echo "$job_complete_file exists."
        else
            condor_submit $matador_folder/$folder/condor_task_desc.cmd
        fi;

	done;
}

function matador_list_unfinished_jobs(){
	matador_folder=$1
	folders=`ls $matador_folder/ | grep -v volatile | grep -v session`

	for folder in $folders; do

		job_complete_file=$matador_folder/$folder/job_complete.txt;
		if [ -f "$job_complete_file"  ]
		then
		    true;
		else
		    echo $folder
		fi;
	done;
}

function matador_list_jobs_w_errors(){
	matador_folder=$1
	echo -e "\nERRORS FOUND:"
	folders=`ls $matador_folder | grep -v volatile`

	for folder in $folders; do
            
		echo "$folder : "
		err_file=$matador_folder/$folder/err.txt;
		cat $err_file

	done;
}

function matador_launch_unstarted_jobs(){
	matador_folder=$1
	folders=`ls $matador_folder | grep -v volatile`

	for folder in $folders; do
		job_started_file=$folder/output.txt;
		if [ -f "$job_started_file"  ]
		then
		    if [ "$2" == "quiet" ]
		    then 
		      jnk=""   
		    else  
		      echo "$job_started_file exists."
		    fi 
		else
		    condor_submit $folder/condor_task_desc.cmd
		fi;
	done;
}

function matador_get_worker_cmd(){
	#!/bin/bash
	echo ""
	cat $1/remote_matlab_launcher.sh | grep -oP "run_remote_job\([^\(]*\)"
	echo ""
}

function matador_exps_with_unfinished_jobs(){

	search_root_dir=$1
	echo "Finding matador sessions to depth of 5"
	matador_folders=$(find $search_root_dir -maxdepth 5 -type d -name *condor*)

	for matador_folder in $matador_folders; do

	  num_unfinished_condor_jobs=$(matador_list_unfinished_jobs $matador_folder | wc -l)
	  
	  echo '----'
	  echo -n `pwd`" : "
	  echo $num_unfinished_condor_jobs

	  if [ "$2" == "launch_unstarted" ]
	  then
	    matador_launch_unstarted_jobs $matador_folder quiet
	  fi

	done;
}

directive=$1
root_dir=$2

if [[ "$directive" == "find_condor_job_ids" ]]; then
	matador_find_job_ids $root_dir
elif [[ "$directive" == "restart_incomplete" ]]; then
	matador_restart_incomplete_jobs  $root_dir
elif [[ "$directive" == "list_unfinished" ]]; then
	matador_list_unfinished_jobs $root_dir
elif [[ "$directive" == "list_errors" ]]; then
	matador_list_jobs_w_errors $root_dir
elif [[ "$directive" == "launch_unstarted" ]]; then
	matador_launch_unstarted_jobs $root_dir $3
elif [[ "$directive" == "get_cmd" ]]; then
	matador_get_worker_cmd $root_dir
elif [[ "$directive" == "find_unfinished_exps" ]]; then
	matador_exps_with_unfinished_jobs $root_dir $3
else
	echo -n "$(basename $0) usage:"
	echo -e "\n\t restart_incomplete    \t Restart jobs that are yet to complete \
			 \n\t list_unfinished    \t\t List unfinished jobs \
			 \n\t list_errors    \t\t List jobs with errors \
			 \n\t launch_unstarted    \t\t Launch unstarted jobs \
			 \n\t get_cmd    \t\t\t Get run_remote_job string for a particular job (for job debugging purposes) \
			 \n\t find_unfinished_exps   \t Find experiments with jobs still running. \
			 \n\t find_condor_job_ids   \t Find the IDs of all Condor jobs running in folders under this directory \
			 \n\t help   \t\t\t Display this help"
fi

