function hyena_obj = create_hyena_session(condor_root_dir,volatile_source_paths, opts)


hyena_obj = create_condor_session(condor_root_dir, ...
                                    volatile_source_paths,...
                                    kv_set('use_hyena',1,opts));

