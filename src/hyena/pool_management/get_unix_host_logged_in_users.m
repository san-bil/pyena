function [out,is_host_up] = get_unix_host_logged_in_users(host_url)

string_args = {'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ',host_url,'"who | grep -oP ''^[^ ]+''  ;echo ENDSSH"'};
cmd =  [ld_lib_path_fix build_string_args(string_args)];
[~,stdout] =system(cmd);
stdout_lines = filter_empty_strings( strsplit(stdout,'\n') );
out = filter_string_list(stdout_lines,'ENDSSH',1);
is_host_up = is_ssh_host_responding(out);
