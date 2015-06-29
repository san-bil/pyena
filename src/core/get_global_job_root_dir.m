function out= get_global_job_root_dir(to_append)

if(~exist('to_append','var'))
    to_append='';
end

global job_root_dir;
out = path_append(job_root_dir,to_append);