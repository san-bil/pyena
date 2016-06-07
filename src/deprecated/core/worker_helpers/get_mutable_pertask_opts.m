function out = get_mutable_pertask_opts(task_ctr,key,default,handler)

if(~exist('handler','var'))
    handler=@my_str_to_num;
end

out = handler(get_mutable_opts(key,ggjrd(sprintf('mutable_task_opts_%d.ini',task_ctr)), default));

easy_file_append(sprintf('"(task %d) %s = %s"',task_ctr, key, my_num2str(default)), ggjrd('mutable_task_opts_names'));