function acc = collect_condor_session_results2(session_object, return_val_name, ignore_unfinished_jobs)

if(~exist('ignore_unfinished_jobs','var'))
    ignore_unfinished_jobs = 0;
end


condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
end

job_list = get_condor_session_job_list(session_object);

acc = cell(length(job_list),1);

for i = 1:length(job_list)
    indicator_file = job_list{i};
    
    if(~exist(indicator_file,'file'))
        if(ignore_unfinished_jobs)
            is_job_complete = 0;
        else
            user_input = input(['Job: ' indicator_file ' is not complete. Ignore? (y/n)']);
            if(strcmp(user_input,'y'))
                is_job_complete=0;
            elseif(strcmp(user_input,'n'))
                error(['Job: ' indicator_file ' is not complete.']);
            else
                error('You must type ''y'' or ''n''.')
            end
        end
    else
        is_job_complete=1;
    end
    
    if(is_job_complete==1)
        task_dir = get_parent_dir(indicator_file);
        task_mat = path_join(task_dir,'task_data.mat');
        load(task_mat,'worker_result');
        return_val = kv_get(return_val_name,worker_result);
        acc{i} = return_val;
    end
    

end



