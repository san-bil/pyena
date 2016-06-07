function job_list = get_condor_session_job_list(session_object, retrieve_job_tags, partial_tag_set_matching, include_or_exclude )

if(~exist('include_or_exclude','var'))
   include_or_exclude = 'include'; 
end

if(~exist('retrieve_job_tags','var'))
   retrieve_job_tags = {'alljobs'}; 
end

if(~exist('partial_tag_set_matching','var') || (partial_tag_set_matching == 1))
	tag_set_match_combiner = @any;
else
	tag_set_match_combiner = @all;
end


condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat');
if(exist(condor_task_cache_path,'file'))
    load(condor_task_cache_path,'session_object');
end


total_job_list = kv_get('job_list',session_object);
session_jobs_tags = kv_get('session_jobs_tags', session_object);

matching_idxs = zeros(length(total_job_list),1);



for i = 1:length(total_job_list)
   
    job = total_job_list{i};
    job_tags = kv_get(job,session_jobs_tags);
    
    tags_match = tag_set_match_combiner(ismember(job_tags, retrieve_job_tags));
    matching_idxs(i) = tags_match;
    
end

if(strcmp(include_or_exclude,'include'))
    final_matching_idxs = ~matching_idxs;
else
    final_matching_idxs = matching_idxs;
end

job_list = total_job_list(final_matching_idxs)';