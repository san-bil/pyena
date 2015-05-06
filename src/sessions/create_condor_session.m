function session_object = create_condor_session(condor_task_root_dir, volatile_src_paths, session_options)

% condor_task_root_dir = root directory for all the condor tasks to be
%                        launched from this session
%                        e.g. '/vol/bitbucket/sb1006/experiments'                       
% volatile_src_paths   = cell array of paths containing necessary source
%                        code for the jobs to be launched from this session
%                        e.g. {'/homes/sb1006/work/superdeepNN/code/'}
% options = nx2 cell array of key-val pairs
%   condor_rsync_args = cell array of string arguments for rsync, when copying job source 
%                       code to root experiment directory (e.g. 
%                        {'--exclude="*.mat"  --include="*.*"'})
%   remote_submit = {0,1} - if not using DoC Linux (or a machine that
%                           doesn't have direct access to condor submission), this must be 1
%   remote_submit_host = a host that does have access to condor submission,
%                        and has a Kerberos keytab file (see:
%                        https://kb.iu.edu/d/aumh#create). If not supplied,
%                        we'll try to find one.

rsync_args = kv_get('condor_rsync_args',session_options,{'--exclude="*.mat"'});

submit_host=kv_get('submit_host',session_options);
is_remote_submit_host = ~islocalhost(submit_host);
volatile_src_task_path = path_join(condor_task_root_dir,'volatile');
volatile_src_paths = my_unique([force_fat_matrix(volatile_src_paths) get_matador_dir()]);

if(is_remote_submit_host)
    ssh_key=kv_get('ssh_key',session_options,default_ssh_key);
    my_mkdir(volatile_src_task_path,submit_host,ssh_key);
    rsyncs(volatile_src_paths, volatile_src_task_path, rsync_args,submit_host,ssh_key, 'push')
    git_clone(get_matador_dep_repos(),volatile_src_task_path,submit_host,ssh_key)
else
    my_mkdir(volatile_src_task_path);
    rsyncs(volatile_src_paths,volatile_src_task_path,rsync_args);
    git_clone(get_matador_dep_repos(),volatile_src_task_path);
end

job_list={};
session_jobs_tags = {};
session_object = kv_create(session_options,submit_host,condor_task_root_dir, volatile_src_task_path, job_list, session_jobs_tags);
