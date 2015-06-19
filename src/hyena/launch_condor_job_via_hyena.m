function launch_condor_job_via_hyena(remote_host, script_path, ssh_key)

if(~exist('ssh_key','var')),ssh_key=default_ssh_key;end;


launcher_script = prepend_path(dirname(mfilename('fullpath')),'launch_condor_job_via_hyena.sh');

cmd = concat_cell_string_array({ld_lib_path_fix,  launcher_script,remote_host,script_path,ssh_key},' ',1);

[~, stdout] = system(cmd);

disp(stdout);