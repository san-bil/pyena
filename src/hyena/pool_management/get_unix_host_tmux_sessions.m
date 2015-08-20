function [out,is_host_up,num_sessions] = get_unix_host_tmux_sessions(host_url)

string_args = {'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ',host_url,'"tmux list-sessions  ;echo ENDSSH"'};
cmd =  [ld_lib_path_fix build_string_args(string_args)];
[~,stdout] =system(cmd);
stdout_lines = filter_empty_strings( strsplit(stdout,'\n') );
out = filter_string_list(stdout_lines,'ENDSSH',1);
out = filter_string_list(out,'failed to connect to server',1);

is_host_up = is_ssh_host_responding(out);
num_sessions = length(out);