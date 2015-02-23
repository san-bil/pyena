function session_object = submit_to_condor_session(session_object,  worker_task, worker_args, job_tags, options)

if(~exist('job_tags','var'))
    job_tags = {};
end

if(~exist('options','var'))
    options = {};
end


condor_task_root_dir = kv_get('condor_task_root_dir',session_object);
volatile_src_task_path = kv_get('volatile_src_task_path', session_object);
src_paths = {volatile_src_task_path};
session_options = kv_get('session_options', session_object,{});

if(kv_haskey('job_name',options))
    job_name = kv_get('job_name',options);
    task_dir=[condor_task_root_dir filesep job_name]; 
else
    task_dir = [condor_task_root_dir filesep datestr(now,'dd-mm-yyyy-HH_MM_SS_FFF')];
end


my_mkdir(task_dir);
data_path = [task_dir filesep 'task_data.mat'];
save(data_path,'worker_task','worker_args','src_paths');
submit_to_condor(data_path,task_dir,kv_join(options,session_options))


job_done_file = [ task_dir filesep 'job_complete.txt' ];
session_object = kv_append_val('job_list', job_done_file, session_object);

session_jobs_tags = kv_get('session_jobs_tags', session_object);
session_jobs_tags = kv_set(job_done_file,job_tags,session_jobs_tags);
session_object = kv_set('session_jobs_tags', session_jobs_tags, session_object);
