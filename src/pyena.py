import os,sys,re
import pickle 
import socket
import inspect
import time
from string import Template

from sbpy_utils.core.my_copy import rsync
from sbpy_utils.core.command_line import chmod,my_system, touch, easy_file_append, ssh_call, get_default_ssh_key, is_ssh_host_responding2,get_local_os
from sbpy_utils.core.file_system import touch, mkdir_p
from sbpy_utils.core.key_val import kvg,kv_get, kv_read, get_mutable_opts
from sbpy_utils.core.my_datetime import get_simple_date
from sbpy_utils.core.string_manipulation import filter_empty_strings, multifilter_string_list
from sbpy_utils.core.synchronization import pause_with_countdown

def launch_condor_job_via_hyena(remote_host, script_path, uname, ssh_key=get_default_ssh_key(),remote_setup_cmds=''):
    
    current_dir = os.path.dirname(os.path.realpath(__file__))
    launcher_script = os.path.join(current_dir,'launch_condor_job_via_hyena.sh')
    cmd = ' '.join([launcher_script,remote_host,script_path,uname,ssh_key,remote_setup_cmds])
    cmd_res = my_system(cmd)

    print(cmd_res)
    
    
def get_unix_host_tmux_sessions(host_url):

    is_host_up = is_ssh_host_responding2(host_url)
    
    if(is_host_up):
        
        string_args = ['ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ',host_url,'"tmux list-sessions  ;echo ENDSSH"'];
        cmd =   ' '.join(string_args)
        cmd_res = my_system(cmd);
        stdout_lines = filter_empty_strings( cmd_res.split('\n') );

        filters=['ENDSSH',
                 'failed to connect to server',
                 'Warning: Permanently added',
                 'RESOURCE-INTENSIVE',
                 'known hosts',
                 'WARNING : Unauthorized access',
                 'prosecuted by law. By accessing',
                 'may be monitored']    

        
        out = multifilter_string_list(stdout_lines,filters,True)
        out = multifilter_string_list(out,['windows (created'],False);
    
        num_sessions = len(out);    
    else:
        fprintf('%s is unresponsive. \n', host_url)
        out={};
        num_sessions = Inf;
    return (out,num_sessions,is_host_up)



def get_unix_host_logged_in_users(host_url):

    is_host_up = is_ssh_host_responding2(host_url);

    if(is_host_up):
    
        grep_cmd = {'linux':'grep -E','mac':'ack'}[get_local_os()]
        string_args = ['ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ',host_url,'"who | '+grep_cmd+'  \'pts|tts|ttys\'  ;echo ENDSSH"'];
        cmd =  ' '.join(string_args)
        cmd_res = my_system(cmd)
        
        stdout_lines = filter_empty_strings( cmd_res.split('\n') );
        
        filters=['ENDSSH',
                 'failed to connect to server',
                 'Warning: Permanently added',
                 'RESOURCE-INTENSIVE',
                 'known hosts',
                 'WARNING : Unauthorized access',
                 'prosecuted by law. By accessing',
                 'may be monitored']

        out = multifilter_string_list(stdout_lines,filters,True)
        out = multifilter_string_list(out,['pts','tty','ttys'],False);    
        num_users = len(out);
        
    else:
        print('%s is unresponsive. \n' % host_url)
        out=[];
        num_users = 10000000000000;
    return (out, num_users,is_host_up)


def find_free_hyena_machines(candidate_list_provider, user_limit=1, hyena_worker_per_node_limit=1, num_machines_ceiling=1, wait_for_free_nodes=True):
    
    all_candidates = candidate_list_provider();
    
    
    
    while(True):
    
        best_machines = [];
        num_user_list = [];
    
        for candidate in all_candidates:
            raw_host = candidate
            candidate_host = raw_host;
            logged_in_users, num_logged_in_users, _ = get_unix_host_logged_in_users(candidate_host);
            tmux_sessions, num_tmux_sessions, is_host_up = get_unix_host_tmux_sessions(candidate_host);

            if(is_host_up and num_logged_in_users<=user_limit and num_tmux_sessions<hyena_worker_per_node_limit):
                best_machines.append(candidate_host)
                num_user_list.append(num_logged_in_users)
                print('%s : %d users, %d hyena sessions\n',(raw_host,num_logged_in_users, num_tmux_sessions));
                if(len(best_machines)>=num_machines_ceiling):
                    return (best_machines,num_user_list)
                else:
                    print('%s : %d users, %d hyena sessions (OCCUPIED)\n' % (raw_host,num_logged_in_users, num_tmux_sessions))
                
        if(wait_for_free_nodes):
            print('\nfind_free_hyena_machines(): waiting for hyena nodes from the candidate list to free up. All currently in use.\n\n');
            time.sleep(3)
        else:
            print('\nfind_free_hyena_machines(): could only acquire %d hyena nodes.\n\n' % len(best_machines));
            return (best_machines,num_user_list)
    return (best_machines,num_user_list)

def get_hyena_host_usage_ratios(hyena_pool):

    hyena_machines = hyena_pool.keys()

    ratios=[];
    for hyena_machine in hyena_pool:
    
        host_slots_used = get_unix_host_tmux_sessions(hyena_machine)[1];
        host_slots_total = hyena_pool[hyena_machine]['host_slots_total']
        ratio = host_slots_used/host_slots_total;
        ratios.append(ratio)
    return ratios

def create_hyena_worker_pool(hyena_machines,jobs_per_host):
    pool = {}
    for hyena_machine in hyena_machines:
        pool[hyena_machine]={'host_slots_used':0,'host_slots_total':jobs_per_host}
    return pool


def get_next_hyena_host(hyena_pool):

    hyena_machines = hyena_pool.keys()
    while(True):
        ratios = get_hyena_host_usage_ratios(hyena_pool)
        min_ratio=min(ratios)
        if(min_ratio<1):
            break;
        
        print('\nget_next_hyena_host(): waiting for a hyena node to free up. All currently in use.\n\n')
        pause_with_countdown(10);
    
    
    mindex = [i for i,r in enumerate(ratios) if r==min_ratio][0]
    
    next_host = hyena_machines[mindex];
    return next_host