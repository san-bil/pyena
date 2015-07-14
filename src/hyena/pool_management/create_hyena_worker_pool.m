function pool = create_hyena_worker_pool(hyena_machines,jobs_per_host)

% host_slots_used host_slots_total

pool = kv_fractal(hyena_machines);


for i = 1:kv_size(pool)

    hyena_machine = hyena_machines{i};
    pool = kv_set_recurse({hyena_machine,'host_slots_used'},0,pool);
    pool = kv_set_recurse({hyena_machine,'host_slots_total'},jobs_per_host,pool);
    
end