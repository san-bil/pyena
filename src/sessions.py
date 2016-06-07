from sbpy_utils.core.key_val import kvg, kv_get, kv_set_recurse, kv_get_recurse
from sbpy_utils.core.command_line import islocalhost,get_default_ssh_key,mkdir_p2,easy_file_append,remote_file_exists
from sbpy_utils.core.my_copy import rsync,rsyncs,save_and_rsync
from sbpy_utils.core.my_random import get_random_uname
from sbpy_utils.core.my_io import my_load,my_save
from sbpy_utils.core.my_datetime import get_simple_date
from sbpy_utils.core.reflection import get_caller
from sbpy_utils.core.interactive import user_prompt_loop
from sbpy_utils.core.git_tools import git_clone
from pyena import find_free_hyena_machines, create_hyena_worker_pool
from core import get_pyena_dir, get_pyena_dep_repos, submit_to_condor
import os
import time
import warnings
def create_condor_session(condor_task_root_dir, volatile_src_paths, session_options):

#%   condor_task_root_dir = root directory for all the condor tasks to be
#%                        launched from this session
#%                        e.g. '$HOME/experiments'                       
#%   volatile_src_paths   = cell array of paths containing necessary source
#%                        code for the jobs to be launched from this session
#%                        e.g. {'$HOME/work/superdeepNN/code/'}
#%   options = nx2 cell array of key-val pairs
#%   condor_rsync_args = cell array of string arguments for rsync, when copying job source 
#%                       code to root experiment directory (e.g. 
#%                        {'--exclude="*.mat"  --include="*.*"'})
#%   remote_submit_host = a host that does have access to condor submission,
#%                        and has a Kerberos keytab file (see:
#%                        https://kb.iu.edu/d/aumh#create). If not supplied,
#%                        we'll try to find one.


    use_hyena=kv_get('use_hyena',session_options,0)
    source_hosts=session_options['source_hosts']

    if(use_hyena):
        hyena_max_users = kv_get('hyena_max_users',session_options,1);
        hyena_hosts_needed= kv_get('hyena_hosts_needed',session_options,2);
        jobs_per_hyena_node=kv_get('jobs_per_hyena_node',session_options,2);
        hyena_candidate_list_provider=session_options['hyena_candidate_list_provider']
        if(not 'hyena_machines' in session_options):
            hyena_machines,num_curr_users = find_free_hyena_machines(hyena_candidate_list_provider, hyena_max_users,jobs_per_hyena_node,hyena_hosts_needed);
        else:
            hyena_machines = session_options['hyena_machines']
        
        hyena_pool = create_hyena_worker_pool(hyena_machines,jobs_per_hyena_node);
        session_options['hyena_pool']=hyena_pool
        all_source_hosts = source_hosts;
    else:
        submit_host=session_options['submit_host']
        all_source_hosts=list(set(source_hosts+[submit_host]))

    
    volatile_src_task_path = os.path.join(condor_task_root_dir,'volatile')
    
    rsync_args = kv_get('matador_rsync_args',session_options,{''});
    print('Copying source to remote filesystem...');
    for source_host in all_source_hosts:
        is_remote_submit_host = not islocalhost(source_host);
        if(is_remote_submit_host):
            ssh_key=kv_get('ssh_key',session_options,get_default_ssh_key());
            mkdir_p2(volatile_src_task_path,source_host,ssh_key);
            rsyncs(volatile_src_paths, volatile_src_task_path, rsync_args,source_host,ssh_key, 'push')
            git_clone(get_pyena_dep_repos(),volatile_src_task_path,source_host,ssh_key)
        else:
            mkdir_p2(volatile_src_task_path);
            rsyncs(volatile_src_paths,volatile_src_task_path,rsync_args);
            git_clone(get_pyena_dep_repos(),volatile_src_task_path);

            
    session_uname = get_random_uname();
    
    easy_file_append(session_uname, os.path.join(condor_task_root_dir,'session_uname.txt'))
    session_options['session_uname']=session_uname
    job_list=[]
    job_to_host_map={}
    session_jobs_tags={}
    
    session_object = {'session_options':session_options,
                      'condor_task_root_dir':condor_task_root_dir, 
                      'volatile_src_task_path':volatile_src_task_path,
                      'job_list':job_list, 
                      'session_jobs_tags':session_jobs_tags,
                      'session_uname':session_uname,
                      'job_to_host_map':job_to_host_map}
    
    if not use_hyena :
        session_object['submit_host']=submit_host
    
    return session_object

