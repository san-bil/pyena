function good_submitter = get_good_doc_condor_submitter()

host_idxs = my_mat2cell(1:20);
lines=cellfun(@(tmp) ['line' sprintf('%2.2d',tmp)], host_idxs, 'UniformOutput',0);
rays=cellfun(@(tmp) ['ray' sprintf('%2.2d',tmp)], host_idxs, 'UniformOutput',0);
coronas=cellfun(@(tmp) ['corona' sprintf('%2.2d',tmp)], host_idxs, 'UniformOutput',0);



all_candidates = [rays lines coronas];

for i =1:length(all_candidates)

    fq_candidate = [all_candidates{i} '.doc.ic.ac.uk'];
    res = check_condor_running_on_remote(fq_candidate);
    if(res)
        good_submitter = fq_candidate;
        return
    end
    
end