function simple_fitness_val = submit_to_hyena_session_synchronous(session_object,  worker_task, worker_args, job_tags, options)



[session_object,new_task_dir] = submit_to_condor_session(session_object,  worker_task, worker_args, job_tags, options);
pause(10);
new_jobcomplete_file_path=path_join(new_task_dir,'job_complete.txt');
matador_wait_on_files(session_object);

worker_result_acc = collect_condor_worker_result({new_jobcomplete_file_path});
worker_result =worker_result_acc{1};
simple_fitness_val=kv_get('simple_fitness_val',worker_result);