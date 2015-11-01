if(use_loopcache && min(mod(loop_tracker+1,loopcache_frequency))==0)
  disp([get_simple_date() ': Caching ' concat_cell_string_array(kv_getkeys(loopcache_stateful),',',1) ' to ' loopcache_file])
  save(loopcache_file,'loopcache_stateful','loop_tracker','-v7.3');
  do_loopcacheload=0;
end