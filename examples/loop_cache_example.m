function loop_cache_example(opts)

%=============SETUP CACHE==================
use_cache = kv_get('use_cache',opts,1);
cache_root_dir = [kv_get('experiment_dir',opts,1) filesep 'cache'];
if(use_cache)
  cache_file = [cache_root_dir filesep 'cache' filesep mfilename '.mat'];
  if(exist(cache_file,'file'))
    load(cache_file, 'loop_tracker');
    doload=1;
  else
    loop_tracker=0;
    save(cache_file,'loop_tracker');
    doload=0;
  end
else
    loop_tracker=0;
end
%==========================================





for g = 1:n_its
    if(g>loop_tracker)
        if(use_cache && doload)
          load(cache_file)
          create_increment_file([mfilename '_load_notification_'],[root_dir filesep 'cache']);
        end

         %=============LOOP BODY====================












         %==========================================

        loop_tracker=g;
        if(use_cache)
          save(cache_file);
          doload=0;
        end
    end       
end

