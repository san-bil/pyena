function launch_condor_job_via_hyena(remote_host, script_path, uname, ssh_key,remote_setup_cmds)

if(~exist('ssh_key','var')),ssh_key=default_ssh_key;end;
if(~exist('remote_setup_cmds','var')),remote_setup_cmds='';end;


launcher_script = prepend_path(dirname(mfilename('fullpath')),'launch_condor_job_via_hyena.sh');

cmd = concat_cell_string_array({ld_lib_path_fix,  launcher_script,remote_host,script_path,uname,ssh_key,remote_setup_cmds},' ',1);

[~, stdout] = system(cmd);

disp(stdout);