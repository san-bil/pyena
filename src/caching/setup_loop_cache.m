function setup_loop_cache(opts)

mystack = dbstack();
caller_func = mystack(2).name;

use_loopcache = kv_get('use_loopcache',opts,1);
loopcache_root_dir = path_join(kv_get('job_root_dir',opts,pwd),'loopcache');
loopcache_frequency = kv_get('loopcache_frequency',opts,1);

if(use_loopcache)
  my_mkdir(loopcache_root_dir);
  loopcache_file = path_join(loopcache_root_dir, [caller_func '.mat']);
  if(exist(loopcache_file,'file'))
    load(loopcache_file, 'loop_tracker');
    do_loopcacheload=1;
  else
    loop_tracker=0;
    save(loopcache_file,'loop_tracker');
    do_loopcacheload=0;
  end
else
    loop_tracker=0;
    do_loopcacheload=0;
    loopcache_file='';
    use_loopcache=0;
    loopcache_root_dir='';
    loopcache_frequency=1000000000;
end

assignin('caller', 'do_loopcacheload', do_loopcacheload);
assignin('caller', 'loop_tracker', loop_tracker);
assignin('caller', 'loopcache_file', loopcache_file);
assignin('caller', 'use_loopcache', use_loopcache);
assignin('caller', 'loopcache_root_dir', loopcache_root_dir);
assignin('caller', 'loopcache_frequency', loopcache_frequency);