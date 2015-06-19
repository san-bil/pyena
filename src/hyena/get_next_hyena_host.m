function next_host = get_next_hyena_host(hyena_pool)

% host_slots_used host_slots_total
hyena_machines = kv_getkeys(hyena_pool);

ratios=[];
for i = 1:kv_size(hyena_pool)

    hyena_machine = hyena_machines{i};
    host_slots_used = kv_get_recursive({hyena_machine,'host_slots_used'},hyena_pool);
    host_slots_total = kv_get_recursive({hyena_machine,'host_slots_total'},hyena_pool);
    ratio = host_slots_used/host_slots_total;
    ratios = [ratios;ratio];
end

mindex = argmin(ratios);

next_host = hyena_machines{mindex};