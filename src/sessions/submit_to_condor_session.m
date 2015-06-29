
function [session_object,task_dir] = submit_to_condor_session(session_object,  worker_task, worker_args, job_tags, options)

if(~exist('job_tags','var')),job_tags = {};end
if(~exist('options','var')),options = {};end

condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
end
    

condor_task_root_dir = kv_get('condor_task_root_dir',session_object);
volatile_src_task_path = kv_get('volatile_src_task_path', session_object);
src_paths = {volatile_src_task_path}; %#ok<NASGU>
session_options = kv_get('session_options', session_object,{});

submit_host=kv_get('submit_host',session_options);
is_remote_submit_host = ~islocalhost(submit_host);


if(kv_haskey('job_name',options))
    job_name = kv_get('job_name',options);
    task_dir=[condor_task_root_dir filesep job_name]; 
else
    task_dir = [condor_task_root_dir filesep datestr(now,'dd-mm-yyyy-HH_MM_SS_FFF')];
end


data_path = path_join(task_dir,'task_data.mat');

if(is_remote_submit_host)
    ssh_key=kv_get('ssh_key',session_options,default_ssh_key);
    my_mkdir(task_dir,submit_host,ssh_key);
    save_and_rsync(submit_host,data_path,kv_create(worker_task,worker_args,src_paths,task_dir),ssh_key);
else
    my_mkdir(task_dir);
    save(data_path,'worker_task','worker_args','src_paths','task_dir','-v7.3');
end

use_hyena=kv_get('use_hyena',session_options,0);
if(use_hyena)
    hyena_pool = kv_get('hyena_pool',session_options);
    hyena_host = get_next_hyena_host(hyena_pool);
    hyena_host_jobs = kv_get_recursive({hyena_host,'host_slots_used'},hyena_pool);
    hyena_pool = kv_set_recurse({hyena_host,'host_slots_used'},hyena_host_jobs+1,hyena_pool);
    session_options = kv_set('hyena_pool',hyena_pool,session_options);
    session_object = kv_set('session_options',session_options,session_object);
    options = kv_set('hyena_host',hyena_host,options);
end

submit_to_condor(data_path,task_dir,kv_join(options,session_options));

job_done_file = path_join(task_dir,'job_complete.txt');

session_object = kv_append_val('job_list', job_done_file, session_object);
session_object = kv_set_recurse({'session_jobs_tags',job_done_file},job_tags,session_object);

save(condor_task_cache_path,'session_object');