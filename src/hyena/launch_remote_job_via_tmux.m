function launch_remote_job_via_tmux(remote_host, project_path, func_handle, simple_args)

simple_args_are_simple = cellfun(@(tmp)ischar(tmp) || (isnumeric(tmp) && numel(tmp)==1), simple_args);
assert(all(simple_args_are_simple));

simple_args = cellfun_uo0(@my_num_to_str,simple_args);

remote_matlab_simple_args = concat_cell_string_array(simple_args,',',1);

launcher_script = prepend_path(dirname(mfilename('fullpath')),'launch_exp_via_tmuxssh.sh');

func_string = ['''' func2str(func_handle) '(' remote_matlab_simple_args ')' ''''] ;

cmd = concat_cell_string_array({launcher_script,remote_host,project_path,func_string},' ',1);

[retval, stdout] = system(cmd);

disp(stdout);