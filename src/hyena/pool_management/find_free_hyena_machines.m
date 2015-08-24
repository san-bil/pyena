function [best_machines,num_user_list] = find_free_hyena_machines(candidate_list_provider, user_limit, hyena_worker_per_node_limit, num_machines_ceiling)

if(~exist('user_limit','var'));user_limit=1;end;
if(~exist('num_machines_ceiling','var'));num_machines_ceiling=1;end;
if(~exist('hyena_worker_per_node_limit','var'));hyena_worker_per_node_limit=2;end;


all_candidates = force_skinny_matrix(candidate_list_provider());

best_machines = {};
num_user_list = [];
for i =1:length(all_candidates)
    raw_host = all_candidates{i};
    candidate_host = raw_host;
    [logged_in_users, is_host_up] = get_unix_host_logged_in_users(candidate_host);
    [tmux_sessions, is_host_up] = get_unix_host_tmux_sessions(candidate_host);
    num_users = length(logged_in_users);
    num_tmux_sessions = length(tmux_sessions);
    if(is_host_up && num_users<=user_limit && num_tmux_sessions<hyena_worker_per_node_limit)
        best_machines{end+1} = candidate_host;
        num_user_list = [num_user_list num_users];
        fprintf('%s : %d users, %d hyena sessions\n',raw_host,num_users, num_tmux_sessions);
        if(length(best_machines)>=num_machines_ceiling)
            best_machines=best_machines';
            num_user_list=num_user_list';
            break;
        end
    end
end

