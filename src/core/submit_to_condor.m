function [job_id,submit_host] = submit_to_condor(data_path,task_dir,options)

if(~exist('options','var')),options={};end
if(~exist('data_path','var')),task_dir = dirname(data_path);end

use_hyena = kv_haskey('use_hyena',options) && kv_get('use_hyena',options,0);
if(use_hyena)
    submit_host = kv_get('hyena_host',options);
else
    submit_host = kv_get('submit_host',options);    
end
is_remote_host=~islocalhost(submit_host);

set_condor_task_file_paths
condor_profile_provider = kv_get('condor_profile_provider',options,@get_vanilla_condor_profile);
condor_profile = condor_profile_provider();
JOB_REQUIREMENTS = kv_get('condor_job_requirements',condor_profile,'');
presubmit_auth_steps = kv_get('presubmit_auth_steps',condor_profile,'');
condor_task_desc_dictionary = kv_create(OUTPUT_FILE,ERROR_FILE,LOG_FILE,LOCAL_CALLER_SCRIPT_PATH,JOB_REQUIREMENTS);

current_dir = dirname(mfilename('fullpath'));
ssh_key=kv_get('ssh_key',options,default_ssh_key);

if(is_remote_host)
    
    rsync_extra_args = {{},submit_host,ssh_key, 'push'};
    chmod_extra_args = {submit_host,ssh_key};
    %###
%     tmpfile_path_1=Templater.fill(path_join(current_dir,'remote_matlab_launcher_template'),...
%                        {'DATA_PATH',data_path;'TASK_DIR',task_dir;},...
%                        get_matlab_func_tempfile('sh'),...
%                        newline);
%     tmpfile_path_2=Templater.fill(path_join(current_dir,'condor_task_desc_template'),condor_task_desc_dictionary,get_matlab_func_tempfile('cmd'),newline);
%     
%     rsync(tmpfile_path_1, LOCAL_CALLER_SCRIPT_PATH, rsync_extra_args{:});
%     rsync(tmpfile_path_2, CONDOR_TASK_DESC_PATH, rsync_extra_args{:});
else
    rsync_extra_args = {};
    chmod_extra_args = {};
%     Templater.fill(path_join(current_dir,'remote_matlab_launcher_template'),...
%                {'DATA_PATH',data_path;'TASK_DIR',task_dir;},...
%                LOCAL_CALLER_SCRIPT_PATH,...
%                newline);
%     Templater.fill(path_join(current_dir,'condor_task_desc_template'),condor_task_desc_dictionary,CONDOR_TASK_DESC_PATH,newline);
end

tmpfile_path_1=Templater.fill(path_join(current_dir,'remote_matlab_launcher_template'),...
                               {'DATA_PATH',data_path;'TASK_DIR',task_dir;},...
                               get_matlab_func_tempfile('sh'),...
                               newline);
tmpfile_path_2=Templater.fill(path_join(current_dir,'condor_task_desc_template'),condor_task_desc_dictionary,get_matlab_func_tempfile('cmd'),newline);

rsync(tmpfile_path_1, LOCAL_CALLER_SCRIPT_PATH, rsync_extra_args{:});
rsync(tmpfile_path_2, CONDOR_TASK_DESC_PATH, rsync_extra_args{:});

rsync(path_join(current_dir,'remote_add_relevant_src_paths.m'), path_join(task_dir,'remote_add_relevant_src_paths.m'),rsync_extra_args{:});
chmod(LOCAL_CALLER_SCRIPT_PATH,'755',chmod_extra_args{:});

fake_submit = kv_get('fake_submit',options,0);


if(~fake_submit && ~use_hyena)
    condor_submission_script = path_join(current_dir,'conSub.sh');
    ssh_keyfile = kv_get('ssh_keyfile',options,default_ssh_key);
    chmod(condor_submission_script,'755');
    cmd = build_string_args({condor_submission_script, num2str(is_remote_host), CONDOR_TASK_DESC_PATH, presubmit_auth_steps, submit_host, ssh_keyfile});
    [~, stdout] = system_e(cmd);
    job_id = condor_get_job_submission_id(stdout);
    write_cell_of_strings_to_file(path_join(task_dir,'condor_job_id.txt'),{job_id});
elseif(~fake_submit && use_hyena)
    hyena_host= kv_get('hyena_host',options);
    launch_condor_job_via_hyena(hyena_host, LOCAL_CALLER_SCRIPT_PATH, kv_get('session_uname',options,'_'));
    fprintf('Submitted hyena job in %s to host %s \n', task_dir, hyena_host);
    job_id=1;
else
    disp(['Set up job in ' task_dir]);
    job_id=1;
end