def create_hyena_session(condor_root_dir,volatile_source_paths, opts):
    opts['use_hyena']=True
    return create_condor_session(condor_root_dir, volatile_source_paths,opts)


def submit_to_local_session(session_object,  worker_task, worker_args,  options={}, dummy_arg=[]):

    condor_task_cache_path = os.path.join(session_object['condor_task_root_dir'], 'session.mat');

    if(os.path.isfile(condor_task_cache_path,'file')):
        session_object=my_load(condor_task_cache_path)['session_object']

    condor_task_root_dir = session_object['condor_task_root_dir']

    task_dir = os.path.join(condor_task_root_dir,kv_get('job_name',options,'local_'+get_simple_date())); 
    global job_root_dir
    job_root_dir = task_dir;
    mkdir_p2(job_root_dir);

    worker_result=worker_task(*worker_args);
    return worker_result


def submit_to_condor_session(session_object,  worker_task, worker_args, job_tags={}, options={}):

    
    condor_task_cache_path = os.path.join(session_object['condor_task_root_dir'], 'session.mat');
    if(os.path.isfile(condor_task_cache_path)):
        session_object=my_load(condor_task_cache_path)['session_object'];        
    
    condor_task_root_dir = session_object['condor_task_root_dir']
    src_paths = [ session_object['volatile_src_task_path'] ] 
    session_options = kv_get('session_options', session_object,{});
    
    use_hyena=kv_get('use_hyena',session_options,0);
    if(use_hyena):
        hyena_pool = kv_get('hyena_pool',session_options);
        hyena_host = get_next_hyena_host(hyena_pool);
        hyena_host_jobs = kv_get_recursive({hyena_host,'host_slots_used'},hyena_pool);
        hyena_pool = kv_set_recurse({hyena_host,'host_slots_used'},hyena_host_jobs+1,hyena_pool);
        session_options = kv_set('hyena_pool',hyena_pool,session_options);
        session_object = kv_set('session_options',session_options,session_object);
        options = kv_set('hyena_host',hyena_host,options);
        submit_host = hyena_host;
    else:
        submit_host=kv_get('submit_host',session_options);
    
    
    task_dir = os.path.join(condor_task_root_dir,kv_get('job_name',options,get_simple_date())); 
    
    is_remote_submit_host = not islocalhost(submit_host);
    data_path = os.path.join(task_dir,'task_data.mat');
    if(is_remote_submit_host):
        ssh_key=kv_get('ssh_key',session_options,get_default_ssh_key());
        mkdir_p2(task_dir,submit_host,ssh_key);
        save_and_rsync(submit_host,data_path,kv_create(worker_task,worker_args,src_paths,task_dir),ssh_key);
    else:
        mkdir_p2(task_dir);
        task_dict={'worker_task':worker_task,'worker_args':worker_args,'src_paths':src_paths,'task_dir':task_dir}
        my_save(task_dict,data_path)
    
    consub_res = submit_to_condor(data_path,task_dir,kv_join(options,session_options));
    job_id=consub_res[0]
    job_host=consub_res[1]
    
    job_done_file = os.path.join(task_dir,'job_complete.txt');
    
    session_object = kv_append_val('job_list', job_done_file, session_object);
    session_object = kv_set_recurse({'session_jobs_tags',job_done_file},job_tags,session_object);
    session_object = kv_set_recurse({'job_to_host_map',job_done_file},job_host,session_object);
    my_save(condor_task_cache_path,'session_object');
    
    return task_dir

def submit_to_hyena_session(*args):
    return submit_to_condor_session(*args)

def submit_to_condor_session_synchronous(*args):
    
    new_task_dir = submit_to_condor_session(*args)
    pause(10)
    new_jobcomplete_file_path=os.path.join(new_task_dir,'job_complete.txt')
    pyena_wait_on_files(session_object)
    
    worker_result_acc = collect_condor_worker_result({new_jobcomplete_file_path});
    worker_result = worker_result_acc[0];
    simple_fitness_val = kv_get('simple_fitness_val',worker_result);
    return simple_fitness_val







