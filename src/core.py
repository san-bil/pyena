import os,sys,pickle,socket,inspect,re
from string import Template
from sbpy_utils.core.my_copy import rsync
from sbpy_utils.core.command_line import chmod,my_system, touch, easy_file_append, ssh_call, get_default_ssh_key
from sbpy_utils.core.file_system import mkdir_p
from sbpy_utils.core.key_val import kvg,kv_get, kv_read, get_mutable_opts
from sbpy_utils.core.my_datetime import get_simple_date
from sbpy_utils.core.my_io import my_readlines,my_writelines
from profiles.vanilla.condor import get_vanilla_condor_profile
from pyena import launch_condor_job_via_hyena
import cloudpickle
import logging


def run_remote_job(experiment_setup_data_path):

    task_dir = os.path.dirname(experiment_setup_data_path);

    try_folder = os.path.join(task_dir,'trys')                              
    if not os.path.exists(try_folder):
        os.makedirs(try_folder)
        
    simple_date=get_simple_date()
    try_file = os.path.join(try_folder,simple_date)+'.log' 
    
    open(try_file,'a').close()
    exp_data=cloudpickle.load(open(experiment_setup_data_path,'rb'))
    worker_task = exp_data['worker_task']
    worker_args = exp_data['worker_args']

    set_global_job_root_dir(task_dir)

    try:
        worker_result = worker_task(*worker_args);
        job_completion_file = open(os.path.join(task_dir,'job_complete.txt'),'w').close();
        simple_finish_date=get_simple_date()
        pickle.dump(open(os.path.join(task_dir,'worker_result.p'),'wb'), {'worker_result': worker_result});
    except Exception as job_err:
        logging.exception(job_err)
        sys.exit("error caught in run_remote_job()")

def dollar_template_file(template_path,template_dict,output_path):
    template=Template(open(template_path, "r").read())    
    templated=template.substitute(**template_dict)
    out_handle=open(output_path, "w").write(templated)
    return output_path
    
def get_pyena_tempfile(ext,stem='file'):

    tmp_folder = os.path.join('/tmp','pyena');
    mkdir_p(tmp_folder);
    tmpfile_path = os.path.join(tmp_folder,stem+'_'+get_simple_date()+'.'+ext); 
    return tmpfile_path
    
def submit_to_condor(data_path,task_dir='',options={}):


    if(task_dir==''):
        task_dir = os.path.dirname(data_path)

    use_hyena = 'use_hyena' in options and options['use_hyena']
    if(use_hyena):
        submit_host = options['hyena_host']
    else:
        submit_host = options['submit_host']
    
    local_host=socket.gethostname()
    submit_host_bare=submit_host.split('@')[1].split('.')[0]
    is_remote_host= not local_host==submit_host_bare
    
    CONDOR_TASK_DESC_PATH = os.path.join(task_dir,'condor_task_desc.cmd');
    OUTPUT_FILE = os.path.join(task_dir,'output.txt');
    ERROR_FILE = os.path.join(task_dir,'err.txt');
    LOG_FILE = os.path.join(task_dir,'log.txt');
    LOCAL_CALLER_SCRIPT_PATH = os.path.join(task_dir,'remote_python_launcher.sh');
    LOCAL_DEBUG_TASK_PATH=os.path.join(task_dir,'remote_python_debug_launcher.py');
    LOCAL_PATH_ADDITIONS_LIST=os.path.join(task_dir,'python_path_additions.txt');
    
    if 'condor_profile_provider' in options:
        condor_profile_provider = options['condor_profile_provider']
    else:
        condor_profile_provider = get_vanilla_condor_profile
        
    condor_profile = condor_profile_provider();
    if 'condor_job_requirements' in condor_profile:
        JOB_REQUIREMENTS=condor_profile['condor_job_requirements']
    else:
        JOB_REQUIREMENTS=''
 
    if 'presubmit_auth_steps' in condor_profile:
        presubmit_auth_steps=condor_profile['presubmit_auth_steps']
    else:
        presubmit_auth_steps=''    

    condor_task_desc_dictionary = {'OUTPUT_FILE':OUTPUT_FILE,
                                   'ERROR_FILE':ERROR_FILE,
                                   'LOG_FILE':LOG_FILE,
                                   'LOCAL_CALLER_SCRIPT_PATH':LOCAL_CALLER_SCRIPT_PATH,
                                   'JOB_REQUIREMENTS':JOB_REQUIREMENTS};

    if 'ssh_key' in options:
        ssh_key=options['ssh_key']
    else:
        ssh_key=os.path.join(os.path.expanduser('~'),'.ssh/id_rsa')

    if(not os.path.isfile(ssh_key)):
        raise Exception('ssh key %s not found.' % ssh_key)
    
    
    if(is_remote_host):
        rsync_extra_args = [[],submit_host,ssh_key, 'push']
        chmod_extra_args = [submit_host,ssh_key]
    else:
        rsync_extra_args = []
        chmod_extra_args = []
    
    current_dir = os.path.dirname(os.path.realpath(__file__))
    remote_python_launcher_template_path = os.path.join(current_dir,'remote_python_launcher_template')
    remote_python_debug_template_path = os.path.join(current_dir,'remote_python_debug_template.py')
    condor_task_desc_template_path = os.path.join(current_dir,'condor_task_desc_template')
    
    target_conda_env=kv_get('target_conda_env', options,'')
    python_path_additions=kv_get('python_path_additions', options,'')
    tmpfile_path_1=dollar_template_file(remote_python_launcher_template_path,
                                        {'DATA_PATH':data_path,
                                         'TASK_DIR':task_dir,
                                         'TARGET_CONDA_ENV':target_conda_env,
                                         'PYTHON_PATH_ADDITIONS':python_path_additions,
                                        },
                                        get_pyena_tempfile('sh','remote_python_launcher')
                                        );
    
    tmpfile_path_2=dollar_template_file(condor_task_desc_template_path,
                                  condor_task_desc_dictionary,
                                  get_pyena_tempfile('cmd','condor_task_desc'));

    python_path_additions_lines=python_path_additions.split(':')
    tmpfile_path_3=get_pyena_tempfile('txt','python_path_additions')
    my_writelines(python_path_additions_lines, tmpfile_path_3)

    rsync(tmpfile_path_1, LOCAL_CALLER_SCRIPT_PATH, *rsync_extra_args);
    rsync(tmpfile_path_2, CONDOR_TASK_DESC_PATH, *rsync_extra_args);
    rsync(tmpfile_path_3, LOCAL_PATH_ADDITIONS_LIST, *rsync_extra_args);
    rsync(remote_python_debug_template_path,LOCAL_DEBUG_TASK_PATH)

    chmod(LOCAL_CALLER_SCRIPT_PATH,'755',*chmod_extra_args);

    fake_submit = kv_get('fake_submit',options,0);
    
    
    if((not fake_submit) and  (not use_hyena)):
        condor_submission_script = os.path.join(current_dir,'conSub.sh');
        chmod(condor_submission_script,'755');
        cmd = ' '.join([condor_submission_script, str(is_remote_host), CONDOR_TASK_DESC_PATH, presubmit_auth_steps, submit_host, ssh_key])
        cmd_output = my_system(cmd)
        job_id = condor_get_job_submission_id(cmd_output);
        my_system('echo %s > %s' % (job_id,os.path.join(task_dir,'condor_job_id.txt'))) 
    elif((not fake_submit) and use_hyena):
        hyena_remote_setup_cmds=kvg('hyena_remote_setup_cmds',options,'');
        hyena_host= options['hyena_host']
        launch_condor_job_via_hyena(hyena_host, LOCAL_CALLER_SCRIPT_PATH, kv_get('session_uname',options,'_'),ssh_key,hyena_remote_setup_cmds);
        print('Submitted hyena job in %s to host %s \n' % (task_dir, hyena_host));
        job_id=1;
    else:
        print('Set up job in '+task_dir);
        job_id=1;
    return (job_id,submit_host)

