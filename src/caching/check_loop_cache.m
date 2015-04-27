if(use_loopcache && do_loopcacheload)
  load(loopcache_file,'loopcache_stateful')
  disp([get_simple_date() ': Loaded ''loopcache_stateful'' cached dict from' loopcache_file]);
  try
    kv_unpack(loopcache_stateful);
  catch
    disp('warning - loopcache didnt find loopcache_stateful...the job was probably cancelled before the first loop even finished.')
  end
  clear('loopcache_stateful');
  create_increment_file([strip_extension(basename(loopcache_file)) '_load_notification_'],loopcache_root_dir,'log');
end