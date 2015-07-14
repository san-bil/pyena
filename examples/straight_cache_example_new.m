function res = straight_cache_example_new(opts)


setup_loop_cache(opts);
i=1;
if(i>loop_tracker) %don't change the name "loop_tracker", it's a keyword. Change "i" all you want though.
    check_loop_cache;

    %============= BLOCK 1 ====================

    expensive_stateful_object_one=i;

    %==========================================

    loop_tracker=i;
    loopcache_stateful = kv_create(expensive_stateful_object_one); %don't change the name "loopcache_stateful", it's a keyword. Change "i" all you want though.
    write_loop_cache;
end
i = i+1;

if(i>loop_tracker) %don't change the name "loop_tracker", it's a keyword. Change "i" all you want though.
    check_loop_cache;

    %============= BLOCK 2 ====================

    expensive_stateful_object_two=i;

    %==========================================

    loop_tracker=i;
    loopcache_stateful = kv_create(expensive_stateful_object_one, expensive_stateful_object_two); %don't change the name "loopcache_stateful", it's a keyword. Change "i" all you want though.
    write_loop_cache;
end
i = i+1;

if(i>loop_tracker) %don't change the name "loop_tracker", it's a keyword. Change "i" all you want though.
    check_loop_cache;

    %============= BLOCK 3 ====================

    expensive_stateful_object_three=i;

    %==========================================

    loop_tracker=i;
    loopcache_stateful = kv_create(expensive_stateful_object_one, expensive_stateful_object_two, expensive_stateful_object_three); %don't change the name "loopcache_stateful", it's a keyword. Change "i" all you want though.
    write_loop_cache;
end
i = i+1;

    
res = kv_create(expensive_stateful_object_three);
