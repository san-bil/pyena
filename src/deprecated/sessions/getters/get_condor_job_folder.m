function task_dir = get_condor_job_folder(session_object,  job_name)

condor_task_root_dir = kv_get('condor_task_root_dir',session_object);
task_dir=[condor_task_root_dir filesep job_name]; 
