function all_candidates = get_ianos_candidate_list(username)


machine_count_map = kv_create_w_names('ianos',1:6);

all_candidates = {};
keys = kv_getkeys(machine_count_map);
for i = 1:length(keys)
    
    key = keys{i};
    hostcount = kv_get(key,machine_count_map);
    
    tmp_hosts=cellfun_uo0(@(tmp) [username '@' key sprintf('%2.2d',tmp) '.doc.ic.ac.uk'], my_mat2cell(hostcount));
    all_candidates = [all_candidates tmp_hosts];

end