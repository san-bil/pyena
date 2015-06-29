function launch_hyena_job_via_tmux(remote_host, project_path, func_handle, simple_args,ssh_key)

disp('launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux launch_hyena_job_via_tmux')


if(~exist('ssh_key','var')),ssh_key=default_ssh_key;end;

simple_args_are_simple = cellfun(@(tmp)ischar(tmp) || (isnumeric(tmp) && numel(tmp)==1), simple_args);
assert(all(simple_args_are_simple));

simple_args = cellfun_uo0(@my_num_to_str,simple_args);

remote_matlab_simple_args = concat_cell_string_array(simple_args,',',1);

launcher_script = prepend_path(dirname(mfilename('fullpath')),'launch_hyena_job_via_tmuxssh.sh');

func_string = ['''' func2str(func_handle) '(' remote_matlab_simple_args ')' ''''] ;

cmd = concat_cell_string_array({launcher_script,remote_host,project_path,func_string,ssh_key},' ',1);

[retval, stdout] = system(cmd);

disp(stdout);
