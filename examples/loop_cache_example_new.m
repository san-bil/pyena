function res = foo(opts)


setup_loop_cache(opts);
i=1;
while(1)
    if(i>loop_tracker)
        check_loop_cache;
        
        %=============LOOP BODY====================

        test_counter=i;
        if(i>1000);break;end;

        %==========================================
        
        loop_tracker=i;
        loopcache_stateful = kv_create(test_counter);
        write_loop_cache;
    end
    i = i+1;
end

res = kv_create(test_counter);
