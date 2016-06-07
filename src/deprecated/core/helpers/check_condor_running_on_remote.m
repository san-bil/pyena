function res = check_condor_running_on_remote(remote_name, options)

if(~exist('options','var'))
    options = {};
end

verbose = kv_get('verbose',options,0);

matlab_shellout_preamble='unset LD_LIBRARY_PATH;';
cmd = 'ssh';
ssh_opts = '-o StrictHostKeyChecking=no -o ConnectTimeout=5';
host = remote_name;
remote_cmd = '"condor_q | grep jobs | grep completed | grep removed | grep idle"';



full_cmd = concat_cell_string_array({matlab_shellout_preamble,cmd,ssh_opts,host,remote_cmd},' ');

[~,b]=system(full_cmd);

if(verbose)
    disp(b);
end
res = ~isempty(regexp(b,'jobs'));