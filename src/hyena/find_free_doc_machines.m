function [best_machines,num_user_list] = find_free_doc_machines(username,user_limit, num_machines_ceiling)

if(~exist('user_limit','var'));user_limit=1;end;
if(~exist('num_machines_ceiling','var'));num_machines_ceiling=1;end;


all_candidates = get_doc_candidate_list()';

best_machines = {};
num_user_list = [];
for i =1:length(all_candidates)
    raw_host = all_candidates{i};
    candidate_host = [username '@' raw_host];
    [logged_in_users, is_host_up] = get_unix_host_logged_in_users(candidate_host);
    num_users = length(logged_in_users);
    if(is_host_up && num_users<=user_limit)
        best_machines{end+1} = candidate_host;
        num_user_list = [num_user_list num_users];
        fprintf('%s : %d users\n',raw_host,num_users);
        if(length(best_machines)>=num_machines_ceiling)
            best_machines=best_machines';
            num_user_list=num_user_list';
            break;
        end
    end
end

