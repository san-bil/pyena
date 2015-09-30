function session_object = create_condor_session(condor_task_root_dir, volatile_src_paths, session_options)

%   condor_task_root_dir = root directory for all the condor tasks to be
%                        launched from this session
%                        e.g. '$HOME/experiments'                       
%   volatile_src_paths   = cell array of paths containing necessary source
%                        code for the jobs to be launched from this session
%                        e.g. {'$HOME/work/superdeepNN/code/'}
%   options = nx2 cell array of key-val pairs
%   condor_rsync_args = cell array of string arguments for rsync, when copying job source 
%                       code to root experiment directory (e.g. 
%                        {'--exclude="*.mat"  --include="*.*"'})
%   remote_submit_host = a host that does have access to condor submission,
%                        and has a Kerberos keytab file (see:
%                        https://kb.iu.edu/d/aumh#create). If not supplied,
%                        we'll try to find one.


use_hyena=kv_get('use_hyena',session_options,0);
source_hosts=kv_get('source_hosts',session_options);

if(use_hyena)
    hyena_max_users = kv_get('hyena_max_users',session_options,1);
    hyena_hosts_needed= kv_get('hyena_hosts_needed',session_options,10);
    jobs_per_hyena_node=kv_get('jobs_per_hyena_node',session_options,2);
    hyena_candidate_list_provider=kv_get('hyena_candidate_list_provider',session_options);
    hyena_machines = find_free_hyena_machines(hyena_candidate_list_provider, hyena_max_users,jobs_per_hyena_node,hyena_hosts_needed);
    hyena_pool = create_hyena_worker_pool(hyena_machines,jobs_per_hyena_node);
    session_options = kv_set('hyena_pool',hyena_pool,session_options);
    all_source_hosts = source_hosts;
else
    submit_host=kv_get('submit_host',session_options);
    all_source_hosts=my_unique([force_skinny_matrix(source_hosts),{submit_host}]);
end


volatile_src_task_path = path_join(condor_task_root_dir,'volatile');
volatile_src_paths = my_unique([force_fat_matrix(volatile_src_paths) get_matador_dir()]);
rsync_args = kv_get('matador_rsync_args',session_options,{'--exclude="*.mat"'});
fprintf('Copying source to remote filesystem...');
for i = 1:length(all_source_hosts)
    source_host = all_source_hosts{i};
    is_remote_submit_host = ~islocalhost(source_host);
    if(is_remote_submit_host)
        ssh_key=kv_get('ssh_key',session_options,default_ssh_key);
        my_mkdir(volatile_src_task_path,source_host,ssh_key);
        rsyncs(volatile_src_paths, volatile_src_task_path, rsync_args,source_host,ssh_key, 'push')
        git_clone(get_matador_dep_repos(),volatile_src_task_path,source_host,ssh_key)
    else
        my_mkdir(volatile_src_task_path);
        rsyncs(volatile_src_paths,volatile_src_task_path,rsync_args);
        git_clone(get_matador_dep_repos(),volatile_src_task_path);
    end
end

session_uname = get_random_uname();
write_cell_of_strings_to_file(path_join(condor_task_root_dir,'session_uname.txt'),{session_uname})
session_options=kv_set('session_uname',session_uname,session_options);
job_list={}; job_to_host_map={}; session_jobs_tags={};
session_object = kv_create(session_options,condor_task_root_dir, volatile_src_task_path, job_list, session_jobs_tags, session_uname,job_to_host_map);

if(~use_hyena)
    session_object = kv_set('submit_host',submit_host,session_object);
end