def get_condor_session_job_list(session_object, retrieve_job_tags=['alljobs'], partial_tag_set_matching=True, include_or_exclude='include' ):

    
    if(partial_tag_set_matching):
        tag_set_match_combiner = any
    else:
        tag_set_match_combiner = all

    condor_task_cache_path = os.path.join(session_object['condor_task_root_dir'], 'session.mat')
    
    if(os.path.isfile(condor_task_cache_path,'file')):
        cached_session_object=load(condor_task_cache_path,'session_object')['session_object']
        session_object=cached_session_object

    total_job_list = session_object['job_list']
    session_jobs_tags = session_object['session_jobs_tags']

    matching_idxs = []



    for job in total_job_list:
    
        job_tags = session_jobs_tags[job]
    
        tags_match = tag_set_match_combiner(job_tags in retrieve_job_tags);
        matching_idxs.append(tags_match)



    if((include_or_exclude=='include')):
        final_matching_idxs = map(lambda x: not x,matching_idxs)
    else:
        final_matching_idxs = matching_idxs


    job_list = [total_job_list[i] for i,k in enumerate(final_matching_idxs) if k]
    return job_list





def pyena_wait_on_files(condor_obj,holding_time=5,ssh_key=get_default_ssh_key()):


    condor_task_cache_path = os.path.join(condor_obj['condor_task_root_dir'], 'session.mat')
    if(os.path.isfile(condor_task_cache_path)):
        session_object=my_load(condor_task_cache_path)['session_object']
        condor_obj = session_object

    job_done_files_list = get_condor_session_job_list(condor_obj)

    job_to_hosts_map = condor_obj['job_to_host_map']    
    err_files_list = map(lambda x: (tmp.replace('job_complete.txt','err.txt')), job_done_files_list)

    print('%s waiting on: \n' % get_caller())
    
    for x in job_done_files_list:
        print('       '+x)

    errs_acc = []
    done_files_acc = []
    while(True):
        
        do_all_job_done_files_exist = map(lambda tmp: remote_file_exists(tmp,job_to_hosts_map[tmp],ssh_key),job_done_files_list)
        new_done_files_ind = map(lambda x,y : x^y,done_files_acc, do_all_job_done_files_exist)
        new_done_files = [job_done_files_list[i] for i,k in enumerate(new_done_files_ind) if k]   
        
        for fi in new_done_files:
            print(os.path.dirname(tmp)+' - job is complete.')
        
        if(all(do_all_job_done_files_exist)):
            out=0
            return
        
        errs = map(lambda(tmp):os.path.getsize(tmp)>0,err_files_list)
        new_errs = map(lambda x,y : x^y,errs_acc, errs)
        
        print_pyena_session_err_files(err_files_list(new_errs));
        errs_acc = errs;
        done_files_acc = do_all_job_done_files_exist;
        
        if(all(errs)):
            error('All matador jobs have failed.')
            return -1
        
        time.sleep(holding_time);
            
    print('%s has finished waiting!\n' % get_caller());
    return 0

def print_pyena_session_err_files():
    warnings.warn('print_pyena_session_err_files not implemented')
    

def collect_condor_worker_result(job_list, ignore_unfinished_jobs=False, ssh_key=get_default_ssh_key()):

    condor_task_cache_path = path_join(kv_get('condor_task_root_dir',session_object), 'session.mat')
    if(exist(condor_task_cache_path,'file')):
        load(condor_task_cache_path,'session_object')

    condor_task_root_dir = session_object['condor_task_root_dir']
    job_to_hosts_map = session_object['job_to_hosts_map']
    matador_pickup_remote_results = kv_get_recurse({'session_options','matador_pickup_remote_results'},session_object,0)
    
    retval_acc = {}
    
    for job in job_list:
        indicator_file = job
        job_host=job_to_hosts_map[indicator_file]
        is_job_complete = remote_file_exists(indicator_file,job_host,ssh_key);
        
        if(not is_job_complete):
            if(not ignore_unfinished_jobs):
                user_prompt_loop('Job: %s is not complete. Ignore? (y/n): ' % indicator_file, 
                                 [(lambda(tmp):(tmp in ['y','n']),"You must type 'y' or 'n'.")])
                
                if(user_input=='n'):
                    raise EnvironmentError('Job: %s is not complete.' % indicator_file)
        else:
            task_dir = os.path.dirname(indicator_file);
            
            if( not islocalhost(job_host) and matador_pickup_remote_results):
                rsync(task_dir, condor_task_root_dir,['-chavuz --progress'],job_host,default_ssh_key,'pull')
                task_mat = os.path.join(condor_task_root_dir, os.path.basename(task_dir),'task_data.mat')
            else:
                task_mat = os.path.join(task_dir,'task_data.mat')    
            
            worker_result=my_load(task_mat)['worker_result']
            retval_acc[os.path.basename(job)] = worker_result;
        
    return retval_acc
    
    



