function out = get_condor_job_text_output(filename, idx, condor_session_obj, tail_num_lines)

job_list = kv_get('job_list', condor_session_obj);
task_dir = get_parent_dir(job_list{idx});
text_file = [task_dir filesep filename];


if(exist('tail_num_lines','var'))
    cmds = {'tail -n', num2str(tail_num_lines), text_file};
else
    cmds = {'cat', text_file};
end


cmd = concat_cell_string_array(cmds,' ');
[~,out] = system(cmd);