job_root_dir=''
def condor_get_job_submission_id(message):

    lines = message.split('\n');
    
    filterlines = [line for line in lines if 'cluster' in line]
    try:
        linepart=filterlines[0].split('cluster')[1]    
    except Exception as err:
        linepart=''
        print('Job ID not available - submission host returned message: %s' % message)
    return linepart


def set_global_job_root_dir(x):
    global job_root_dir;
    job_root_dir=x;

def get_global_job_root_dir(to_append=''):
    global job_root_dir;
    return os.path.join(job_root_dir,to_append);

def ggjrd(*args):
    return get_global_job_root_dir(*args);
    
def gmto(*args):
    return get_mutable_task_opts(*args)    

def sgjrd(*args):
    set_global_job_root_dir(*args);

def get_mutable_task_opts(key,default,handler=(lambda x:float(x))):
    out = handler(get_mutable_opts(key,ggjrd('mutable_task_opts.ini'),default));
    easy_file_append('"(task %d) %s = %s"' % (-1, key, str(default)), ggjrd('mutable_task_opts_names'));
    return out
    
def get_mutable_pertask_opts(task_ctr,key,default,handler=(lambda x:float(x))):
    out = handler(get_mutable_opts(key,ggjrd('mutable_task_opts_%d.ini'%task_ctr), default));
    easy_file_append('"(task %d) %s = %s"' % (task_ctr, key, str(default)), ggjrd('mutable_task_opts_names'));
    return out


def check_condor_running_on_remote(remote_host, ssh_key=get_default_ssh_key(), options={}):

    verbose = kv_get('verbose',options,0);

    ssh_opts = '-o StrictHostKeyChecking=no -o ConnectTimeout=5';
    remote_cmd = 'condor_q | grep jobs | grep completed | grep removed | grep idle'
        
    res=ssh_call(remote_cmd,remote_host,ssh_key,ssh_opts)
    
    if(verbose):
        print(res);
    
    return ('jobs' in res)


def pyena_check_is_job_cancelled():

    job_cancellation_file = get_global_job_root_dir('cancel_job.txt');
    if(os.path.isfile(job_cancellation_file)):
        print('MATADOR: Exiting job due to cancellation.\n');
        sys.exit();
        
def get_pyena_dep_repos():
    pyena_dir = get_pyena_dir();
    pyena_deps = (my_readlines(os.path.join(pyena_dir,'requirements.txt')))[0]
    return pyena_deps

def get_pyena_dir():

    out = ''.join((re.split('pyena',os.path.realpath(__file__))[:-1]))+'pyena'
    return out