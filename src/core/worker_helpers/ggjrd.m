function out = ggjrd(to_append)

if(~exist('to_append','var'))
    to_append='';
end


out=get_global_job_root_dir(to_append);