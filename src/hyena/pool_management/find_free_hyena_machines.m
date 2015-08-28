function [best_machines,num_user_list] = find_free_hyena_machines(candidate_list_provider, user_limit, hyena_worker_per_node_limit, num_machines_ceiling, wait_for_free_nodes)

if(~exist('user_limit','var'));user_limit=1;end;
if(~exist('num_machines_ceiling','var'));num_machines_ceiling=1;end;
if(~exist('hyena_worker_per_node_limit','var'));hyena_worker_per_node_limit=2;end;
if(~exist('wait_for_free_nodes','var'));wait_for_free_nodes=1;end;


all_candidates = force_skinny_matrix(candidate_list_provider());



while(1)
    
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
                return;
            end
        else
            fprintf('%s : %d users, %d hyena sessions (OCCUPIED)\n',raw_host,num_users, num_tmux_sessions);
            
        end
    end

    if(wait_for_free_nodes)
        print_log_message(1,2,'\nfind_free_hyena_machines(): waiting for hyena nodes from the candidate list to free up. All currently in use.\n\n');
    else
        print_log_message(1,2,'\nfind_free_hyena_machines(): could only acquire %d hyena nodes.\n\n', length(best_machines));
        return
    end
end