function setup_loop_cache(opts)

mystack = dbstack();
caller_func = mystack(2).name;

use_loopcache = kv_get('use_loopcache',opts,1);
loopcache_root_dir = [kv_get('job_root_dir',opts,1) filesep 'loopcache'];
loopcache_frequency = kv_get('loopcache_frequency',opts,1);

if(use_loopcache)
  my_mkdir(loopcache_root_dir);
  loopcache_file = [loopcache_root_dir filesep caller_func '.mat'];
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
end

assignin('caller', 'do_loopcacheload', do_loopcacheload);
assignin('caller', 'loop_tracker', loop_tracker);
assignin('caller', 'loopcache_file', loopcache_file);
assignin('caller', 'use_loopcache', use_loopcache);
assignin('caller', 'loopcache_root_dir', loopcache_root_dir);
assignin('caller', 'loopcache_frequency', loopcache_frequency);