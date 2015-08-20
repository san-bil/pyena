function next_host = get_next_hyena_host(hyena_pool)

% host_slots_used host_slots_total
hyena_machines = kv_getkeys(hyena_pool);


while(1)
    ratios = get_hyena_host_usage_ratios(hyena_pool);
    if(min(ratios)<1)
        break;
    end
    print_log_message(1,2,'\nget_next_hyena_host(): waiting for a hyena node to free up. All currently in use.\n\n')
    pause_with_countdown(10);
    print_log_message(1,2,'\nChecking for free hyena host...\n\n')
end

mindex = argmin(ratios);

next_host = hyena_machines{mindex};