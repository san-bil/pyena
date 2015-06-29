function out = matador_wait_on_files(condor_obj,holding_time)

% in: a list of file paths
%     a waiting period between file-existence checks
%
% out: nada.
%
% desc: Every holding_time seconds, the function checks for the presence of all the files in files_list.
%       As soon as they all exist, the function exits. Used for sending off a bunch of jobs via the shell,
%       and sychronizing by waiting for the results, instead of waiting for each job synchronously.
%
% tags: #synchronization #jobs #condor #shell
if(~exist('holding_time', 'var'))
   holding_time = 5; 
end

condor_task_cache_path = path_join(kv_get('condor_task_root_dir',condor_obj), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
    condor_obj = session_object;
end

job_done_files_list = get_condor_session_job_list(condor_obj);
err_files_list = cellfun_uo0(@(tmp)strrep(tmp,'job_complete.txt','err.txt'), job_done_files_list);

fprintf('%s waiting on: \n',callerfunc());
disp_cellstr( cellfun_uo0(@(tmp)['       ' tmp],job_done_files_list));


errs_acc = (zeros(size(err_files_list)));
done_files_acc = (zeros(size(job_done_files_list)));
while(1)
    
    
    do_all_job_done_files_exist = logical(my_cell2mat(cellfun_uo0(@(tmp)exist(tmp,'file'),job_done_files_list)));
    new_done_files_ind = xor(done_files_acc, do_all_job_done_files_exist);
    new_done_files = job_done_files_list(new_done_files_ind);
    cellfun_uo0(@(tmp)disp_out([ dirname(tmp) ' - job is complete.' ]),new_done_files);
    
    if(all(do_all_job_done_files_exist));out=0;return;end
    
    errs = logical(my_cell2mat(cellfun_uo0(@(tmp)get_file_size(tmp)>0,err_files_list)));
    new_errs = xor(errs_acc, errs);
    
    print_matador_session_err_files(err_files_list(new_errs));
    errs_acc = errs;
    done_files_acc = do_all_job_done_files_exist;
    
    if(all(errs));out=-1;return;end
    
    pause(holding_time);
    
end

fprintf('%s has finished waiting!\n',callerfunc());
