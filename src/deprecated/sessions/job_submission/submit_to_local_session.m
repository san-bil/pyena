
function [worker_result] = submit_to_local_session(session_object,  worker_task, worker_args,  options, dummy_arg)

if(exist('dummy_arg','var'))
    dummy_arg = {}; %this is on purpose. 
end

if(~exist('options','var')),options = {};end

condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
end
    

condor_task_root_dir = kv_get('condor_task_root_dir',session_object);


task_dir = path_join(condor_task_root_dir,kv_get('job_name',options,['local_' datestr(now,'dd-mm-yyyy-HH_MM_SS_FFF')])); 
global job_root_dir
job_root_dir = task_dir;
my_mkdir(job_root_dir);

worker_result=worker_task(worker_args{:});




