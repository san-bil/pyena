function good_submitter = get_good_doc_condor_submitter()


all_candidates = get_doc_candidate_list();
 
for i =1:length(all_candidates)

    candidate_host = all_candidates{i};
    is_condor_running = check_condor_running_on_remote(candidate_host);
    if(is_condor_running)
        good_submitter = candidate_host;
        return
    end
    
end