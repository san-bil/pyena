function ratios = get_hyena_host_usage_ratios(hyena_pool)

% host_slots_used host_slots_total
hyena_machines = kv_getkeys(hyena_pool);

ratios=[];
for i = 1:kv_size(hyena_pool)

    hyena_machine = hyena_machines{i};
%    host_slots_used = kv_get_recursive({hyena_machine,'host_slots_used'},hyena_pool);
    [~,~,host_slots_used] = get_unix_host_tmux_sessions(hyena_machine);
    host_slots_total = kv_get_recursive({hyena_machine,'host_slots_total'},hyena_pool);
    ratio = host_slots_used/host_slots_total;
    ratios(end+1) = ratio;
end


