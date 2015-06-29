function acc = collect_condor_worker_result(job_list, ignore_unfinished_jobs)

if(~exist('ignore_unfinished_jobs','var'))
    ignore_unfinished_jobs = 0;
end

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
        acc{i} = worker_result;
    end
    

end



