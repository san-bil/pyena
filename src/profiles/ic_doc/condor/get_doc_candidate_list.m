function all_candidates = get_doc_candidate_list(host_family_order, username)

if(~exist('host_family_order','var'))
    host_family_order = {};
end

machine_count_map = kv_create_w_names('pixel',1:44,...
                                      'texel',1:38,...
                                      'line',1:34,...
                                      'ray',1:40,...
                                      'corona',1:41,...
                                      'edge',1:28, ...
                                      'ianos',1:6 ...
                                  );
machine_count_map = kv_order_keys(host_family_order,machine_count_map);

all_candidates = {};
keys = kv_getkeys(machine_count_map);
for i = 1:length(keys)
    
    key = keys{i};
    host_idxs = kv_get(key,machine_count_map);
    
    tmp_hosts=cellfun_uo0(@(tmp) [username '@' key sprintf('%2.2d',tmp) '.doc.ic.ac.uk'], my_mat2cell(host_idxs));
    all_candidates = [all_candidates; tmp_hosts];

end