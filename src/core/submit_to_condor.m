function submit_to_condor(data_path,task_dir,options)

if(~exist('options','var'))
    options={};
end



current_dir = get_parent_dir(mfilename('fullpath'));

if(~exist('data_path','var'))
    task_dir = get_parent_dir(data_path);
end
%%
condor_task_desc_path = [task_dir filesep 'condor_task_desc.cmd'];

outputFile = [task_dir filesep 'output.txt'];
errorFile = [task_dir filesep 'err.txt'];
logFile = [task_dir filesep 'log.txt'];
remote_launcher_script_path = [task_dir filesep 'remote_matlab_launcher.sh'];
%%
remote_task_dictionary = {
              'DATA_PATH',data_path;
              'TASK_DIR',task_dir;
              };

Templater.fill([current_dir filesep 'remote_matlab_launcher_template'],...
               remote_task_dictionary,...
               remote_launcher_script_path,...
               '\n');
%%
condor_task_desc_dictionary = {
              'OUTPUT_FILE',outputFile;
              'ERROR_FILE',errorFile;
              'LOG_FILE',logFile;
              'LOCAL_CALLER_SCRIPT_PATH',remote_launcher_script_path
              };
          
Templater.fill([current_dir filesep 'condor_task_desc_template'],...
               condor_task_desc_dictionary,...
               condor_task_desc_path,...
               '\n');
           
copyfile([current_dir filesep 'remote_add_relevant_src_paths.m'], [task_dir filesep 'remote_add_relevant_src_paths.m']);
[~, chmod_result] = system(['chmod 755 ' remote_launcher_script_path],'-echo'); 

%%

fake_submit = kv_get('fake_submit',options,0);
remote_submit = kv_get('remote_submit',options,0);

if(fake_submit==0)
    if(remote_submit)
        
        remote_submit_host = kv_get('remote_submit_host',options);
        
        system(['chmod 755 ' current_dir filesep 'conSub_remote.sh']);
        job_submit_cmd_string = [current_dir filesep 'conSub_remote.sh', ' ',condor_task_desc_path, ' ', remote_submit_host];
        [exitVal, sysResult] = system(job_submit_cmd_string);
    else
        system(['chmod 755 ' current_dir filesep 'conSub.sh'])
        job_submit_cmd_string = [current_dir filesep 'conSub.sh', ' ',condor_task_desc_path];
        [exitVal, sysResult] = system(job_submit_cmd_string);
    end
end

verbose = kv_get('verbose',options,1);
if(verbose)
    disp(sysResult)
end  
                
