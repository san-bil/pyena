function hyena_obj = create_hyena_session(condor_root_dir,volatile_source_paths, opts)


source_hosts = {'sb1006@corona17.doc.ic.ac.uk'};
hyena_max_users=2;
hyena_hosts_needed=16;
hyena_candidate_list_provider = @()get_doc_candidate_list({'texel'},'sb1006');
fake_submit = 1;
jobs_per_hyena_node = 2;

hyena_obj = create_condor_session(condor_root_dir, ...
                                    volatile_source_paths,...
                                    kv_set('use_hyena',1,opts));

