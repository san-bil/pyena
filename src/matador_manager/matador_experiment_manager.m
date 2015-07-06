function [ output_args ] = matador_experiment_manager(directive, target_folder, target_host, ssh_key )

if(~exist('ssh_key','var')),ssh_key=default_ssh_key;end;

manager_script = prepend_path(dirname(mfilename('fullpath')),'matador_experiment_manager.sh');

if(islocalhost(target_host))
    cmd = concat_cell_string_array({ld_lib_path_fix, 'bash',manager_script,directive, target_folder},' ',1);
else
    cmd = concat_cell_string_array({ld_lib_path_fix,  'ssh -i',ssh_key,target_host,'''bash -s'' < ',manager_script,directive, target_folder},' ',1);
end

[~, stdout] = system_e(cmd);

disp(stdout);
output_args = filter_empty_strings(strsplit(stdout,'\n'))';