function out = get_mutable_task_opts(key,default,handler)

if(~exist('handler','var'))
    handler=@my_str_to_num;
end

out = handler(get_mutable_opts(key,ggjrd('mutable_task_opts.ini'),default));

easy_file_append(key,ggjrd('mutable_task_opts_names'));