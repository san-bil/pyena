function session_object = create_condor_session(condor_task_root_dir, volatile_src_paths, options)

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

rsync_args = kv_get('condor_rsync_args',options,{});

volatile_src_task_path = [condor_task_root_dir filesep 'volatile'];
my_mkdir(volatile_src_task_path);


matador_dir = strsplit_inc_delim(mfilename('fullpath'),'matador');
volatile_src_paths{end+1} = matador_dir;
volatile_src_paths = my_unique(volatile_src_paths);
copy_files(volatile_src_paths,volatile_src_task_path,1,rsync_args);

job_list={};
session_jobs_tags = {};

remote_submit = kv_get('remote_submit',options,0);
session_options = kv_create(remote_submit);

if(remote_submit)
    
    if(kv_haskey('remote_submit_host',options))
        remote_submit_host = kv_get('remote_submit_host',options);
    else
        remote_submit_host_getter = kv_get('remote_submit_host_getter',options,@get_good_doc_condor_submitter);
        remote_submit_host = remote_submit_host_getter();
    end
    
    session_options = kv_set('remote_submit_host',remote_submit_host,session_options);
end


session_object = kv_create(session_options,condor_task_root_dir, volatile_src_task_path, job_list, session_jobs_tags);
