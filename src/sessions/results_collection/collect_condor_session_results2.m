function retval_acc = collect_condor_session_results2(session_object, return_val_name, ignore_unfinished_jobs,ssh_key)

if(~exist('ignore_unfinished_jobs','var')); ignore_unfinished_jobs = 0; end
if(~exist('ssh_key','var')),ssh_key=default_ssh_key;end;

condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
end

condor_task_root_dir = kv_get('condor_task_root_dir', session_object);
job_list = get_condor_session_job_list(session_object);
job_to_hosts_map = kv_get('job_to_host_map', session_object);
matador_pickup_remote_results = kv_get_recursive({'session_options','matador_pickup_remote_results'},session_object);

retval_acc = cell(length(job_list),1);

for i = 1:length(job_list)
    indicator_file = job_list{i};
    job_host=kv_get(indicator_file,job_to_hosts_map);
    is_job_complete = remote_file_exists(indicator_file,job_host,ssh_key);
    
    if(~is_job_complete)
        if(~ignore_unfinished_jobs)
            user_prompt_loop(['Job: ' indicator_file ' is not complete. Ignore? (y/n): '], {@(tmp)ismember(tmp,{'y','n'}),'You must type ''y'' or ''n''.'})
            if(strcmp(user_input,'n'))
                error(['Job: ' indicator_file ' is not complete.']);
            end
        end
    else
        task_dir = dirname(indicator_file);
        
        fetch_criteria_1 = ~islocalhost(job_host) && matador_pickup_remote_results;
        fetch_criteria_2 = islocalhost(job_host);
        if(fetch_criteria_1)
           rsync(task_dir, condor_task_root_dir, rsync_args,job_host,default_ssh_key,'pull')
           task_mat = path_join(condor_task_root_dir, basename(task_dir),'task_data.mat');
        elseif(fetch_criteria_2)
           task_mat = path_join(task_dir,'task_data.mat');
        end
        
        if(fetch_criteria_1 || fetch_criteria_2)
            load(task_mat,'worker_result');
            return_val = kv_get(return_val_name,worker_result);
        else
            return_val = 'Results not fetched.';
        end
        %% 
        
        retval_acc{i} = return_val;
    end
    

end



