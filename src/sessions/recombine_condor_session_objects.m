function condor_session_object = recombine_condor_session_objects(tmp_condor_session_objects_acc)

tmp_condor_session_objects_acc = tmp_condor_session_objects_acc(cellfun(@(tmp)~isempty(tmp),tmp_condor_session_objects_acc ));

if(isempty(tmp_condor_session_objects_acc))
    job_list={};
    session_jobs_tags={};
else
    
    list_of_job_lists  = cellfun(@(tmp)kv_get('job_list',tmp),tmp_condor_session_objects_acc,'UniformOutput',0);
    job_list = [list_of_job_lists{:}];

    session_jobs_tags_acc = cellfun(@(tmp)kv_get('session_jobs_tags',tmp),tmp_condor_session_objects_acc,'UniformOutput',0);
    session_jobs_tags = vertcat(session_jobs_tags_acc{:});
end

condor_task_root_dir = kv_get('condor_task_root_dir',tmp_condor_session_objects_acc{1});
volatile_src_task_path = kv_get('volatile_src_task_path',tmp_condor_session_objects_acc{1});


condor_session_object = kv_create(condor_task_root_dir, volatile_src_task_path, job_list, session_jobs_tags);
